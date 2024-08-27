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
    filtered_input$df_details_prefiltered,
    filtered_input$has_changed
  )

  # update downloads appropriately
  observe({
    # create filename
    fn_no_ext <- paste0("Gemeinderatswahlen_Auswahl_",
                        filtered_input$current_inputs$year(), "_",
                        filtered_input$current_inputs$kreis(), "_",
                        filtered_input$current_inputs$liste())
    excel_args <- list(
      "data_for_download" = arrange_for_download(filtered_input$filtered_data(), "xlsx"),
      "string_choice" <- paste(filtered_input$current_inputs$year(),
                                filtered_input$current_inputs$kreis(),
                                filtered_input$current_inputs$liste(),
                               sep = ", ")
    )

    mod_download_server(
      "download_1",
      arrange_for_download(filtered_input$filtered_data(), "csv"),
      fn_no_ext,
      ssz_download_excel,
      excel_args
    )
  }) |>
    bindEvent(filtered_input$has_changed())
}
