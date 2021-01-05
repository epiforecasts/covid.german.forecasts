library(googledrive)
library(googlesheets4)
library(dplyr)
library(purrr)


# Google sheets authentification -----------------------------------------------
options(gargle_oauth_cache = ".secrets")
drive_auth(cache = ".secrets", email = "epiforecasts@gmail.com")
gs4_auth(token = drive_token())

spread_sheet <- "1xdJDgZdlN7mYHJ0D0QbTcpiV9h1Dmga4jVoAg5DhaKI"
identification_sheet <- "1GJ5BNcN1UfAlZSkYwgr1-AxgsVA2wtwQ9bRwZ64ZXRQ"


# setup ------------------------------------------------------------------------
# - 1 as this is usually updated on a Tuesday
submission_date <- Sys.Date() - 1
median_ensemble <- FALSE
# grid of quantiles to obtain / submit from forecasts
quantile_grid <- c(0.01, 0.025, seq(0.05, 0.95, 0.05), 0.975, 0.99)


# load data from Google Sheets -------------------------------------------------
# load identification
ids <- googlesheets4::read_sheet(ss = identification_sheet, 
                                 sheet = "ids")
# load forecasts 
forecasts <- googlesheets4::read_sheet(ss = spread_sheet, 
                                       sheet = "predictions")

# handle comments made by users ------------------------------------------------
# extract comments and store separately
comments <- forecasts %>%
  dplyr::select(forecaster_id, comments) %>%
  dplyr::filter(!is.na(comments)) %>%
  unique()

# append comments to google sheets
comment_sheet <- "1isJQbE1RLvXYDpaaDADPHObgh8DMsTIHOonu8S1W8zc"
googlesheets4::sheet_append(ss = comment_sheet,
                            data = comments)

# obtain raw and filtered forecasts, save raw forecasts-------------------------
raw_forecasts <- forecasts %>%
  dplyr::select(-comments) 

# use only the latest forecast from a given forecaster
filtered_forecasts <- raw_forecasts %>%
  # interesting question whether or not to include foracast_type here. 
  # if someone reconnecs and then accidentally resubmits under a different
  # condition should that be removed or not? 
  dplyr::group_by(forecaster_id, forecast_type, location, inc, type) %>%
  dplyr::filter(forecast_time == max(forecast_time)) %>%
  dplyr::ungroup()


# replace forecast duration with exact data about forecast date and time
# define function to do this for raw and filtered forecasts
replace_date_and_time <- function(forecasts) {
  forecast_times <- forecasts %>%
    dplyr::group_by(forecaster_id, location, type, inc) %>%
    dplyr::summarise(forecast_time = unique(forecast_time)) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(forecaster_id, forecast_time) %>%
    dplyr::group_by(forecaster_id) %>%
    dplyr::mutate(forecast_duration = c(NA, diff(forecast_time))) %>%
    dplyr::ungroup()
  
  forecasts <- dplyr::inner_join(forecasts, forecast_times, 
                                 by = c("forecaster_id", "location", "inc", 
                                        "type", "forecast_time")) %>%
    dplyr::mutate(forecast_week = lubridate::epiweek(forecast_date), 
                  target_end_date = as.Date(target_end_date)) %>%
    dplyr::select(-forecast_time)
  
  return(forecasts)
}

# replace time with duration and date with epiweek
raw_forecasts <- replace_date_and_time(raw_forecasts)
filtered_forecasts <- replace_date_and_time(filtered_forecasts)

# write raw forecasts
data.table::fwrite(raw_forecasts %>%
                     dplyr::select(-board_name),
                   paste0("human-forecasts/raw-forecast-data/", 
                          submission_date, "-raw-forecasts.csv"))


# obtain quantiles from forecasts ----------------------------------------------
# define function that returns quantiles depending on condition and distribution

calculate_quantiles <- function(quantile_grid, 
                             median, 
                             width, 
                             forecast_type, 
                             distribution, 
                             lower_90, 
                             upper_90) {
  
  if (forecast_type == "distribution") {
    if (distribution == "log-normal") {
      values <- list(exp(qnorm(quantile_grid, 
                               mean = log(as.numeric(median)),
                               sd = as.numeric(width))))
    } else if (distribution == "normal") {
      values <- list((qnorm(quantile_grid, 
                            mean = (as.numeric(median)),
                            sd = as.numeric(width))))
      
    } else if (distribution == "cubic-normal") {
      values <- list((qnorm(quantile_grid, 
                            mean = (as.numeric(median) ^ (1/3)),
                            sd = as.numeric(width))) ^ 3)
      
    } else if (distribution == "fifth-power-normal") {
      values <- list((qnorm(quantile_grid, 
                            mean = (as.numeric(median) ^ (1/5)),
                            sd = as.numeric(width))) ^ 5)
      
    } else if (distribution == "seventh-power-normal") {
      values <- list((qnorm(quantile_grid, 
                            mean = (as.numeric(median) ^ (1/7)),
                            sd = as.numeric(width))) ^ 7)
    }
    
  } else if (forecast_type == "quantile_forecast") {
    # code still needs to be written
    values <- list(quantile_grid)
  }
  return(values)
}

forecast_quantiles <- filtered_forecasts %>%
  # disregard quantile forecasts this week
  dplyr::filter(forecast_type == "distribution") %>%
  dplyr::rowwise() %>%
  dplyr::mutate(quantile = list(quantile_grid),
                value = calculate_quantiles(quantile_grid, 
                                            median, 
                                            width, 
                                            forecast_type, 
                                            distribution, 
                                            lower_90, 
                                            upper_90)) %>%
  tidyr::unnest(cols = c(quantile, value)) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(type = ifelse(type == "cases", "case", "death"), 
                target = paste0(horizon, " wk ahead inc ", type), 
                type = "quantile")

# save forecasts in quantile-format
data.table::fwrite(forecast_quantiles %>%
                     dplyr::mutate(submission_date = submission_date),
                   paste0("human-forecasts/processed-forecast-data/", 
                          submission_date, "-processed-forecasts.csv"))

# # filter out all forecasts where only one of two targets was submitted
# forecast_quantiles %>%
#   dplyr::group_by(forecaster_id) %>%
#   dplyr::mutate(number_flag = dplyr::n()) %>%
#   dplyr::filter(number_flag %% 8 == 0) # 4 * 4 * 23 in total



if (median_ensemble) {
  # make median ensemble ---------------------------------------------------------
  median_ensemble <- forecast_quantiles %>%
    dplyr::mutate(target_end_date = as.Date(target_end_date)) %>%
    dplyr::group_by(location, location_name, target, type, quantile, horizon, target_end_date) %>%
    dplyr::summarise(value = median(value)) %>%
    dplyr::ungroup() %>%
    dplyr::select(target, target_end_date, location, type, quantile, value, location_name)
  
  # add median forecast
  forecast_inc <- dplyr::bind_rows(median_ensemble, 
                                   median_ensemble %>%
                                     dplyr::filter(quantile == 0.5) %>%
                                     dplyr::mutate(type = "point", 
                                                   quantile = NA))
} else {
  # make mean ensemble ---------------------------------------------------------
  mean_ensemble <- forecast_quantiles %>%
    dplyr::mutate(target_end_date = as.Date(target_end_date)) %>%
    dplyr::group_by(location, location_name, target, type, quantile, horizon, target_end_date) %>%
    dplyr::summarise(value = mean(value)) %>%
    dplyr::ungroup() %>%
    dplyr::select(target, target_end_date, location, type, quantile, value, location_name)
  
  # add median forecast
  forecast_inc <- dplyr::bind_rows(mean_ensemble, 
                                   mean_ensemble %>%
                                     dplyr::filter(quantile == 0.5) %>%
                                     dplyr::mutate(type = "point", 
                                                   quantile = NA))
}


# add cumulative forecasts -----------------------------------------------------

# get latest cumulative forecast
first_forecast_date <- forecasts %>%
  dplyr::pull(target_end_date) %>%
  as.Date() %>%
  unique() %>%
  min(na.rm = TRUE)

# add latest deaths and cases
source(here::here("functions", "load-data.R"))

deaths <- get_data(cumulative = TRUE, weekly = TRUE, cases = FALSE) %>%
  dplyr::group_by(location) %>%
  dplyr::filter(target_end_date == as.Date(first_forecast_date - 7)) %>%
  dplyr::mutate(case = "death")

cases <- get_data(cumulative = TRUE, weekly = TRUE, cases = TRUE) %>%
  dplyr::group_by(location) %>%
  dplyr::filter(target_end_date == as.Date(first_forecast_date - 7)) %>%
  dplyr::mutate(case = "case")

last_obs <- dplyr::bind_rows(deaths, cases) %>%
  dplyr::select(location, value, case) %>%
  dplyr::rename(last_value = value)

# make cumulative
forecast_cum <- forecast_inc %>%
  dplyr::mutate(case = ifelse(grepl("case", target), "case", "death")) %>%
  dplyr::group_by(location, quantile, case) %>%
  dplyr::mutate(value = cumsum(value), 
                target = gsub("inc", "cum", target)) %>%
  dplyr::ungroup() %>%
  # add last observed value
  dplyr::inner_join(last_obs) %>%
  dplyr::mutate(value = value + last_value) %>%
  dplyr::select(-last_value, -case)

forecast_submission <- dplyr::bind_rows(forecast_inc, forecast_cum) %>%
  dplyr::mutate(forecast_date = submission_date)


# write submission files -------------------------------------------------------
if (!dir.exists(here::here("submissions", "human-forecasts", submission_date))) {
  dir.create(here::here("submissions", "human-forecasts", submission_date))
}



forecast_submission %>%
  dplyr::filter(location_name %in% "Germany", 
                grepl("death", target)) %>%
  data.table::fwrite(here::here("submissions", "human-forecasts", submission_date,
                                paste0(submission_date, 
                                       "-Germany-epiforecasts-EpiExpert.csv")))

forecast_submission %>%
  dplyr::filter(location_name %in% "Germany", 
                grepl("case", target)) %>%
  data.table::fwrite(here::here("submissions", "human-forecasts", submission_date,
                                paste0(submission_date, 
                                       "-Germany-epiforecasts-EpiExpert-case.csv")))

forecast_submission %>%
  dplyr::filter(location_name %in% "Poland", 
                grepl("death", target)) %>%
  data.table::fwrite(here::here("submissions", "human-forecasts", submission_date,
                                paste0(submission_date, 
                                       "-Poland-epiforecasts-EpiExpert.csv")))

forecast_submission %>%
  dplyr::filter(location_name %in% "Poland", 
                grepl("case", target)) %>%
  data.table::fwrite(here::here("submissions", "human-forecasts", submission_date,
                                paste0(submission_date, 
                                       "-Poland-epiforecasts-EpiExpert-case.csv")))








# also read all EpiExpert forecasts, give them a board_name 
folders <- list.files("submissions/human-forecasts/")
files <- purrr::map(folders, 
                    .f = function(folder_name) {
                      files <- list.files(paste0("submissions/human-forecasts/", 
                                                 folder_name))
                      paste(paste0("submissions/human-forecasts/", 
                                   folder_name, "/", 
                                   files))
                    }) %>%
  unlist()
epiexpert_forecasts <- purrr::map_dfr(files, readr::read_csv) %>%
  dplyr::mutate(board_name = "EpiExpert-ensemble", 
                submission_date = forecast_date,
                horizon = as.numeric(gsub("([0-9]+).*$", "\\1", target))) %>%
  dplyr::filter(grepl("inc", target), 
                type == "quantile")

data.table::fwrite(epiexpert_forecasts, 
                   "human-forecasts/processed-forecast-data/all-epiexpert-forecasts.csv")




# also read all EpiNow2 forecasts, give them a board_name 
folders <- list.files("submissions/rt-forecasts/")
files <- purrr::map(folders, 
                    .f = function(folder_name) {
                      files <- list.files(paste0("submissions/rt-forecasts/", 
                                                 folder_name))
                      paste(paste0("submissions/rt-forecasts/", 
                                   folder_name, "/", 
                                   files))
                    }) %>%
  unlist()
epinow_forecasts <- purrr::map_dfr(files, readr::read_csv) %>%
  dplyr::mutate(board_name = "EpiNow2", 
                submission_date = forecast_date,
                horizon = as.numeric(gsub("([0-9]+).*$", "\\1", target))) %>%
  dplyr::filter(grepl("inc", target), 
                type == "quantile")

data.table::fwrite(epinow_forecasts, 
                   "human-forecasts/processed-forecast-data/all-epinow2-forecasts.csv")

# copy data into human forecast performance board app
file.copy(from = here::here("human-forecasts", "processed-forecast-data"), 
          to = here::here("human-forecasts", "performance-board"), recursive = TRUE)




# also read all EpiNow2 secondary forecasts, give them a board_name 
folders <- list.files("submissions/deaths-from-cases/")
files <- purrr::map(folders, 
                    .f = function(folder_name) {
                      files <- list.files(paste0("submissions/deaths-from-cases/", 
                                                 folder_name))
                      paste(paste0("submissions/deaths-from-cases/", 
                                   folder_name, "/", 
                                   files))
                    }) %>%
  unlist()
epinow_forecasts <- purrr::map_dfr(files, readr::read_csv) %>%
  dplyr::mutate(board_name = "EpiNow2_secondary", 
                submission_date = forecast_date,
                horizon = as.numeric(gsub("([0-9]+).*$", "\\1", target))) %>%
  dplyr::filter(grepl("inc", target), 
                type == "quantile")

data.table::fwrite(epinow_forecasts, 
                   "human-forecasts/processed-forecast-data/all-epinow2_secondary-forecasts.csv")

# copy data into human forecast performance board app
file.copy(from = here::here("human-forecasts", "processed-forecast-data"), 
          to = here::here("human-forecasts", "performance-board"), recursive = TRUE)














# 
# 
# # empty google sheet
# cols <- data.frame(matrix(ncol = ncol(forecasts), nrow = 0))
# names(cols) <- names(forecasts)
# googlesheets4::write_sheet(data = cols,
#                            ss = spread_sheet,
#                            sheet = "predictions")

