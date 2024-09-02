#' details UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_details_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # Name of selected candidate - requires show_details > 0
    htmlOutput(ns("name_candidate")),

    # table with info about selected candidate - requires show_details > 0
    shinycssloaders::withSpinner(
      reactableOutput(ns("table_candidate")),
      type = 7,
      color = "#0F05A0"
    ),

    # Name of selected candidate
    # Title for table
    hr(),
    h4("Stimmen aus veränderten Listen"),

    # div for d3 chart; namespace is dealt with in server/JS message handler
    div(id = ns("sszvis-chart"))
  )
}

#' details Server Functions
#' @param data_person data frame with data to be shown in small reactable (static)
#' @param df_details_prefiltered data frame to be used for info on candidate's changed votes (static)
#' @noRd
mod_details_server <- function(id, data_person, df_details_prefiltered) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Render title of selected person
    output$name_candidate <- renderText({
      paste0("<br><h2>", data_person$Name, " (", data_person$Liste, ")", "</h2><hr>")
    })

    # table for selected person
    output$table_candidate <- renderReactable({
      create_details_reactable(data_person)
    })

    # create and send data for bar chart
    # observe({
      person <- create_data_for_chart(df_details_prefiltered, data_person)
      id <- paste0("#", ns("sszvis-chart"))
      update_chart(list("data" = person, "container_id" = id), "update_data", session)
    # }) |>
    #   bindEvent(df_details_prefiltered(), data_person())
  })
}

## To be copied in the UI
# mod_details_ui("details_1")

## To be copied in the server
# mod_details_server("details_1")
