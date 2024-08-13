test_that("data is still the same", {
  expect_snapshot_value(get_data(), style = "json2")
})

test_that("utils functions for getting the data work", {
  # parameter function
  params <- get_params_data_load()
  # returns a list of years and links, all items should have the same number of items
  expect_equal(length(params[[1]]), length(params[[2]]))
  expect_equal(length(params[[1]]), length(params[[3]]))
})
