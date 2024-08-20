#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # input module returns filtered data
  filtered_input <- mod_input_server("input_module")

  # main results module returns further filtered data according to click
  info_single_candidate <- mod_results_server(
    "results_1",
    filtered_input$filtered_data,
    filtered_input$has_changed
  )

  observe({
    updateNumericInput(session, "show_details",
      value = info_single_candidate$row_click()
    )
  }) |>
    bindEvent(info_single_candidate$row_click())

  # module with details on one candidate
  mod_details_server(
    "details_1",
    info_single_candidate$data_person,
    filtered_input$df_details_prefiltered
  )

  ## Write Download Table
  # CSV
  output$csvDownload <- downloadHandler(
    filename = function(vote) {
      suchfeld <- gsub(" ", "-", info_single_candidate$data_person()$Name, fixed = TRUE)
      paste0("Gemeinderatswahlen_", input$select_year, "_", suchfeld, ".csv")
    },
    content = function(file) {
      write.csv(info_single_candidate$data_download(), file, fileEncoding = "UTF-8", row.names = FALSE, na = " ")
    }
  )

  # Excel
  output$excelDownload <- downloadHandler(
    filename = function(vote) {
      suchfeld <- gsub(" ", "-", info_single_candidate$data_person()$Name, fixed = TRUE)
      paste0("Gemeinderatswahlen_", input$select_year, "_", suchfeld, ".xlsx")
    },
    content = function(file) {
      ssz_download_excel(
        info_single_candidate$data_download(),
        file,
        info_single_candidate$data_person()$Name
      )
    }
  )
}
