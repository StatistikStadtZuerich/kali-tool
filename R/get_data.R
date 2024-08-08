# todos has
# - write test to check the data is still the same (snapshot?) (functions now work but results not checked)
# - document all functions including utils
# - run styler
# - put all wrangling in a separate function

get_data <- function() {
  ### Candidates
  params <- get_params_data_load()


  ## Download and Rename and wrangle as required
  data_cand <- furrr::future_map2_dfr(params[["URLs_cand"]], params[["years"]], data_download) |>
    mutate(G = case_when(
      G == "M" ~ "Männlich",
      G == "W" ~ "Weiblich"
    )) |>
    rename(Geschlecht = G) |>
    mutate(
      ListeBezeichnung = trimws(ListeBezeichnung),
      Vorname = trimws(Vorname),
      Nachname = trimws(Nachname),
      Wahlkreis = trimws(Wahlkreis)
    ) |>
    select(-A, -Kand, -Liste) |>
    mutate(
      Name = paste(Vorname, Nachname, sep = " "),
      Wahlkreis = paste("Kreis", Wahlkreis, sep = " ")
    ) |>
    select(-Vorname, -Nachname)

  ### Results
  

  # parallelised download for results
  df_details <- furrr::future_map2(params[["URLs_result"]], params[["years"]], data_download) |> 
    # data wrangling step (includes correction for 2010 special names)
    furrr::future_map(data_wrangle) |> 
    # combine into one df
    purrr::list_rbind()

  ### Data Manipulation

  # to avoid duplicates in main table, just select a subset to join
  df_details_for_join <- df_details |>
    select(
      Name, Wahljahr, Wahlkreis, ListeBezeichnung, Wahlresultat,
      `Anzahl Stimmen`, `Parteieigene Stimmen`,
      `Parteifremde Stimmen`,
      `Anteil Stimmen aus veränderten Listen`
    ) |>
    unique()

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
    arrange(Wahljahr, WahlkreisSort) |>
    mutate(Alter = Wahljahr - GebJ) |>
    rename(Liste = ListeKurzbez)

  # with updated data (2026): check if this joined df has NA, in that case
  # there is probably a mismatch in names or someone missing
  # currently known missing results: Jürg Nef, EVP, 2018

  return(list("df_main" = df_main, "df_details" = df_details))
}
