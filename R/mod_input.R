#' input UI Function
#'
#' @description A shiny Module with all the inputs, returning the filtered data from the server
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_input_ui <- function(id) {
  ns <- NS(id)
  tagList(

    # Suchfeld: Namensuche
    sszTextInput(ns("suchfeld"), "Name"),

    # radioButtons() vertical for gender
    sszRadioButtons(ns("gender_radio_button"),
      label = "Geschlecht",
      choices = c("Alle", sort(unique(df_main$Geschlecht))),
      selected = "Alle" # default value
    ),

    # selectInput() for year of election
    sszSelectInput(ns("select_year"), "Gemeinderatswahlen",
      choices = unique_wj,
      selected = last(unique_wj)
    ),

    # selectInput() for Stadtkreis
    sszSelectInput(ns("select_kreis"), "Wahlkreis",
      choices = c(
        "Ganze Stadt", unique(df_main$Wahlkreis)
      ),
      selected = "Ganze Stadt"
    ),

    # selectInput() for party
    sszSelectInput(ns("select_liste"), "Liste",
      choices = c("Alle Listen"),
      selected = "Alle Listen"
    ),

    # radioButtons() vertical for whether the person was elected
    sszRadioButtons(ns("wahlstatus_radio_button"),
      label = "Status",
      # nicht basierend auf den Daten um die Handvoll "rückt nach" und NAs zu vermeiden
      choices = c("Alle", "gewählt", "nicht gewählt"),
      selected = "Alle"
    )
  )
}

#' input Server Functions
#'
#' @noRd
mod_input_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # update selection of lists based on selected year
    # needed as the lists do not necessarily have the same names each year
    observeEvent(input$select_year, {
      new_choices <- c(
        "Alle Listen",
        unique(df_main[df_main$Wahljahr == input$select_year, ]$ListeBezeichnung)
      )
      updateSelectInput(
        session = session,
        inputId = "select_liste",
        choices = new_choices,
        selected = new_choices[[1]]
      )
    })

    # Filter main data according to inputs
    filtered_data <- reactive({
      filter_candidates(df_main, input)
    })

    # filter detailed results data according to inputs
    df_details_prefiltered <- reactive({
      create_prefiltered_data(df_details, input$select_year, input$wahlstatus_radio_button)
    })

    # update the reactive value to indicate any of the inputs has changed
    has_changed <- reactiveVal(value = 0)
    observeEvent(
      eventExpr = list(
        input$suchfeld, input$select_year,
        input$gender_radio_button,
        input$select_kreis, input$select_liste,
        input$wahlstatus_radio_button
      ),
      handlerExpr = {
        current_val <- has_changed()
        has_changed(current_val + 1)
      },
      ignoreNULL = FALSE
    )

    return(list(
      "filtered_data" = filtered_data,
      "df_details_prefiltered" = df_details_prefiltered,
      "has_changed" = has_changed,
      # return some input values for appropriate naming of download
      "current_inputs" = list(
        "year" = reactive({ input$select_year }),
        "kreis" = reactive({ input$select_kreis }),
        "liste" = reactive({ input$select_liste })
      )

    ))
  })
}

## To be copied in the UI
# mod_input_ui("input_1")

## To be copied in the server
# mod_input_server("input_1")
