#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  # Set the Icon path
  ssz_icons <- icon_set("inst/app/www/icons/")

  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),

    # Your application UI logic
    add_kali_devs(fluidPage(
      # Sidebar: Input widgets are placed here
      sidebarLayout(
        sidebarPanel(

          # Suchfeld: Namensuche
          sszTextInput("suchfeld", "Name"),


          # radioButtons() vertical for gender
          sszRadioButtons("gender_radio_button",
            label = "Geschlecht",
            choices = c("Alle", "Männlich", "Weiblich"),
            selected = "Alle" # default value
          ),

          # selectInput() for year of election
          sszSelectInput("select_year", "Gemeinderatswahlen",
            choices = unique_wj,
            selected = unique_wj[[length(unique_wj)]]
          ),

          # selectInput() for Stadtkreis
          sszSelectInput("select_kreis", "Wahlkreis",
            choices = c(
              "Ganz Stadt", "Kreis 1 + 2", "Kreis 3",
              "Kreis 4 + 5", "Kreis 6", "Kreis 7 + 8",
              "Kreis 9", "Kreis 10", "Kreis 11",
              "Kreis 12"
            ),
            selected = "Ganz Stadt"
          ),


          # selectInput() for party
          sszSelectInput("select_liste", "Liste",
            choices = c("Alle Listen"),
            selected = "Alle Listen"
          ),

          # radioButtons() vertical for whether the person was elected
          sszRadioButtons("wahlstatus_radio_button",
            label = "Status",
            choices = c("Alle", "gewählt", "nicht gewählt"),
            selected = "Alle"
          ),

          # Action Button to start the query and show the resulting table
          conditionalPanel(
            condition = "input.ActionButtonId==0",
            sszActionButton(
              "ActionButtonId",
              "Abfrage starten"
            )
          ),

          # Downloads - only show these when one person is selected to
          # download details about this person
          conditionalPanel(
            condition = "output.tableCand",
            h3("Detailinformationen herunterladen"),

            # Download Panel
            tags$div(
              id = "downloadWrapperId",
              class = "downloadWrapperDiv",
              sszDownloadButton(
                outputId = "csvDownload",
                label = "csv",
                image = img(ssz_icons$download)
              ),
              sszDownloadButton(
                outputId = "excelDownload",
                label = "xlsx",
                image = img(ssz_icons$download)
              ),
              sszOgdDownload(
                outputId = "ogdDown",
                label = "OGD",
                image = img(ssz_icons("link")),
                href = "https://data.stadt-zuerich.ch/dataset?q=Kandidierende&sort=score+desc%2C+date_last_modified+desc"
              )
            )
          )
        ),


        # Mail Panel: Outputs are placed here
        mainPanel(
          conditionalPanel(
            condition = "input.ActionButtonId>0",

            # Title for table
            h1("Die untenstehenden Kandidierenden entsprechen Ihren Suchkriterien"),
            hr(),
            # Define subtitle
            p("Für Detailinformationen zu den Ergebnissen einzelner Kandidierenden wählen Sie eine Zeile aus."),

            # Example Table Output
            shinycssloaders::withSpinner(
              reactableOutput("table"),
              type = 7,
              color = "#0F05A0"
            ),
          ),

          # initialise hidden variable for row selection, to be used with JS function in reactable
          conditionalPanel(
            "false",
            numericInput(
              label = NULL,
              inputId = "show_details",
              value = 0
            )
          ),

          # Name of selected candidate - requires show_details > 0
          htmlOutput("nameCandidate"),

          # table with info about selected candidate - requires show_details > 0
          shinycssloaders::withSpinner(
            reactableOutput("tableCand"),
            type = 7,
            color = "#0F05A0"
          ),

          # Only show plot if tableCand is also shown
          conditionalPanel(
            condition = "output.tableCand",

            # Name of selected candidate
            # Title for table
            hr(),
            h4("Stimmen aus veränderten Listen"),
          ),

          # Chart container; can't be used in a conditional panel as when the
          # update_data function is called, the UI is not ready yet when JS tries
          # to target container id.
          # ID must be "sszvis-chart", as this is what the JS is looking to fill
          div(id = "sszvis-chart")
        )
      )
    ))
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "KALI"
    ),
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
    shinyjs::useShinyjs(debug = TRUE)
  )
}
