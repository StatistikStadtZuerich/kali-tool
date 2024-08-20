# prepare module inputs
my_inputs <- list(
  "suchfeld" = "",
  "select_year" = 2014,
  "gender_radio_button" = "Alle",
  "select_kreis" = "Ganze Stadt",
  "select_liste" = "Alle Listen",
  "wahlstatus_radio_button" = "Alle"
)
filtered_data <- filter_candidates(df_main, my_inputs)
data_person <- create_data_person(filtered_data, 33)
df_prefiltered <- create_prefiltered_data(
  df_details,
  my_inputs$select_year,
  my_inputs$wahlstatus_radio_button
)

testServer(
  mod_details_server,
  # Add here your module params
  args = list(reactive(data_person), reactive(df_prefiltered)),
  {
    ns <- session$ns
    # check outputs are there
    expect_true(stringr::str_detect(output$name_candidate, data_person()$Name))

    expect_true(stringr::str_detect(
      output$table_candidate,
      "Detailinformationen"
    ))

    # to improve/todo: test whether d3 chart is there
  }
)

test_that("module ui works", {
  ui <- mod_details_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_details_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})
