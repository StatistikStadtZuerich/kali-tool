#' arrange_for_download
#'
#' @description Function to arrange the data for download
#'
#' @return rearranged data frame
#'
#' @noRd
arrange_for_download <- function(filtered_data, output_target = c("csv", "xlsx")) {
  rlang::arg_match(output_target)

  pre_arranged <- filtered_data |>
    select(-all_of("GebJ")) |>
    mutate(BisherLang = if_else(Bisher == 1, "bisher", "neu")) |>
    rename(BisherSort = Bisher,
           `Liste Bezeichnung` = ListeBezeichnung) |>
    select(
      all_of(c(
        "Wahljahr", "Name", "Alter", "Titel", "Beruf", "Liste", "Liste Bezeichnung",
        "Wahlkreis", "WahlkreisSort", "BisherLang", "BisherSort"
      )),
      everything()
    )

  if (output_target == "csv") {
    # for csv, remove spaces from column names
    return(pre_arranged |> rename_with(\(x) stringr::str_remove_all(x, " ")))
  } else if (output_target == "xlsx") {
    # for excel, remove "Beruf" as string encoding corrupts excel file
    return(pre_arranged |>
             select(-Beruf, -contains("Sort")))
  }

  # stuff I have tried to make the excel work
  #|>
  # did not manage to convert the "Beruf" to valid strings that can be opened in excel
  # rowwise() |>
  # mutate(Beruf = rawToChar(charToRaw(Beruf)))
  # mutate(Beruf = str_replace(Beruf, "\\&", ","),
  #        Beruf = str_replace(Beruf, "[:symbol:]", ""))
  # mutate(across(is.character,
  #               \(x) stringi::stri_trans_general(x, "Latin-ASCII")))
  # mutate(Beruf = enc2utf8(Beruf))
}
