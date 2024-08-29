test_that("check data download for one candidate works", {
  # prepare inputs
  my_inputs <- list(
    "suchfeld" = "",
    "select_year" = 2022,
    "gender_radio_button" = "Alle",
    "select_kreis" = "Ganze Stadt",
    "select_liste" = "Alle Listen",
    "wahlstatus_radio_button" = "Alle"
  )
  filtered_data <- filter_candidates(df_main, my_inputs)
  row_to_be_selected <- 99
  name_to_be_selected <- filtered_data |>
    slice(row_to_be_selected) |>
    pull(Name)

  # check data type
  expect_s3_class(
    create_data_download_candidate(
      filtered_data,
      row_to_be_selected
    ),
    "data.frame"
  )
  # check correct name is selected
  expect_equal(
    unique(create_data_download_candidate(
      filtered_data,
      row_to_be_selected
    )$Name),
    name_to_be_selected
  )
  # check column names
  expect_named(
    create_data_download_candidate(
      filtered_data,
      row_to_be_selected
    ),
    c(
      "Wahljahr", "Name", "Alter", "Geschlecht", "Beruf", "Wahlkreis",
      "Liste", "Resultat der Wahl", "Wert"
    )
  )
  # # check rows: 5
  expect_equal(
    nrow(create_data_download_candidate(
      filtered_data,
      row_to_be_selected
    )),
    5
  )
})
