#' create_data_download_candidate
#'
#' @description Function to filter the data to get details about one candidate that can be downloaded
#'
#' @param filtered_data data frame with data filtered according to inputs; output from input module
#' @param show_details row number to be selected
#'
#' @return data frame with filtered values
#'
#' @noRd
create_data_download_candidate <- function(filtered_data, show_details) {
  filtered_data |>
    select(all_of(c(
      "Wahljahr", "Name", "Alter", "Geschlecht", "Beruf", "Wahlkreis", "Liste",
      "Wahlresultat", "Anzahl Stimmen", "Parteieigene Stimmen",
      "Parteifremde Stimmen", "Anteil Stimmen aus veränderten Listen"
    ))) |>
    slice(show_details) |>
    # change combo columns to character
    mutate(across(c("Wahlresultat", "Anzahl Stimmen", "Parteieigene Stimmen",
                    "Parteifremde Stimmen",
                    "Anteil Stimmen aus veränderten Listen"),
                  as.character)) |>
    pivot_longer(c(
      "Wahlresultat", "Anzahl Stimmen", "Parteieigene Stimmen",
      "Parteifremde Stimmen", "Anteil Stimmen aus veränderten Listen"),
      names_to = "Result der Wahl",
      values_to = "Wert"
    )
}
