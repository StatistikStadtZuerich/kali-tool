test_that("make sure reactable for one candidate works", {
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
  data_person <- create_data_person(filtered_data, 42)

  # check data type
  expect_s3_class(
    create_details_reactable(data_person),
    "reactable"
  )
  # check dimensions
  expect_equal(
    length(create_details_reactable(data_person)$x$tag$attribs$columns),
    2
  )
  expect_equal(
    length(dplyr::last(jsonlite::parse_json(
      create_details_reactable(data_person)$x$tag$attribs$data
    ))),
    5
  )
})
