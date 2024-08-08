# script to get the latest data from ogd and save it locally
# run locally, and will be run also in the deployment pipeline
#
# when running locally: load all as well
# devtools::load_all()

# get data and make Data Frames
data <- get_data()
df_main <- data[["df_main"]]
df_details <- data[["df_details"]]
unique_wj <- sort(unique(df_main$Wahljahr))

usethis::use_data(df_main, df_details, unique_wj,
                  overwrite = TRUE,
                  internal = TRUE)
