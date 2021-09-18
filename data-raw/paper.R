library(here)
library(magrittr)
library(stringr)
library(data.table)
library(scoringutils)

# ==============================================================================
# ------------------------------ update data -----------------------------------
# ==============================================================================

# update forecast data from server ---------------------------------------------
# system(
#   paste(". data-raw/paper.sh")
# )

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
file_paths <- file_paths[!(grepl("EpiExpert_Rt", file_paths)) & 
                           !(grepl("included_models", file_paths))]
  
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
    "Hub-ensemble-realised"), 
  c("KITCOVIDhub-mean_ensemble", 
    "Hub-ensemble-realised-mean"), 
  
  c("KIT-baseline", 
    "Baseline"),
  c("epiforecasts-EpiExpert", 
    "Crowd forecast"), 
  c("epiforecasts-EpiNow2", 
    "Renewal"), 
  c("epiforecasts-EpiNow2-retrospective", 
    "Renewal-retrospective"), 
  c("epiforecasts-EpiNow2_secondary", 
    "Convolution"), 
  c("epiforecasts-EpiNow2_secondary-retrospective", 
    "Convolution-retrospective"),
  
  c("KITCOVIDhub-median_ensemble_exclude_both", 
    "Hub-ensemble"), 
  c("KITCOVIDhub-mean_ensemble_exclude_both", 
    "Hub-ensemble-mean"), 
  
  c("KITCOVIDhub-median_ensemble_exclude_EpiExpert", 
    "Hub-ensemble-with-renewal"), 
  c("KITCOVIDhub-mean_ensemble_exclude_EpiExpert", 
    "Hub-ensemble-with-renewal-mean"), 
  
  c("KITCOVIDhub-median_ensemble_exclude_EpiNow2", 
    "Hub-ensemble-with-crowd"), 
  c("KITCOVIDhub-mean_ensemble_exclude_EpiNow2", 
    "Hub-ensemble-with-crowd-mean"), 
  
  c("KITCOVIDhub-median_ensemble_include_EpiNow2_secondary_additionally", 
    "Hub-ensemble-with-all"), 
  c("KITCOVIDhub-mean_ensemble_include_EpiNow2_secondary_additionally", 
    "Hub-ensemble-with-all-mean"), 
  
  
  c("KITCOVIDhub-median_ensemble_include_only_EpiNow2_secondary", 
    "Hub-ensemble-with-convolution"), 
  c("KITCOVIDhub-mean_ensemble_include_only_EpiNow2_secondary", 
    "Hub-ensemble-with-convolution-mean")
) %>%
  # not sure why this is not unique?
  unique()

purrr::walk(change_names, 
            .f = function(change) {
              prediction_data[, model := ifelse(model == change[1], 
                                                change[2], 
                                                model)]
            })

usethis::use_data(prediction_data, overwrite = TRUE)


# store names of regular models and ensemble models ----------------------------
regular_models <- c("Renewal", "Hub-ensemble", "Crowd forecast", "Convolution")
usethis::use_data(regular_models, overwrite = TRUE)

ensemble_models <- unique(prediction_data$model)
ensemble_models <- ensemble_models[grepl("ensemble", ensemble_models)]
usethis::use_data(ensemble_models, overwrite = TRUE)

# update truth data ------------------------------------------------------------
# source(here("data-raw", "update.R"))

# weekly truth data
weekly_cases <- fread(here("data-raw", "weekly-incident-cases.csv"))
weekly_cases[, target_type := "case"]
weekly_deaths <- fread(here("data-raw", "weekly-incident-deaths.csv"))
weekly_deaths[, target_type := "death"]
truth <- rbindlist(list(weekly_cases, weekly_deaths)) 
truth <- truth[location_name %in% c("Germany", "Poland")]
truth_data <- truth[, `:=` (location = NULL, 
              target_end_date = as.Date(target_end_date))]
setnames(truth_data, old = "value", new = "true_value")

usethis::use_data(truth_data, overwrite = TRUE)

# daily truth data
daily_cases <- fread(here("data-raw", "daily-incidence-cases.csv"))
daily_cases[, target_type := "case"]
daily_deaths <- fread(here("data-raw", "daily-incidence-deaths.csv"))
daily_deaths[, target_type := "death"]
dailytruth <- rbindlist(list(daily_cases, daily_deaths)) 
dailytruth <- dailytruth[location_name %in% c("Germany", "Poland")]
dailytruth_data <- dailytruth[, `:=` (location = NULL,
                                      target_end_date = as.Date(date))]
setnames(dailytruth_data, old = "value", new = "true_value")

usethis::use_data(dailytruth_data, overwrite = TRUE)


# combine raw data and store ---------------------------------------------------
combined_data <- merge_pred_and_obs(
  prediction_data, 
  truth_data, 
  by = c("location_name", "target_end_date", "target_type")
)[,
  forecast_date := as.character(forecast_date)
]

usethis::use_data(combined_data, overwrite = TRUE)


# update data about the number of ensembles included in the Hub ----------------
root_dir <- here("data-raw", "included_models")
filenames <- list.files(root_dir)
get_date <- function(filename) {
  date <- substr(filename, 17, 26)
  return(as.Date(date))
}
dates <- get_date(filenames)
filenames <- filenames[dates >= "2020-10-12" & dates <= "2021-03-01"]

ensemble_members <- purrr::map_dfr(filenames, 
                                   .f = function(x) {
                                     dt <- fread(here(root_dir, x))
                                     dt[, Date := get_date(x)]
                                     return(dt)
                                   })

del_cols <- names(ensemble_members)[grepl("XX", names(ensemble_members)) | 
                                      grepl("cum", names(ensemble_members))]
ensemble_members[, (del_cols) := NULL]

usethis::use_data(ensemble_members, overwrite = TRUE)


# ==============================================================================
# -------------------- filter data and perform stratification ------------------
# ==============================================================================

# define different date periods relevant for the paper--------------------------
forecast_dates <- list()

# all unfiltered dates
forecast_dates[["unfiltered"]] <- c(
  seq.Date(from = as.Date("2020-10-12"), to = as.Date("2021-03-01"), "week") 
)

# all dates relevant to the hubs
forecast_dates[["full_hub_period"]] <- c(
  seq.Date(from = as.Date("2020-10-12"), to = as.Date("2020-12-14"), "week"), 
  seq.Date(from = as.Date("2021-01-11"), to = as.Date("2021-03-01"), "week") 
)
  
# first period in the Hub paper
forecast_dates[["first_period"]] <- 
  forecast_dates$cases[as.Date(forecast_dates$cases) <= "2020-12-19"]

# second period in the hub paper
forecast_dates[["second_period"]] <- 
  forecast_dates$cases[as.Date(forecast_dates$cases) >= "2021-01-04"]

# christmas period
forecast_dates[["christmas"]] <- 
  seq.Date(as.Date("2020-12-19"), as.Date("2021-01-07"), "week")

# dates not scored for death forecasts
forecast_dates[["death_not_scored"]] <- 
  forecast_dates$unfiltered[as.Date(forecast_dates$unfiltered) < "2020-12-14"]

# forecast_dates[["cases"]] <- 
#   forecast_dates$unfiltered[
#     !(forecast_dates$unfiltered %in% c("2020-12-21", "2020-12-28"))
#   ]
# 
# forecast_dates[["deaths"]] <- 
#   forecast_dates$cases[as.Date(forecast_dates$cases) >= "2020-12-14"]

usethis::use_data(forecast_dates, overwrite = TRUE)

# classify epidemic into rising and falling ------------------------------------
# classify epidemic according to whether, on a given forecast date, the two
# weeks before that have seen monotonic rise, decline, or an unclear trend
classify_epidemic <- function(data, cutoff = 0.05, growth_cutoff = 2) {
  dt <- as.data.table(data)
  
  # calculate differences and set differences smaller than 
  # a certain cutoff to zero
  dt[, diff_1 := c(NA, diff(true_value, 1)), 
     by = c("location_name", "target_type")]
  dt[abs(diff_1) < (cutoff * true_value), diff_1 := 0]
  dt[, diff_prev := c(shift(diff_1, 1)), 
     by = c("location_name", "target_type")]
  
  # assign a label depending on observed differences
  dt[, c("classification", "speed") := "unclear"]
  dt[(diff_1 >= 0 & diff_prev >= 0), 
     classification := "increasing"]
  dt[(diff_1 <= 0 & diff_prev <= 0 ), 
     classification := "decreasing"]
  dt[(diff_1 == 0 & diff_prev == 0), 
     classification := "unclear"]
  dt[(classification == "increasing") & 
       diff_1 > growth_cutoff * diff_prev, 
     speed := "accelerating"]
  dt[(classification == "increasing") & 
       diff_1 < 1/growth_cutoff * diff_prev, 
     speed := "decelerating"]
  dt[(classification == "decreasing") & 
       abs(diff_1) > growth_cutoff * abs(diff_prev), 
     speed := "accelerating"]
  dt[(classification == "decreasing") & 
       abs(diff_1) < 1/growth_cutoff * abs(diff_prev), 
     speed := "decelerating"]
  
  dt[, c("diff_1", "diff_prev") := NULL]
  return(dt)
}

# obtain classification
epitrend <- classify_epidemic(truth_data)
epitrend[, forecast_date := as.character(target_end_date + 2)]

usethis::use_data(epitrend, overwrite = TRUE)

# save unfiltered data and filtered data ---------------------------------------
# save unfiltered data
unfiltered_data <- combined_data[forecast_date %in% 
                                   as.character(forecast_dates$unfiltered)]

unfiltered_data[, horizon := substring(target, 1, 1)]

unfiltered_data[
  , location_target := paste0(str_to_sentence(target_type), 
                              "s", " in ", location_name)
]

# add classification (as of the forecast date)
# to get this as of target end date, keep the target_end_date column in epitrend
# and remove the forecast_date and merge by target_end_date instead
unfiltered_data <- merge(
  unfiltered_data, 
  copy(epitrend)[, c("target_end_date", "true_value") := NULL], 
  by = c("location_name", "target_type", "forecast_date")
)


unfiltered_data[, target_phase := str_to_title(paste0(target_type, "s - ", 
                                                      classification, " phase"))]
unfiltered_data[, target_phase := factor(target_phase, 
                                         levels = str_to_title(c("Cases - decreasing phase", 
                                                                 "Cases - unclear phase", 
                                                                 "Cases - increasing phase", 
                                                                 "Deaths - decreasing phase", 
                                                                 "Deaths - unclear phase", 
                                                                 "Deaths - increasing phase")))]

usethis::use_data(unfiltered_data, overwrite = TRUE)

# load and set up data
filtered_cases <- unfiltered_data[
  target_type == "case" & 
    !(as.Date(forecast_date) %in% forecast_dates$christmas)
]

filtered_deaths <- unfiltered_data[
  target_type == "death" & 
    !(as.Date(forecast_date) %in% forecast_dates$christmas) &
    !(as.Date(forecast_date) %in% forecast_dates$death_not_scored)
]

filtered_data <- rbindlist(list(filtered_cases, filtered_deaths))

usethis::use_data(filtered_data, overwrite = TRUE)










# additional analysis for individual forecasters -------------------------------

# store prediction data for individual forecasters
root_dir <- here::here("crowd-forecast", "processed-forecast-data")
file_paths_forecast <- here::here(root_dir, list.files(root_dir))

crowdforecast_data <- purrr::map_dfr(file_paths_forecast, 
                                  .f = function(x) {
                                    data <- data.table::fread(x) %>%
                                      dplyr::mutate(target_end_date = as.Date(target_end_date), 
                                                    submission_date = as.Date(submission_date), 
                                                    forecast_date = as.Date(forecast_date))
                                  }) %>%
  dplyr::mutate(target_type = ifelse(grepl("death", target), "death", "case")) %>%
  dplyr::rename(prediction = value) %>%
  dplyr::mutate(forecast_date = as.Date(submission_date)) %>%
  dplyr::rename(model = board_name) %>%
  dplyr::filter(type == "quantile", 
                location_name %in% c("Germany", "Poland")) %>%
  dplyr::select(location, location_name, forecast_date, quantile, prediction, model, target_end_date, horizon, target, target_type)

usethis::use_data(crowdforecast_data, overwrite = TRUE)


# check number of available forecasters
dt <- prediction_data[!(model %in% c("Crowd-Rt-Forecast",
                               "EpiNow2_secondary", 
                               "EpiExpert-ensemble", 
                               "EpiNow2")), 
                .(`number of forecasters` = length(unique(model))), , 
                by = c("forecast_date", "location_name", "target_type")
][order(forecast_date)][
  !is.na(forecast_date)]


dt[, .(sd = sd(`number of forecasters`), 
                             mean = mean(`number of forecasters`), 
                             min  = min(`number of forecasters`), 
                             max = max(`number of forecasters`), 
                             median = median(`number of forecasters`)), 
   by = c("location_name", "target_type")] 

