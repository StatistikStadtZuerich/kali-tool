test_that("data is still the same", {
  expect_snapshot_value(get_data(), style = "json2")
})
