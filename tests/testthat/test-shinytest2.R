library(shinytest2)

# Setup any PROXY setting here
http_proxy <- Sys.getenv("HTTP_PROXY")
Sys.setenv("HTTP_PROXY" = "")
chromote::set_chrome_args(paste0("--http-proxy=", http_proxy))

test_that("check resetting of list choice", {
  app <- AppDriver$new(name = "kali-golem", height = 1206, width = 2263)
  app$expect_values()

  # check resetting of list input when another input is changed
  initial_list_choice <- app$get_value(input = "input_module-select_liste")
  app$set_inputs(`input_module-select_liste` = "Schweizerische Volkspartei – SVP")
  new_list_choice <- app$get_value(input = "input_module-select_liste")
  expect_false(initial_list_choice == new_list_choice)
  app$set_inputs(`input_module-select_year` = "2010")
  # this should reset the list choice
  reset_list_choice <- app$get_value(input = "input_module-select_liste")
  expect_equal(initial_list_choice, reset_list_choice)

  # make main results appear
  app$click("ActionButtonId")
  # click on row
  app$set_inputs(`results_1-show_details` = 6, allow_no_input_binding_ = TRUE, priority_ = "event")

  # check all values
  app$expect_values()

  # check observe in main app: reset show_inputs when some input is changed
  # after a row has been clicked
  app$set_inputs(`input_module-wahlstatus_radio_button` = "gewählt", wait_ = T)
  Sys.sleep(2) # hacky way to avoid unreliable repetition
  expect_equal(app$get_value(input = "show_details"), 0)
  expect_equal(app$get_value(input = "results_1-show_details"), 0)
  app$expect_values()

  # click another row
  app$set_inputs(`results_1-show_details` = 1, allow_no_input_binding_ = TRUE, priority_ = "event")
  app$expect_values()

  # modify more inputs
  app$set_inputs(`input_module-select_year` = "2022")
  app$expect_values()
  app$set_inputs(`input_module-gender_radio_button` = "Männlich")
  app$expect_values()
  app$set_inputs(`input_module-wahlstatus_radio_button` = "nicht gewählt")
  app$expect_values()
  app$set_inputs(`input_module-select_kreis` = "Kreis 6")
  app$expect_values()
  app$set_inputs(`input_module-suchfeld` = "Meyer")
  app$expect_values()
  app$stop()
})


test_that("{shinytest2} recording: kali-golem-download", {
  app <- AppDriver$new(name = "kali-golem-download", height = 853, width = 1606)
  app$click("ActionButtonId")

  # check csv
  app$expect_download("download_1-csv_download")

  # check excel
  # adjust test for excel: as metadata is different every time, get file and
  # compare only the content
  # not tested like this: the image and the date on the first sheet
  temp_excel_file <- "temp-excel-test.xlsx"
  app$get_download("download_1-excel_download", temp_excel_file)
  sheet1 <- read.xlsx(temp_excel_file, sheet = 1, colNames = F)
  # only test first 3 columns, 4th columns contains date
  expect_snapshot(sheet1[, 1:3])
  sheet2 <- read.xlsx(temp_excel_file, sheet = 2, colNames = F)
  expect_snapshot(sheet2)
  file.remove(temp_excel_file)
})
