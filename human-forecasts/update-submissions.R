library(covid.german.forecasts)
library(googledrive)
library(googlesheets4)
library(dplyr)
library(purrr)
library(data.table)
library(lubridate)


# Google sheets authentification -----------------------------------------------
options(gargle_oauth_cache = ".secrets")
drive_auth(cache = ".secrets", email = "epiforecasts@gmail.com")
gs4_auth(token = drive_token())

spread_sheet <- "1nOy3BfHoIKCHD4dfOtJaz4QMxbuhmEvsWzsrSMx_grI"
identification_sheet <- "1GJ5BNcN1UfAlZSkYwgr1-AxgsVA2wtwQ9bRwZ64ZXRQ"


# setup ------------------------------------------------------------------------
# - 1 as this is usually updated on a Tuesday
submission_date <- latest_weekday()
median_ensemble <- FALSE
# grid of quantiles to obtain / submit from forecasts
quantile_grid <- c(0.01, 0.025, seq(0.05, 0.95, 0.05), 0.975, 0.99)


# load data from Google Sheets -------------------------------------------------
# load identification
ids <- try_and_wait(read_sheet(ss = identification_sheet, sheet = "ids"))
# load forecasts 
forecasts <- try_and_wait(read_sheet(ss = spread_sheet))

delete_data <- FALSE
if (delete_data) {
  # add forecasts to backup sheet
  try_and_wait(sheet_append(ss = spread_sheet, sheet = "oldforecasts", data = forecasts))
  
  # delete data from sheet
  cols <- data.frame(matrix(ncol = ncol(forecasts), nrow = 0))
  names(cols) <- names(forecasts)
  try_and_wait(write_sheet(data = cols, ss = spread_sheet, sheet = "predictions"))
}

# obtain raw and filtered forecasts, save raw forecasts-------------------------
raw_forecasts <- forecasts %>%
  mutate(location = ifelse(location_name == "Germany", "GM", "PL"))

# use only the latest forecast from a given forecaster
filtered_forecasts <- raw_forecasts %>%
  # interesting question whether or not to include foracast_type here. 
  # if someone reconnecs and then accidentally resubmits under a different
  # condition should that be removed or not? 
  group_by(forecaster_id, location, target_type) %>%
  filter(forecast_time == max(forecast_time)) %>%
  ungroup()


# replace forecast duration with exact data about forecast date and time
# define function to do this for raw and filtered forecasts
replace_date_and_time <- function(forecasts) {
  forecast_times <- forecasts %>%
    group_by(forecaster_id, location, target_type) %>%
    summarise(forecast_time = unique(forecast_time)) %>%
    ungroup() %>%
    arrange(forecaster_id, forecast_time) %>%
    group_by(forecaster_id) %>%
    dmutate(forecast_duration = c(NA, diff(forecast_time))) %>%
    ungroup()
  
  forecasts <- inner_join(forecasts, forecast_times, 
                          by = c("forecaster_id", "location",  "target_type", "forecast_time")) %>%
    mutate(forecast_week = epiweek(forecast_date), target_end_date = as.Date(target_end_date)) %>%
    select(-forecast_time)
  return(forecasts)
}

# replace time with duration and date with epiweek
raw_forecasts <- replace_date_and_time(raw_forecasts)
filtered_forecasts <- replace_date_and_time(filtered_forecasts)

# write raw forecasts
fwrite(raw_forecasts %>% select(-board_name),
       here("human-forecasts", "raw-forecast-data", submission_date, "-raw-forecasts.csv"))


# obtain quantiles from forecasts ----------------------------------------------
# define function that returns quantiles depending on condition and distribution

calculate_quantiles <- function(quantile_grid, median, width, forecast_type, distribution, lower_90, upper_90) {
  
  if (distribution == "log-normal") {
    values <- list(exp(qnorm(quantile_grid, mean = log(as.numeric(median)), sd = as.numeric(width))))
  } else if (distribution == "normal") {
    values <- list((qnorm(quantile_grid, mean = (as.numeric(median)), sd = as.numeric(width))))
    
  } else if (distribution == "cubic-normal") {
    values <- list((qnorm(quantile_grid, mean = (as.numeric(median) ^ (1/3)), sd = as.numeric(width))) ^ 3)
    
  } else if (distribution == "fifth-power-normal") {
    values <- list((qnorm(quantile_grid, mean = (as.numeric(median) ^ (1/5)), sd = as.numeric(width))) ^ 5)
    
  } else if (distribution == "seventh-power-normal") {
    values <- list((qnorm(quantile_grid, mean = (as.numeric(median) ^ (1/7)), sd = as.numeric(width))) ^ 7)
  }
  return(values)
}

forecast_quantiles <- filtered_forecasts %>%
  # disregard quantile forecasts this week
  rowwise() %>%
  mutate(quantile = list(quantile_grid),
        value = calculate_quantiles(quantile_grid, median, width, forecast_type, distribution, lower_90, upper_90)) %>%
  unnest(cols = c(quantile, value)) %>%
  ungroup() %>%
  mutate(type = ifelse(target_type == "cases", "case", "death"), target = paste0(horizon, " wk ahead inc ", type), 
         type = "quantile")

# save forecasts in quantile-format
fwrite(forecast_quantiles %>% mutate(submission_date = submission_date),
       here("human-forecasts", "processed-forecast-data", submission_date, "-processed-forecasts.csv"))

# omit forecasters who haven't forecasted at least two targets
forecasters_to_omit <- forecast_quantiles %>%
  select(forecaster_id, location, target_type) %>%
  unique() %>%
  group_by(forecaster_id) %>%
  mutate(n = n(), flag = n >= 2) %>%
  filter(!flag) %>%
  pull(forecaster_id) %>%
  unique()
  
forecast_quantiles <- forecast_quantiles %>%
  filter(!(forecaster_id %in% forecasters_to_omit))
  
if (median_ensemble) {
  # make median ensemble ---------------------------------------------------------
  forecast_inc <- forecast_quantiles %>%
    mutate(target_end_date = as.Date(target_end_date)) %>%
    group_by(location, location_name, target, type, quantile, horizon, target_end_date) %>%
    summarise(value = median(value)) %>%
    ungroup() %>%
    select(target, target_end_date, location, type, quantile, value, location_name)
} else {
  # make mean ensemble ---------------------------------------------------------
  forecast_inc <- forecast_quantiles %>%
    mutate(target_end_date = as.Date(target_end_date)) %>%
    group_by(location, location_name, target, type, quantile, horizon, target_end_date) %>%
    summarise(value = mean(value)) %>%
    ungroup() %>%
    select(target, target_end_date, location, type, quantile, value, location_name)
}
# add point forecast
  forecast_inc <- bind_rows(forecast_inc, 
    forecast_inc %>%
      filter(quantile == 0.5) %>%
      mutate(type = "point", 
      quantile = NA))

# add cumulative forecasts -----------------------------------------------------
# get latest cumulative forecast
first_forecast_date <- forecasts %>%
  pull(target_end_date) %>%
  as.Date() %>%
  unique() %>%
  min(na.rm = TRUE)

deaths <- get_truth_data(dir = here("data-raw"), range = "weekly", type = "cumulative",
                         target = "deaths", locs = c("GM", "PL")) %>%
  group_by(location) %>%
  filter(target_end_date == as.Date(first_forecast_date - 7)) %>%
  rename(case = type)

cases <- get_truth_data(dir = here("data-raw"), range = "weekly", type = "cumulative",
                         target = "cases", locs = c("GM", "PL")) %>%
  group_by(location) %>%
  filter(target_end_date == as.Date(first_forecast_date - 7)) %>%
  rename(case = type)

last_obs <- bind_rows(deaths, cases) %>%
  select(location, value, case) %>%
  rename(last_value = value)

# make cumulative
forecast_cum <- forecast_inc %>%
  mutate(case = ifelse(grepl("case", target), "case", "death")) %>%
  group_by(location, quantile, case) %>%
  mutate(value = cumsum(value), 
                target = gsub("inc", "cum", target)) %>%
  ungroup() %>%
  # add last observed value
  inner_join(last_obs) %>%
  mutate(value = value + last_value) %>%
  select(-last_value, -case)

forecast_submission <- bind_rows(forecast_inc, forecast_cum) %>%
  mutate(forecast_date = submission_date)

# write submission files -------------------------------------------------------
check_dir(here("submissions", "human-forecasts", submission_date))

forecast_submission %>%
  filter(location_name %in% "Germany", 
                grepl("death", target)) %>%
  fwrite(here("submissions", "human-forecasts", submission_date, paste0(submission_date, "-Germany-epiforecasts-EpiExpert.csv")))

forecast_submission %>%
  filter(location_name %in% "Germany", 
                grepl("case", target)) %>%
  fwrite(here("submissions", "human-forecasts", submission_date, paste0(submission_date, "-Germany-epiforecasts-EpiExpert-case.csv")))

forecast_submission %>%
  filter(location_name %in% "Poland", 
                grepl("death", target)) %>%
  fwrite(here("submissions", "human-forecasts", submission_date, paste0(submission_date, "-Poland-epiforecasts-EpiExpert.csv")))

forecast_submission %>%
  filter(location_name %in% "Poland", 
                grepl("case", target)) %>%
  fwrite(here("submissions", "human-forecasts", submission_date, paste0(submission_date, "-Poland-epiforecasts-EpiExpert-case.csv")))