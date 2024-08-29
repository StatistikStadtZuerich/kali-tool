test_that("arrange for download function works works", {
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

  # Beruf encoding does not work yet, so is not returned for Excel
  expect_named(
    arrange_for_download(filtered_data, "xlsx"),
    c(
      "Wahljahr", "Name", "Alter", "Titel", # "Beruf",
      "Liste", "Liste Bezeichnung", "Wahlkreis", "BisherLang",
      "Geschlecht", "Wahlresultat", "Anzahl Stimmen",
      "Parteieigene Stimmen", "Parteifremde Stimmen",
      "Anteil Stimmen aus veränderten Listen"
    )
  )
  # but it is returned for csv, and csv does not have spaces in column names
  expect_named(
    arrange_for_download(filtered_data, "csv"),
    c(
      "Wahljahr", "Name", "Alter", "Titel", "Beruf",
      "Liste", "ListeBezeichnung",
      "Wahlkreis", "WahlkreisSort", "BisherLang", "BisherSort",
      "Geschlecht", "Wahlresultat", "AnzahlStimmen",
      "ParteieigeneStimmen", "ParteifremdeStimmen",
      "AnteilStimmenausverändertenListen"
    )
  )

  # number of rows should remain the same
  expect_equal(
    nrow(arrange_for_download(filtered_data, "csv")),
    nrow(filtered_data)
  )

  # output type can only be excel or csv
  expect_error(arrange_for_download(filtered_data, "parquet"))
})
