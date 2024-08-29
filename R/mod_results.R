#' results UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_results_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # Title for table
    h1("Die untenstehenden Kandidierenden entsprechen Ihren Suchkriterien"),
    hr(),
    # Define subtitle
    p("Für Detailinformationen zu den Ergebnissen einzelner Kandidierenden wählen Sie eine Zeile aus."),

    # Table Output
    shinycssloaders::withSpinner(
      reactableOutput(ns("table")),
      type = 7,
      color = "#0F05A0"
    ),
    conditionalPanel(
      "input.show_details > 0",
      mod_details_ui(ns("details_1")),
      ns = ns
    ),

    # initialise hidden variable for row selection, to be used with JS function in reactable
    conditionalPanel(
      "false",
      numericInput(
        label = NULL,
        inputId = ns("show_details"),
        value = 0
      )
    ),
  )
}

#' results Server Functions
#' @param filtered_data data frame to be shown in main reactable, reactive
#' @param prefiltered_details df_details pre-filtered according to inputs, reactive
#' @param input_change reactive that changes when user changes something in input widgets
#' @noRd
mod_results_server <- function(id, filtered_data, prefiltered_details, input_change) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # main Reactable Output
    output$table <- renderReactable({
      get_reactable_candidates(filtered_data(), ns("show_details"))
    })

    # update the show_details to zero when any of the inputs are changed
    observeEvent(
      input_change(),
      updateNumericInput(session, "show_details", value = 0),
      ignoreNULL = FALSE
    )

    # create reactive with info about selected candidate
    data_person <- reactive({
      req(input$show_details > 0)
      create_data_person(filtered_data(), input$show_details)
    }) |>
      bindEvent(input$show_details)

    # create reactive with info about selected candidate for download
    data_download <- reactive({
      req(input$show_details > 0)
      create_data_download_candidate(filtered_data(), input$show_details)
    }) |>
      bindEvent(input$show_details)

    # module with details on one candidate
    observe({
      # only show if show_details is > 0; avoid race condition of module being
      # shown when data is not yet ready
      req(input$show_details > 0)
      mod_details_server(
        "details_1",
        data_person,
        prefiltered_details
      )
    }) |>
      bindEvent(input$show_details)

    return(list(
      "data_person" = data_person,
      "data_download" = data_download
    ))
  })
}

## To be copied in the UI
# mod_results_ui("results_1")

## To be copied in the server
# mod_results_server("results_1")
