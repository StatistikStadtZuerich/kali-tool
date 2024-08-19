#' create_prefiltered_data
#'
#' @description function to partially pre-filter the data for the detailed view
#'
#' @param df_details tibble on details, package data
#' @param year year to be filtered
#' @param wahlstatus wahlstatus, corresponds to input$wahlstatus_radio_button
#'
#' @return filtered tibble
#'
#' @noRd
create_prefiltered_data <- function(df_details, year, wahlstatus) {
  df_details |>
    filter(.data[["Wahljahr"]] == year) |>
    filter(if (wahlstatus != "Alle") {
      .data[["Wahlresultat"]] == wahlstatus
    } else {
      TRUE
    })
}
