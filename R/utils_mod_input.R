#' mod_input
#'
#' @description A utils function
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd
filter_candidates <- function(df_main, input_values) {
  df_main |>
    filter(Wahljahr == input_values$select_year) |>
    filter(if (input_values$suchfeld != "") {
      grepl(input_values$suchfeld, Name, ignore.case = TRUE)
      } else TRUE) |>
    filter(if (input_values$gender_radio_button != "Alle") {
      Geschlecht == input_values$gender_radio_button
      } else TRUE) |>
    filter(if (input_values$select_kreis != "Ganze Stadt") {
      Wahlkreis == input_values$select_kreis
      } else TRUE) |>
    filter(if (input_values$select_liste != "Alle Listen") {
      ListeBezeichnung == input_values$select_liste
      } else TRUE) |>
    filter(if (input_values$wahlstatus_radio_button != "Alle") {
      Wahlresultat == input_values$wahlstatus_radio_button
      } else TRUE)
}
