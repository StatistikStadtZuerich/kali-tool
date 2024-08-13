#' get_params_data_load
#'
#' @description A utils function: the place where hardcoded things like links and years are set. No other function should need modification with the addition of another year if the structure remains the same.
#'
#' @return a list with a vector of years, a vector of links to the candidate datasets, and a vector of links to the result datasets
#'
#' @noRd
get_params_data_load <- function() {
  # Years
  years <- c(2022, 2018, 2014, 2010)

  # URLs for all the candidates
  URLs_cand <- c(
    "https://data.stadt-zuerich.ch/dataset/politik_gemeinderatswahlen_2022_kandidierende/download/gemeinderatswahlen_2022_kandidierende.csv",
    "https://data.stadt-zuerich.ch/dataset/politik_gemeinderatswahlen_2018_kandidierende/download/gemeinderatswahlen_2018_kandidierende.csv",
    "https://data.stadt-zuerich.ch/dataset/politik-gemeinderatswahlen-2014-alle-kandidierenden/download/GRW-2014-alle-Kandidierenden-OGD.csv",
    "https://data.stadt-zuerich.ch/dataset/politik_gemeinderatswahlen_2010_kandidierende/download/gemeinderatswahlen_2010_kandidierende.csv"
  )

  # URLs for the results
  URLs_result <- c(
    "https://data.stadt-zuerich.ch/dataset/politik_gemeinderatswahlen_2022_resultate/download/GRW_2022_resultate_kandidierende_und_herkunft_der_stimmen.csv",
    "https://data.stadt-zuerich.ch/dataset/politik_gemeinderatswahlen_2018_resultate/download/GRW_2018_resultate_und_herkunft_der_stimmen.csv",
    "https://data.stadt-zuerich.ch/dataset/politik-gemeinderatswahlen-2014-resultate/download/GRW_2014_Resultate_und_Herkunft_der_Stimmen_Nachzahlung_v2.csv",
    "https://data.stadt-zuerich.ch/dataset/politik_gemeinderatswahlen_2010_resultate/download/GRW_2010_resultate_kandidierende_und_herkunft_der_stimmen.csv"
  )

  # todo has in tests: check 3 results, check they are equally long

  return(list(
    "years" = years,
    "URLs_cand" = URLs_cand,
    "URLs_result" = URLs_result
  ))
}

#' data_download
#' @description Function to download the data from Open Data Zürich
#'
#' @param link URL to the csv
#' @param year integer year to be added in an additional column
#'
#' @return tibble, downloaded from link plus "Wahljahr" column added
#' @noRd
data_download <- function(link, year) {
  data <- data.table::fread(link, encoding = "UTF-8") |>
    mutate(Wahljahr = year)
}

# Function to make data long to wide, and wrangle data
#' wrangle_data_results_per_year
#'
#' data wrangling for results for one year
#'
#' @param data tibble with results data
#'
#' @return wrangled results tibble
#' @noRd
wrangle_data_results_per_year <- function(data) {
  data |>
    select(
      Wahljahr, Liste_Bez_lang, Wahlkreis, Nachname, Vorname,
      Wahlresultat, total_stim, starts_with("part"), starts_with("stim")
    ) |>
    gather(
      Var, Value, -Wahljahr, -Liste_Bez_lang, -Wahlkreis, -Nachname,
      -Vorname, -Wahlresultat, -total_stim, -starts_with("part")
    ) |>
    mutate(Value = as.numeric(Value)) |>
    rename(ListeBezeichnung = Liste_Bez_lang) |>
    mutate(StimmeVeraeListe = str_remove_all(Var, "stim_verae_wl_")) |>
    mutate(Wahlresultat = stringr::str_replace(Wahlresultat, "ae", "ä")) |>
    mutate(
      ListeBezeichnung = trimws(ListeBezeichnung),
      Vorname = trimws(Vorname),
      Nachname = trimws(Nachname),
      Wahlkreis = trimws(Wahlkreis)
    ) |>
    mutate(
      Name = paste(Vorname, Nachname, sep = " "),
      Wahlkreis = paste("Kreis", Wahlkreis, sep = " ")
    ) |>
    select(-Vorname, -Nachname) |>
    mutate(StimmeVeraeListe = case_when(
      StimmeVeraeListe == "Gruene" ~ "Grüne",
      StimmeVeraeListe == "evp_bdp" ~ "EVP/BDP",
      StimmeVeraeListe == "DieMitte" ~ "Die Mitte",
      StimmeVeraeListe == "ILoveZH" ~ "I Love ZH",
      TRUE ~ StimmeVeraeListe
    )) |>
    mutate(
      `Anteil Stimmen aus veränderten Listen` = as.character(
        round(100 * (1 - (part_eig_stim_unv_wl / total_stim)), 1)
      )
    ) |>
    mutate(
      `Anteil Stimmen aus veränderten Listen` = paste(`Anteil Stimmen aus veränderten Listen`,
                                                      "%",
                                                      sep = " "
      )
    ) |>
    rename(
      `Anzahl Stimmen` = total_stim,
      `Parteieigene Stimmen` = part_eig_stim,
      `Parteifremde Stimmen` = part_frmd_stim
    )
}

#' wrangle_data_results
#'
#' @description wrapper around wrangle_data_results_per_year to deal with
#' correction for 2010
#'
#'
#' @param df tibble of results from one year
#'
#' @return wrangled data, for 2010 incl. correction
#' @noRd
wrangle_data_results <- function(df) {

  # no modification required for data later than 2010
  if (unique(df["Wahljahr"]) > 2010) {
    return(wrangle_data_results_per_year(df))
  }

  # for 2010, rename and mutate
  df |>
    rename(Liste_Bez_lang = Liste, Wahlresultat = Wahlergebnis) |>
    wrangle_data_results_per_year() |>
    mutate(ListeBezeichnung = gsub(".*– ", "", ListeBezeichnung))

}
