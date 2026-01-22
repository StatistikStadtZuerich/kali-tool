# script to get the latest data from ogd and save it locally
# run locally, and will be run also in the deployment pipeline
#
# when running locally: load all as well
pkgload::load_all(helpers = FALSE, attach_testthat = FALSE)

# get data and make Data Frames
data <- get_data()
df_main <- data[["df_main"]]
df_details <- data[["df_details"]]
unique_wj <- sort(unique(df_main$Wahljahr))

# Global variable, whether results to candidates are available
# if there are results for all election years -->set to 0
year_results_not_available <- data[["year_noresults"]]

usethis::use_data(df_main, df_details, unique_wj, year_results_not_available,
  overwrite = TRUE,
  internal = TRUE
)
