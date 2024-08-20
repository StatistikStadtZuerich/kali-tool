test_that("check creation of data for chart works", {
  # prepare inputs
  my_inputs <- list(
    "suchfeld" = "",
    "select_year" = 2014,
    "gender_radio_button" = "Alle",
    "select_kreis" = "Ganze Stadt",
    "select_liste" = "Alle Listen",
    "wahlstatus_radio_button" = "Alle"
  )
  filtered_data <- filter_candidates(df_main, my_inputs)
  data_person <- create_data_person(filtered_data, 42)
  df_prefiltered <- create_prefiltered_data(df_details,
                                            my_inputs$select_year,
                                            my_inputs$wahlstatus_radio_button)
  # check data type
  expect_s3_class(create_data_for_chart(df_prefiltered, data_person),
                  "data.frame")
  # check name of candidate
  expect_equal(create_data_for_chart(df_prefiltered, data_person) |>
                 pull(Name) |>
                 unique(),
               data_person$Name)
  # check column names
  expect_named(create_data_for_chart(df_prefiltered, data_person),
               c("Name", "StimmeVeraeListe", "Value"))
  # could test more: dimensions etc

})
