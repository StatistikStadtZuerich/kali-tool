#' create_details_reactable
#'
#' @description function to generate the reactable for the details about the candidate
#'
#' @param data_person appropriately filtered data for one candidate
#'
#' @return a reactable
#'
#' @noRd
create_details_reactable <- function(data_person) {
  data_person |>
    select(-all_of(c("Name", "Wahlkreis", "ListeBezeichnung", "Liste"))) |>
    gather(`Detailinformationen zu den erhaltenen Stimmen`, Wert) |>
    reactable(paginationType = "simple",
              theme = reactableTheme(
                borderColor = "#DEDEDE"
              ),
              defaultColDef = colDef(
                align = "left",
                minWidth = 50
              ),
              outlined = TRUE,
              highlight = TRUE
    )
}
