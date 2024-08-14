# todos has
# - run styler

#' get_data
#'
#' @description Function to get the necessary data from the OGD portal.
#'
#'
#' @return a list of two tibbles: df_main and df_details
#' @export
#'
#' @examples
#' data <- get_data()
get_data <- function() {
  # get parameters for data load (years, urls)
  params <- get_params_data_load()

  # Candidates: Download, rename and wrangle as required
  data_cand <- furrr::future_map2_dfr(params[["URLs_cand"]], params[["years"]], data_download) |>
    wrangle_candidates()

  # Results: download and wrangle
  df_details <- furrr::future_map2(params[["URLs_result"]], params[["years"]], data_download) |>
    # data wrangling step (includes correction for 2010 special names)
    furrr::future_map(wrangle_data_results) |>
    # combine into one df
    purrr::list_rbind()

  # to avoid duplicates in main table, just select a subset to join
  df_details_for_join <- df_details |>
    select(all_of(c(
      "Name", "Wahljahr", "Wahlkreis", "ListeBezeichnung", "Wahlresultat",
      "Anzahl Stimmen", "Parteieigene Stimmen",
      "Parteifremde Stimmen",
      "Anteil Stimmen aus veränderten Listen"
    ))) |>
    unique()

  # join candidates and results
  df_main <- data_cand |>
    left_join(df_details_for_join, by = c(
      "Wahljahr",
      "Name",
      "Wahlkreis",
      "ListeBezeichnung"
    )) |>
    mutate(WahlkreisSort = case_when(
      Wahlkreis == "Kreis 1 + 2" ~ 1,
      Wahlkreis == "Kreis 3" ~ 2,
      Wahlkreis == "Kreis 4 + 5" ~ 3,
      Wahlkreis == "Kreis 6" ~ 4,
      Wahlkreis == "Kreis 7 + 8" ~ 5,
      Wahlkreis == "Kreis 9" ~ 6,
      Wahlkreis == "Kreis 10" ~ 7,
      Wahlkreis == "Kreis 11" ~ 8,
      Wahlkreis == "Kreis 12" ~ 9
    )) |>
    arrange(across(all_of(c("Wahljahr", "WahlkreisSort")))) |>
    mutate(Alter = .data[["Wahljahr"]] - .data[["GebJ"]]) |>
    rename(Liste = .data[["ListeKurzbez"]])

  # with updated data (2026): check if this joined df has NA, in that case
  # there is probably a mismatch in names or someone missing
  # currently known missing results: Jürg Nef, EVP, 2018

  return(list("df_main" = df_main, "df_details" = df_details))
}
