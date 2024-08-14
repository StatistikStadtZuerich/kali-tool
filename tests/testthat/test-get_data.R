test_that("data is still the same", {
  dfs <- get_data()
  expect_snapshot_value(dfs, style = "json2")
  expect_named(dfs, c("df_main", "df_details"))
})

test_that("there are results for all candidates", {
  dfs <- get_data()
  df_main <- dfs[["df_main"]]
  # there is one missing result in 2018, but there shouldn't be more
  expect_lt(sum(is.na(df_main$Wahlresultat)), 2)
})
