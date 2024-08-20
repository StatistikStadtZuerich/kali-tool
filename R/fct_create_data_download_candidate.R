#' create_data_download_candidate
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd
create_data_download_candidate <- function(filtered_data) {
  filtered_data |>
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
}
