# Launch the ShinyApp (Do not remove this comment)
# RT app
# when on a new computer, update crowdforecastr
# devtools::install_github("epiforecasts/crowdforecastr")
library(covid.german.forecasts)
library(data.table)
library(dplyr)
library(crowdforecastr)
library(magrittr)

options("golem.app.prod" = TRUE)

# load submission date from data if on server
if (!dir.exists("rt-crowd-forecast")) {
  submission_date <- readRDS("data/submission_date.rds")
} else {
  submision_date <- latest_weekday() + 7
}
first_forecast_date <- as.character(as.Date(submission_date) - 16)

# run on local machine to load the latest data. will be skipped on the shiny server
if (dir.exists("rt-forecast")) {
  obs_filt_rt_cases <- fread(paste0("rt-forecast/data/summary/cases/", submission_date, "/rt.csv")) %>%
    rename(value = median, target_end_date = date) %>%
    mutate(target_type = "case", target_end_date = as.Date(target_end_date)) %>%
    filter(target_end_date <= (as.Date(first_forecast_date) + 7 * 6)) %>%
    filter(region %in% c("Poland", "Germany"))

  obs_filt_rt_deaths <- fread(paste0("rt-forecast/data/summary/deaths/", submission_date, "/rt.csv")) %>%
    rename(value = median, target_end_date = date) %>%
    mutate(target_type = "death", target_end_date = as.Date(target_end_date)) %>%
    filter(target_end_date <= (as.Date(first_forecast_date) + 7 * 6)) %>%
    filter(region %in% c("Poland", "Germany"))

  obs_filt_rt <- bind_rows(obs_filt_rt_cases, obs_filt_rt_deaths) %>%
    arrange(region, target_type, target_end_date) %>%
    arrange(region, target_type, target_end_date)
  
  fwrite(obs_filt_rt, "rt-crowd-forecast/external-ressources/observations.csv")
} else {
  obs_filt_rt <- read.csv("data/observations.csv")
}

run_app(data = obs_filt_rt,
        selection_vars = c("region", "target_type"), 
        first_forecast_date = first_forecast_date,
        submission_date = submission_date,
        horizons = 7,
        horizon_interval = 7,
        google_account_mail = "epiforecasts@gmail.com", 
        force_increasing_uncertainty = FALSE,
        default_distribution = "normal",
        forecast_sheet_id = "1g4OBCcDGHn_li01R8xbZ4PFNKQmV-SHSXFlv2Qv79Ks",
        user_data_sheet_id = "1GJ5BNcN1UfAlZSkYwgr1-AxgsVA2wtwQ9bRwZ64ZXRQ", 
        path_past_forecasts = "external_ressources/processed-forecast-data/")