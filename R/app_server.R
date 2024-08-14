#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
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

  # Filter data according to inputs
  filtered_data <- reactive({
    df_main |>
      filter(Wahljahr == input$select_year) |>
      filter(if (input$suchfeld != "") grepl(input$suchfeld, Name, ignore.case = TRUE) else TRUE) |>
      filter(if (input$gender_radio_button != "Alle") Geschlecht == input$gender_radio_button else TRUE) |>
      filter(if (input$select_kreis != "Ganz Stadt") Wahlkreis == input$select_kreis else TRUE) |>
      filter(if (input$select_liste != "Alle Listen") ListeBezeichnung == input$select_liste else TRUE) |>
      filter(if (input$wahlstatus_radio_button != "Alle") Wahlresultat == input$wahlstatus_radio_button else TRUE)
  })

  # main Reactable Output
  output$table <- renderReactable({
    req(input$ActionButtonId > 0)

    table_output <- get_reactable_candidates(filtered_data())
    table_output
  })

  # Prepare data for second Output

  # update the show_details to zero when any of the inputs are changed
  observeEvent(
    eventExpr = list(
      input$suchfeld, input$select_year,
      input$gender_radio_button,
      input$select_kreis, input$select_liste,
      input$wahlstatus_radio_button
    ),
    handlerExpr = {
      updateNumericInput(session, "show_details", value = 0)
    },
    ignoreNULL = FALSE
  )

  data_person <- reactive({
    req(input$show_details > 0)

    person <- filtered_data() |>
      select(
        Name, Wahlkreis, ListeBezeichnung, Liste, Wahlresultat,
        `Anzahl Stimmen`, `Parteieigene Stimmen`,
        `Parteifremde Stimmen`,
        `Anteil Stimmen aus veränderten Listen`
      ) |>
      mutate(ID = row_number()) |>
      filter(ID == input$show_details) |>
      select(-ID)
    person
  }) |>
    bindEvent(input$show_details)

  data_download <- reactive({
    req(input$show_details > 0)
    person <- filtered_data() |>
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

  # Render title of selected person
  output$nameCandidate <- renderText({
    req(input$show_details > 0)
    paste0("<br><h2>", data_person()$Name, " (", data_person()$Liste, ")", "</h2><hr>")
  })

  # table for selected person
  output$tableCand <- renderReactable({
    req(input$show_details > 0)

    candidate_info <- data_person() |>
      select(-Name, -Wahlkreis, -ListeBezeichnung, -Liste) |>
      gather(`Detailinformationen zu den erhaltenen Stimmen`, Wert)


    table_output <- get_reactable_details(candidate_info)
    table_output
  })

  # create and send data for bar chart
  # observeEvent rather than observe to avoid race condition between sending
  # the data and setting the input$show_details/the selected row number
  observeEvent(input$show_details, {
    req(input$ActionButtonId > 0)

    if (input$show_details > 0) {
      shinyjs::show("sszvis-chart")

      person <- df_details |>
        # filter the equivalent of filtered_dat that is not also filtered below
        filter(Wahljahr == input$select_year) |>
        filter(if (input$wahlstatus_radio_button != "Alle") Wahlresultat == input$wahlstatus_radio_button else TRUE) |>
        filter(Name == data_person()$Name) |>
        filter(Wahlkreis == data_person()$Wahlkreis) |>
        filter(ListeBezeichnung == data_person()$ListeBezeichnung) |>
        select(Name, StimmeVeraeListe, Value) |>
        filter(!is.na(Value) & Value > 0) |>
        arrange(desc(Value))

      update_chart(person, "update_data", session)
    } else {
      # hide the chart (sending empty custom message does not work with iframe resizer on ssz website)
      shinyjs::hide("sszvis-chart")
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
