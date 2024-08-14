#' input UI Function
#'
#' @description A shiny Module.
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
      choices = c("Alle", "Männlich", "Weiblich"),
      selected = "Alle" # default value
    ),

    # selectInput() for year of election
    sszSelectInput(ns("select_year"), "Gemeinderatswahlen",
      choices = unique_wj,
      selected = unique_wj[[length(unique_wj)]]
    ),

    # selectInput() for Stadtkreis
    sszSelectInput(ns("select_kreis"), "Wahlkreis",
      choices = c(
        "Ganz Stadt", "Kreis 1 + 2", "Kreis 3",
        "Kreis 4 + 5", "Kreis 6", "Kreis 7 + 8",
        "Kreis 9", "Kreis 10", "Kreis 11",
        "Kreis 12"
      ),
      selected = "Ganz Stadt"
    ),

    # selectInput() for party
    sszSelectInput(ns("select_liste"), "Liste",
      choices = c("Alle Listen"),
      selected = "Alle Listen"
    ),

    # radioButtons() vertical for whether the person was elected
    sszRadioButtons(ns("wahlstatus_radio_button"),
      label = "Status",
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
      df_main |>
        filter(Wahljahr == input$select_year) |>
        filter(if (input$suchfeld != "") grepl(input$suchfeld, Name, ignore.case = TRUE) else TRUE) |>
        filter(if (input$gender_radio_button != "Alle") Geschlecht == input$gender_radio_button else TRUE) |>
        filter(if (input$select_kreis != "Ganz Stadt") Wahlkreis == input$select_kreis else TRUE) |>
        filter(if (input$select_liste != "Alle Listen") ListeBezeichnung == input$select_liste else TRUE) |>
        filter(if (input$wahlstatus_radio_button != "Alle") Wahlresultat == input$wahlstatus_radio_button else TRUE)
    })

    # filter detailed results data according to inputs
    df_details_prefiltered <- reactive({
      df_details |>
        # filter the equivalent of filtered_dat that is not also filtered below
        filter(Wahljahr == input$select_year) |>
        filter(if (input$wahlstatus_radio_button != "Alle") Wahlresultat == input$wahlstatus_radio_button else TRUE)
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
      "has_changed" = has_changed
    ))
  })
}

## To be copied in the UI
# mod_input_ui("input_1")

## To be copied in the server
# mod_input_server("input_1")
