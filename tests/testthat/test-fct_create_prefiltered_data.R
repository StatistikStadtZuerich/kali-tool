test_that("check pre-filtering function", {
  year_filter <- 2014
  selection_status_filter <- "gewählt"
  # year filter works
  expect_equal(create_prefiltered_data(df_details, year_filter, "Alle"),
               df_details |> filter(Wahljahr == year_filter))
  # election status filter works
  expect_equal(create_prefiltered_data(df_details, year_filter, selection_status_filter),
               df_details |> filter(Wahljahr == year_filter,
                                    Wahlresultat == selection_status_filter))
  # return is a data.frame
  expect_s3_class(create_prefiltered_data(df_details, year_filter, "Alle"),
                  "data.frame")
})
