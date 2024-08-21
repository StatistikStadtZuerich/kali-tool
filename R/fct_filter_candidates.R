#' filter candidates
#'
#' @description function to filter the candidates according to the inputs
#'
#' @param df_main data frame with all candidates (package data)
#' @param input_values list of values for filtering
#'
#' @return dataframe with filtered data
#'
#' @noRd
filter_candidates <- function(df_main, input_values) {
  df_main |>
    filter(.data[["Wahljahr"]] == input_values$select_year) |>
    filter(if (input_values$suchfeld != "") {
      grepl(input_values$suchfeld, .data[["Name"]], ignore.case = TRUE)
    } else {
      TRUE
    }) |>
    filter(if (input_values$gender_radio_button != "Alle") {
      .data[["Geschlecht"]] == input_values$gender_radio_button
    } else {
      TRUE
    }) |>
    filter(if (input_values$select_kreis != "Ganze Stadt") {
      .data[["Wahlkreis"]] == input_values$select_kreis
    } else {
      TRUE
    }) |>
    filter(if (input_values$select_liste != "Alle Listen") {
      .data[["ListeBezeichnung"]] == input_values$select_liste
    } else {
      TRUE
    }) |>
    filter(if (input_values$wahlstatus_radio_button != "Alle") {
      .data[["Wahlresultat"]] == input_values$wahlstatus_radio_button
    } else {
      TRUE
    })
}
