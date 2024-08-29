testServer(
  mod_input_server,
  # Add here your module params
  {
    ns <- session$ns
    session$setInputs(
      "suchfeld" = "",
      "select_year" = 2022,
      "gender_radio_button" = "Alle",
      "select_kreis" = "Ganze Stadt",
      "select_liste" = "Alle Listen",
      "wahlstatus_radio_button" = "Alle"
    )
    # Check returned
    res <- session$returned
    expect_named(res, c(
      "filtered_data", "df_details_prefiltered",
      "has_changed", "current_inputs"
    ))

    # make sure output assignment worked
    expect_identical(res$filtered_data(), filtered_data())
    expect_identical(res$df_details_prefiltered(), df_details_prefiltered())
    expect_identical(res$has_changed(), has_changed())

    # check output types
    expect_s3_class(filtered_data(), "data.frame")
    expect_s3_class(df_details_prefiltered(), "data.frame")
    expect_type(res$current_inputs, "list")
    expect_named(
      res$current_inputs,
      c("year", "kreis", "liste")
    )
    expect_true(is.reactive(res$current_inputs$year))
    expect_true(is.reactive(res$current_inputs$kreis))
    expect_true(is.reactive(res$current_inputs$liste))

    # check has_changed actually changes when new input is set
    initial_has_changed <- has_changed()
    session$setInputs(
      "select_liste" = "Grüne"
    )
    expect_false(initial_has_changed == has_changed())
  }
)

test_that("module ui works", {
  ui <- mod_input_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_input_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})
