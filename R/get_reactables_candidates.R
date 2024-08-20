#' get_reactable_candidates
#'
#' @description function to generate the main table with a list of candidates
#'
#' @param df filtered data to be shown
#' @param name_of_row_var correctly namespaced name for the input variable to be set with click
#'
#' @return a reactable
get_reactable_candidates <- function(df, name_of_row_var) {
  reactable(
    df |>
      select(Name, Alter, Geschlecht, Beruf, Wahlkreis, Liste) |>
      unique(),
    paginationType = "simple",
    language = reactableLang(
      noData = "Keine Einträge gefunden",
      pageNumbers = "{page} von {pages}",
      pageInfo = "{rowStart} bis {rowEnd} von {rows} Einträgen",
      pagePrevious = "\u276e",
      pageNext = "\u276f",
      pagePreviousLabel = "Vorherige Seite",
      pageNextLabel = "Nächste Seite"
    ),
    theme = reactableTheme(
      borderColor = "#DEDEDE"
    ),
    defaultColDef = colDef(
      align = "left",
      minWidth = 50
    ),
    outlined = TRUE,
    highlight = TRUE,
    onClick = JS(
      # Send the click event to Shiny, which will be available in input$show_details
      # Note that the row index starts at 0 in JavaScript, so we add 1
      paste0("function(rowInfo, column) {
            if (window.Shiny) {
            Shiny.setInputValue('", name_of_row_var, ":shiny.number', rowInfo.index + 1, { priority: 'event' })
            }
            }"))
  )
}
