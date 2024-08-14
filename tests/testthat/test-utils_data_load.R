test_that("utils functions for getting the data work", {
  # parameter function
  params <- get_params_data_load()
  # returns a list of years and links, all items should have the same number of items
  expect_equal(length(params[[1]]), length(params[[2]]))
  expect_equal(length(params[[1]]), length(params[[3]]))
})
