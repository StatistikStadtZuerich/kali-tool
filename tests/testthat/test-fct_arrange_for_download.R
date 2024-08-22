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

  #Beruf encoding does not work yet, so is not returned
  expect_named(arrange_for_download(filtered_data),
               c("Wahljahr", "Name", "Alter", "Titel", #"Beruf",
                 "Liste", "ListeBezeichnung",
                 "Wahlkreis", "WahlkreisSort", "BisherLang", "BisherSort"
               ))

  # number of rows should remain the same
  expect_equal(nrow(arrange_for_download(filtered_data)),
               nrow(filtered_data))
})
