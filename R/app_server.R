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
  observe({
    # only show if show_details is > 0; avoid race conditio of module being
    # shown when data is not yet ready
    req(input$show_details)
    mod_details_server(
      "details_1",
      info_single_candidate$data_person,
      filtered_input$df_details_prefiltered
    )

    # create filename (currently without further specifyers like year or suchfeld)
    fn_no_ext <- paste0("Gemeinderatswahlen_Auswahl_",  format(Sys.time(), "%Y-%m-%d_%H:%M:%S"))

    mod_download_server("download_1",
                        arrange_for_download(filtered_input$filtered_data(), "csv"),
                        fn_no_ext,
                        ssz_download_excel,
                        arrange_for_download(filtered_input$filtered_data(), "xlsx"))
  }) |>
    bindEvent(input$show_details)



}
