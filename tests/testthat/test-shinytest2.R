library(shinytest2)

# Setup any PROXY setting here
http_proxy <- Sys.getenv("HTTP_PROXY")
Sys.setenv("HTTP_PROXY" = "")
chromote::set_chrome_args(paste0("--http-proxy=", http_proxy))

test_that("check resetting of list choice", {
  app <- AppDriver$new(name = "kali-golem", height = 1206, width = 2263)
  app$expect_values()
  initial_list_choice <- app$get_value(input = "input_module-select_liste")
  app$set_inputs(`input_module-select_liste` = "Schweizerische Volkspartei – SVP")
  new_list_choice <- app$get_value(input = "input_module-select_liste")
  expect_false(initial_list_choice == new_list_choice)
  app$set_inputs(`input_module-select_year` = "2010")
  # this should reset the list choice
  reset_list_choice <- app$get_value(input = "input_module-select_liste")
  expect_equal(initial_list_choice, reset_list_choice)
})
