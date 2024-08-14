test_that("filtering works works", {
  my_inputs <- list(
    "suchfeld" = "",
    "select_year" = 2022,
    "gender_radio_button" = "Alle",
    "select_kreis" = "Ganze Stadt",
    "select_liste" = "Alle Listen",
    "wahlstatus_radio_button" = "Alle"
  )

  # expect only filter for year with default values
  initial_filter <- df_main |>
    filter(Wahljahr == my_inputs$select_year)
  expect_equal(filter_candidates(df_main, my_inputs),
               initial_filter)

  # nur Frauen
  my_inputs$gender_radio_button <- "Weiblich"
  women_filter <- initial_filter |>
    filter(Geschlecht == "Weiblich")
  expect_equal(filter_candidates(df_main, my_inputs),
               women_filter)

  # nur ein Wahlkreis
  my_inputs$select_kreis <- "Kreis 6"
  kreis_filter <- women_filter |>
    filter(Wahlkreis == "Kreis 6")
  expect_equal(filter_candidates(df_main, my_inputs),
               kreis_filter)

  # nur ein Wahlresultat
  my_inputs$wahlstatus_radio_button <- "nicht gewählt"
  result_filter <- kreis_filter |>
    filter(Wahlresultat == "nicht gewählt")
  expect_equal(filter_candidates(df_main, my_inputs),
               result_filter)

  # nur eine Liste
  my_inputs$select_liste <- result_filter$ListeBezeichnung[[1]]
  list_filter <- result_filter |>
    filter(ListeBezeichnung == result_filter$ListeBezeichnung[[1]])
  expect_equal(filter_candidates(df_main, my_inputs),
               list_filter)

  # Name der existiert
  my_inputs$suchfeld <- list_filter$Name[[1]]
  expect_equal(filter_candidates(df_main, my_inputs),
               list_filter |> filter(Name == list_filter$Name[[1]]))

  # Name der nicht existiert
  my_inputs$suchfeld <- "asdf"
  expect_equal(filter_candidates(df_main, my_inputs),
               list_filter |> filter(Name == "asdf"))

})
