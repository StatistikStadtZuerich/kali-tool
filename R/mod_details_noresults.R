#' details_noresults UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_details_noresults_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # Name of selected candidate - requires show_details > 0
    htmlOutput(ns("name_candidate")),

    # Name of selected candidate
    # Title for table
    h4("Resultate für das aktuelle Wahljahr sind noch nicht verfügbar.")
  )
}

#' details_noresults Server Functions
#'
#' @noRd
mod_details_noresults_server <- function(id, data_person) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Render title of selected person
    output$name_candidate <- renderText({
      paste0("<br><h2>", data_person$Name, " (", data_person$Liste, ")", "</h2><hr>")
    })
  })
}

## To be copied in the UI
# mod_details_noresults_ui("details_noresults_1")

## To be copied in the server
# mod_details_noresults_server("details_noresults_1")
