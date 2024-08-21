#' create_data_for_chart
#'
#' @description creates data for d3 chart
#'
#' @param df_prefiltered pre-filtered data, output from input module
#' @param data_person details filtered to particular candidate
#'
#' @return a data.frame
#'
#' @noRd
create_data_for_chart <- function(df_prefiltered, data_person) {
  df_prefiltered |>
    filter(
      .data[["Name"]] == data_person$Name,
      .data[["Wahlkreis"]] == data_person$Wahlkreis,
      .data[["ListeBezeichnung"]] == data_person$ListeBezeichnung
    ) |>
    select(all_of(c("Name", "StimmeVeraeListe", "Value"))) |>
    filter(!is.na(Value) & Value > 0) |>
    arrange(desc(Value))
}
