test_that("check data_person works", {
  # prepare input data
  my_inputs <- list(
    "suchfeld" = "",
    "select_year" = 2022,
    "gender_radio_button" = "Alle",
    "select_kreis" = "Ganze Stadt",
    "select_liste" = "Alle Listen",
    "wahlstatus_radio_button" = "Alle"
  )
  filtered_data <- filter_candidates(df_main, my_inputs)

  row_to_be_selected <- 29
  name_to_be_selected <- filtered_data |>
    slice(row_to_be_selected) |>
    pull(Name)
  # check correct name is selected
  expect_equal(
    create_data_person(filtered_data, row_to_be_selected)$Name,
    name_to_be_selected
  )
  # check columns: only 9
  expect_equal(
    ncol(create_data_person(filtered_data, row_to_be_selected)),
    9
  )
  # check rows: only 1
  expect_equal(
    nrow(create_data_person(filtered_data, row_to_be_selected)),
    1
  )
  # check data type
  expect_s3_class(
    create_data_person(filtered_data, row_to_be_selected),
    "data.frame"
  )
})
