#' create_data_person
#'
#' @description function to create the data about one candidate
#'
#' @param filtered_data data that is shown in the main table, output from input module
#' @param show_details integer representing the row number of the candidate§ to be selected
#' @return data.frame with just data on one candidate
#'
#' @noRd
create_data_person <- function(filtered_data, show_details) {
  filtered_data |>
    select(all_of(c(
      "Name", "Wahlkreis", "ListeBezeichnung", "Liste", "Wahlresultat",
      "Anzahl Stimmen", "Parteieigene Stimmen", "Parteifremde Stimmen",
      "Anteil Stimmen aus veränderten Listen"
    ))) |>
    slice(show_details)
}
