library(here)
library(magrittr)
library(stringr)
library(data.table)

# ==============================================================================
# ------------------------------ update data -----------------------------------
# ==============================================================================

# update forecast data from server ---------------------------------------------
system(
  paste(". data-raw/paper.sh")
)

# get the correct file paths to all forecasts ----------------------------------
folders <- here::here("data-raw", list.files("data-raw"))
folders <- folders[
  !(grepl("\\.R", folders) | grepl(".sh", folders) | grepl(".csv", folders))
]

file_paths <- purrr::map(folders, 
                         .f = function(folder) {
                           files <- list.files(folder)
                           out <- here::here(folder, files)
                           return(out)}) %>%
  unlist()
file_paths <- file_paths[grepl(".csv", file_paths)]
file_paths <- file_paths[!(
  grepl("EpiExpert_Rt", file_paths) |
    grepl("mean_ensemble", file_paths)
)]
  
# load all past forecasts ------------------------------------------------------
# ceate a helper function to get model name from a file path
get_model_name <- function(file_path) {
  split <- str_split(file_path, pattern = "/")[[1]]
  model <- split[length(split) - 1]
  return(model)
}

prediction_data <- purrr::map_dfr(file_paths, 
                                  .f = function(file_path) {
                                    data <- data.table::fread(file_path)
                                    data[, `:=`(
                                      target_end_date = as.Date(target_end_date), 
                                      forecast_date = as.Date(forecast_date), 
                                      model = get_model_name(file_path)
                                    )]
                                    return(data)
                                  }) %>%
  dplyr::mutate(target_type = ifelse(grepl("death", target), "death", "case")) %>%
  dplyr::rename(prediction = value) %>%
  dplyr::mutate(location_name = ifelse(location == "GM", "Germany", "Poland")) %>%
  dplyr::filter(type == "quantile", 
                grepl("inc", target),
                location %in% c("GM", "PL")) %>%
  dplyr::select(location, location_name, forecast_date, quantile, prediction, model, target_end_date, target, target_type)

# change model names -----------------------------------------------------------
# helper function to change model names
change_model_name <- function(names, old_name, new_name) {
  names <- ifelse (names == old_name, new_name, names)
  return(names)
}

change_names <- list(
  c("KITCOVIDhub-median_ensemble", 
    "Hub-ensemble"), 
  c("KIT-baseline", 
    "Baseline"),
  c("epiforecasts-EpiExpert", 
    "Crowd forecast"), 
  c("epiforecasts-EpiNow2", 
    "Renewal"), 
  c("epiforecasts-EpiNow2_secondary", 
    "Convolution")
)

purrr::walk(change_names, 
            .f = function(change) {
              prediction_data[, model := ifelse(model == change[1], 
                                                change[2], 
                                                model)]
            })

usethis::use_data(prediction_data, overwrite = TRUE)

# update truth data ------------------------------------------------------------
source(here("data-raw", "update.R"))

weekly_cases <- fread(here("data-raw", "weekly-incident-cases.csv"))
weekly_cases[, target_type := "case"]
weekly_deaths <- fread(here("data-raw", "weekly-incident-deaths.csv"))
weekly_deaths[, target_type := "death"]
truth <- rbindlist(list(weekly_cases, weekly_deaths)) 
truth <- truth[location_name %in% c("Germany", "Poland")]
truth_data <- truth[, `:=` (location = NULL, epiweek = NULL, 
              target_end_date = as.Date(target_end_date))]
setnames(truth_data, old = "value", new = "true_value")

usethis::use_data(truth_data, overwrite = TRUE)

# combine data -----------------------------------------------------------------
combined_data <- merge_pred_and_obs(
  prediction_data, 
  truth_data, 
  by = c("location_name", "target_end_date", "target_type")
)[,
  forecast_date := as.character(forecast_date)
]

usethis::use_data(combined_data, overwrite = TRUE)

# define different date periods ------------------------------------------------
forecast_dates <- list()

forecast_dates[["unfiltered"]] <- c(
  seq.Date(from = as.Date("2020-10-12"), to = as.Date("2021-03-01"), "week") 
)

forecast_dates[["full_hub_period"]] <- c(
  seq.Date(from = as.Date("2020-10-12"), to = as.Date("2020-12-14"), "week"), 
  seq.Date(from = as.Date("2021-01-11"), to = as.Date("2021-03-01"), "week") 
)
  
forecast_dates[["cases"]] <- 
  forecast_dates$unfiltered[
    !(forecast_dates$unfiltered %in% c("2020-12-21", "2020-12-28"))
  ]

forecast_dates[["first_period"]] <- 
  forecast_dates$cases[as.Date(forecast_dates$cases) <= "2020-12-19"]

forecast_dates[["second_period"]] <- 
  forecast_dates$cases[as.Date(forecast_dates$cases) >= "2021-01-04"]

forecast_dates[["deaths"]] <- 
  forecast_dates$cases[as.Date(forecast_dates$cases) >= "2020-12-07"]

usethis::use_data(forecast_dates, overwrite = TRUE)
