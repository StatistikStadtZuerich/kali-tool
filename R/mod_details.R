#' details UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_details_ui <- function(id){
  ns <- NS(id)
  tagList(
    # Name of selected candidate - requires show_details > 0
    htmlOutput(ns("nameCandidate")),

    # table with info about selected candidate - requires show_details > 0
    shinycssloaders::withSpinner(
      reactableOutput(ns("tableCand")),
      type = 7,
      color = "#0F05A0"
    ),

    # Name of selected candidate
    # Title for table
    hr(),
    h4("Stimmen aus veränderten Listen"),

    # Chart container; can't be used in a conditional panel as when the
    # update_data function is called, the UI is not ready yet when JS tries
    # to target container id.
    # ID must be "sszvis-chart", as this is what the JS is looking to fill
    div(id = ns("sszvis-chart"))

  )
}

#' details Server Functions
#'
#' @noRd
mod_details_server <- function(id, data_person, df_details_prefiltered){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    # Render title of selected person
    output$nameCandidate <- renderText({
      paste0("<br><h2>", data_person()$Name, " (", data_person()$Liste, ")", "</h2><hr>")
    })

    # table for selected person
    output$tableCand <- renderReactable({
      candidate_info <- data_person() |>
        select(-Name, -Wahlkreis, -ListeBezeichnung, -Liste) |>
        gather(`Detailinformationen zu den erhaltenen Stimmen`, Wert)

      get_reactable_details(candidate_info)
    })

    # create and send data for bar chart
    # observeEvent rather than observe to avoid race condition between sending
    # the data and setting the input$show_details/the selected row number
    observe({
      person <- df_details_prefiltered() |>
        filter(Name == data_person()$Name) |>
        filter(Wahlkreis == data_person()$Wahlkreis) |>
        filter(ListeBezeichnung == data_person()$ListeBezeichnung) |>
        select(Name, StimmeVeraeListe, Value) |>
        filter(!is.na(Value) & Value > 0) |>
        arrange(desc(Value))

      update_chart(person, "update_data", session)
    }) |>
      bindEvent(df_details_prefiltered(), data_person())

  })
}

## To be copied in the UI
# mod_details_ui("details_1")

## To be copied in the server
# mod_details_server("details_1")
