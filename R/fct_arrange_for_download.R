#' arrange_for_download
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd
arrange_for_download <- function(filtered_data) {
  filtered_data |>
    select(-all_of("GebJ")) |>
    mutate(BisherLang = if_else(Bisher == 1, "bisher", "neu")) |>
    rename(BisherSort = Bisher) |>
    select(all_of(c(
      "Wahljahr", "Name", "Alter", "Titel", "Beruf", "Liste", "ListeBezeichnung",
      "Wahlkreis", "WahlkreisSort", "BisherLang", "BisherSort"
    )),
    everything()) |>
    mutate(across(is.character,
                  \(x) stringi::stri_trans_general(x, "de-ASCII"))) |>
    select(-Beruf)
}
