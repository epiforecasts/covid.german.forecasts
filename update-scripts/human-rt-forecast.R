library(googledrive)
library(googlesheets4)
library(dplyr)
library(purrr)


# Google sheets authentification -----------------------------------------------
options(gargle_oauth_cache = ".secrets")
drive_auth(cache = ".secrets", email = "epiforecasts@gmail.com")
gs4_auth(token = drive_token())

spread_sheet <- "1g4OBCcDGHn_li01R8xbZ4PFNKQmV-SHSXFlv2Qv79Ks"
identification_sheet <- "1GJ5BNcN1UfAlZSkYwgr1-AxgsVA2wtwQ9bRwZ64ZXRQ"


# setup ------------------------------------------------------------------------
# - 1 as this is usually updated on a Tuesday
submission_date <- Sys.Date() - 2
median_ensemble <- FALSE


# load data from Google Sheets -------------------------------------------------
# load identification
ids <- googlesheets4::read_sheet(ss = identification_sheet, 
                                 sheet = "ids")
# load forecasts 
forecasts <- googlesheets4::read_sheet(ss = spread_sheet)

# obtain raw and filtered forecasts, save raw forecasts-------------------------
raw_forecasts <- forecasts %>%
  dplyr::mutate(forecast_date = as.Date(forecast_date), 
                submission_date = as.Date(submission_date))

# use only the latest forecast from a given forecaster
filtered_forecasts <- raw_forecasts %>%
  # interesting question whether or not to include foracast_type here. 
  # if someone reconnecs and then accidentally resubmits under a different
  # condition should that be removed or not? 
  dplyr::group_by(forecaster_id, region, target_type) %>%
  dplyr::filter(forecast_time == max(forecast_time)) %>%
  dplyr::ungroup() 


# replace forecast duration with exact data about forecast date and time
# define function to do this for raw and filtered forecasts
replace_date_and_time <- function(forecasts) {
  forecast_times <- forecasts %>%
    dplyr::group_by(forecaster_id, region) %>%
    dplyr::summarise(forecast_time = unique(forecast_time)) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(forecaster_id, forecast_time) %>%
    dplyr::group_by(forecaster_id) %>%
    dplyr::mutate(forecast_duration = c(NA, diff(forecast_time))) %>%
    dplyr::ungroup()
  
  forecasts <- dplyr::inner_join(forecasts, forecast_times, 
                                 by = c("forecaster_id", "region", "forecast_time")) %>%
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
                   paste0("rt-crowd-forecast/raw-forecast-data/", 
                          submission_date, "-raw-forecasts.csv"))


# draw samples from the distributions ------------------------------------------
n_people <- filtered_forecasts$forecaster_id %>%
  unique() %>%
  length()

draw_samples <- function(distribution, 
                         median, 
                         width,
                         n_people, 
                         overall_sample_number = 1000, 
                         min_per_person_samples = 50) {

  num_samples <- max(ceiling(overall_sample_number / n_people), 
                     min_per_person_samples)
  
  if (distribution == "log-normal") {
    values <- exp(rnorm(num_samples, 
                             mean = log(as.numeric(median)),
                             sd = as.numeric(width)))
  } else if (distribution == "normal") {
    values <- rnorm(num_samples, 
                          mean = (as.numeric(median)),
                          sd = as.numeric(width))
    
  } else if (distribution == "cubic-normal") {
    values <- (rnorm(num_samples, 
                          mean = (as.numeric(median) ^ (1/3)),
                          sd = as.numeric(width))) ^ 3
    
  } else if (distribution == "fifth-power-normal") {
    values <- (rnorm(num_samples, 
                          mean = (as.numeric(median) ^ (1/5)),
                          sd = as.numeric(width))) ^ 5
    
  } else if (distribution == "seventh-power-normal") {
    values <- (rnorm(num_samples, 
                          mean = (as.numeric(median) ^ (1/7)),
                          sd = as.numeric(width))) ^ 7
  }

  out <- list(sort(values))
  return(out)
}

# draw samples
forecast_samples <- filtered_forecasts %>%
  dplyr::rename(location = region) %>%
  dplyr::mutate(location = ifelse(location == "Germany", "GM", "PL")) %>%
  dplyr::select(c(forecaster_id, location, target_end_date, submission_date, target_type, distribution, median, width)) %>%
  dplyr::arrange(forecaster_id, location, target_type, target_end_date) %>%
  dplyr::rowwise() %>%
  dplyr::mutate(value = draw_samples(median = median, 
                                     width = width, 
                                     distribution = distribution,
                                     n_people = n_people, 
                                     overall_sample_number = 1000, 
                                     min_per_person_samples = 50), 
                sample = list(1:length(value))) %>%
  tidyr::unnest(cols = c(sample, value)) %>%
  dplyr::ungroup() %>%
  dplyr::select(forecaster_id, location, target_end_date, submission_date, target_type, sample, value) %>%
  dplyr::arrange(forecaster_id, location, target_type, target_end_date, sample)
  

  
  



# interpolate missing days
# I'm pretty sure the horizon time indexisng is currently wrong. 


dates <- unique(forecast_samples$target_end_date)
date_range <- seq(min(as.Date(min(dates))), max(as.Date(max(dates))), by = 'days')
submission_date = unique(forecast_samples$submission_date)
forecaster_ids <- unique(forecast_samples$forecaster_id)
n_samples <- max(forecast_samples$sample)
helper_data <- expand.grid(target_end_date = date_range, 
                           forecaster_id = forecaster_ids,
                           location = c("GM", "PL"), 
                           target_type = c("case", "death"), 
                           submission_date = submission_date, 
                           sample = 1:n_samples)

# get rid of 

forecast_samples_daily <- forecast_samples %>%
  dplyr::mutate(target_end_date = as.Date(target_end_date)) %>%
  dplyr::full_join(helper_data) %>%
  dplyr::arrange(forecaster_id, location, target_type, sample, target_end_date) %>%
  dplyr::group_by(forecaster_id, location, target_type, sample) %>%
  dplyr::mutate(no_predictions = ifelse(all(is.na(value)), TRUE, FALSE)) %>%
  dplyr::filter(!no_predictions) %>%
  dplyr::mutate(value = zoo::na.approx(value))
  

# save forecasts in quantile-format
data.table::fwrite(forecast_samples_daily %>%
                     dplyr::mutate(submission_date = submission_date),
                   paste0("rt-crowd-forecast/processed-forecast-data/", 
                          submission_date, "-processed-forecasts.csv"))




# check result if you want
check <- scoringutils::sample_to_quantile(forecast_samples_daily %>%
                                            dplyr::rename(prediction = value)) %>%
  dplyr::mutate(target_end_date = as.Date(target_end_date))

plot <- scoringutils::plot_predictions(check %>%
                                 dplyr::mutate(true_value = NA_real_, 
                                               target_end_date = as.Date(target_end_date,
                                                                         origin="1970-01-01")), 
                               x = "target_end_date", 
                               facet_formula = ~ forecaster_id + location + target_type)




