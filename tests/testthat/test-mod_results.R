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
df_prefiltered <- create_prefiltered_data(
  df_details,
  my_inputs$select_year,
  my_inputs$wahlstatus_radio_button
)

testServer(
  mod_results_server,
  # Add here your module params
  args = list(reactive(filtered_data), reactive(df_prefiltered), reactive(5)),
  {
    ns <- session$ns
    initial_row <- 3
    session$setInputs("show_details" = initial_row)
    # Check returned
    res <- session$returned
    expect_named(res, c("data_person", "data_download"))

    # make sure output assignment worked
    expect_identical(res$data_person(), data_person())
    expect_identical(res$data_download(), data_download())

    # check output types
    expect_s3_class(data_person(), "data.frame")
    expect_s3_class(data_download(), "data.frame")

    # check detailed info is only available when a row is clicked,
    # i.e. when show_details is > 0
    session$setInputs("show_details" = 0)
    expect_error(data_person())
    expect_error(data_download())
  }
)

test_that("module ui works", {
  ui <- mod_results_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_results_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})
