#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  filtered_input <- mod_input_server("input_module")

  # main Reactable Output
  output$table <- renderReactable({
    req(input$ActionButtonId > 0)

    table_output <- get_reactable_candidates(filtered_input$filtered_data())
    table_output
  })

  # Prepare data for second Output

  # update the show_details to zero when any of the inputs are changed
  observeEvent(
    filtered_input$has_changed(),
    updateNumericInput(session, "show_details", value = 0),
    ignoreNULL = FALSE
  )

  data_person <- reactive({
    req(input$show_details > 0)
    create_data_person(filtered_input$filtered_data(), input$show_details)
  }) |>
    bindEvent(input$show_details)

  data_download <- reactive({
    req(input$show_details > 0)
    person <- filtered_input$filtered_data() |>
      select(
        Wahljahr, Name, Alter, Geschlecht, Beruf, Wahlkreis, Liste,
        Wahlresultat, `Anzahl Stimmen`, `Parteieigene Stimmen`,
        `Parteifremde Stimmen`,
        `Anteil Stimmen aus veränderten Listen`
      ) |>
      mutate(ID = row_number()) |>
      filter(ID == input$show_details) |>
      select(-ID) |>
      gather(
        `Result der Wahl`, Wert, -Wahljahr, -Name, -Alter,
        -Geschlecht, -Beruf, -Wahlkreis, -Liste
      )
    person
  }) |>
    bindEvent(input$show_details)

  # create and send data for bar chart
  # observeEvent rather than observe to avoid race condition between sending
  # the data and setting the input$show_details/the selected row number
  mod_details_server("details_1", data_person, filtered_input$df_details_prefiltered)
  observeEvent(input$show_details, {
    req(input$ActionButtonId > 0)

    if (input$show_details > 0) {
      shinyjs::show("details_1")
    } else {
      # hide the chart (sending empty custom message does not work with iframe resizer on ssz website)
      shinyjs::hide("details_1")
    }
  })

  ## Write Download Table
  # CSV
  output$csvDownload <- downloadHandler(
    filename = function(vote) {
      suchfeld <- gsub(" ", "-", data_person()$Name, fixed = TRUE)
      paste0("Gemeinderatswahlen_", input$select_year, "_", suchfeld, ".csv")
    },
    content = function(file) {
      write.csv(data_download(), file, fileEncoding = "UTF-8", row.names = FALSE, na = " ")
    }
  )

  # Excel
  output$excelDownload <- downloadHandler(
    filename = function(vote) {
      suchfeld <- gsub(" ", "-", data_person()$Name, fixed = TRUE)
      paste0("Gemeinderatswahlen_", input$select_year, "_", suchfeld, ".xlsx")
    },
    content = function(file) {
      ssz_download_excel(data_download(), file, data_person()$Name)
    }
  )
}
