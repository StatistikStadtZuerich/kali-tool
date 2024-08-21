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
          mod_input_ui("input_module"),
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
            condition = "input.show_details > 0",
            h3("Detailinformationen herunterladen"),

            mod_download_ui("download_1", ssz_icons)
          )
        ),

        # Mail Panel: Outputs are placed here
        mainPanel(
          conditionalPanel(
            condition = "input.ActionButtonId>0",
            mod_results_ui("results_1"),
            conditionalPanel(
              condition = "input.show_details > 0",
              mod_details_ui("details_1")
            )
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
  )
}
