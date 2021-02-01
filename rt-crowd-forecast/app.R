# Launch the ShinyApp (Do not remove this comment)
# RT app
# when on a new computer, update crowdforecastr
# devtools::install_github("epiforecasts/crowdforecastr")

library(crowdforecastr)
library(magrittr)

options("golem.app.prod" = TRUE)


# load submission date from data if on server
if (!dir.exists("rt-crowd-forecast/")) {
  submission_date <- readRDS("data/submission_date.RDS")
} else {
  submision_date <- as.Date("2020-02-01")
}

first_forecast_date <- as.character(as.Date(submission_date) - 16)

# run on local machine to load the latest data. will be skipped on the shiny server
if (dir.exists("rt-forecast")) {
  obs_filt_rt_cases <- data.table::fread(paste0("rt-forecast/data/summary/cases/", submission_date, "/rt.csv")) %>%
      dplyr::rename(value = median,
                    target_end_date = date) %>%
    dplyr::mutate(target_type = "case",
                  target_end_date = as.Date(target_end_date)) %>%
      dplyr::filter(target_end_date <= (as.Date(first_forecast_date) + 7 * 6)) %>%
    dplyr::filter(region %in% c("Poland", "Germany"))
  obs_filt_rt_deaths <- data.table::fread(paste0("rt-forecast/data/summary/deaths/", submission_date, "/rt.csv")) %>%
    dplyr::rename(value = median,
                  target_end_date = date) %>%
    dplyr::mutate(target_type = "death",
                  target_end_date = as.Date(target_end_date)) %>%
    dplyr::filter(target_end_date <= (as.Date(first_forecast_date) + 7 * 6)) %>%
    dplyr::filter(region %in% c("Poland", "Germany"))
  obs_filt_rt <- dplyr::bind_rows(obs_filt_rt_cases, obs_filt_rt_deaths) %>%
    dplyr::arrange(region, target_type, target_end_date) %>%
    dplyr::arrange(region, target_type, target_end_date)
  
  data.table::fwrite(obs_filt_rt,
                     "rt-crowd-forecast/external-ressources/observations.csv")
  
} else {
  obs_filt_rt <- read.csv("data/observations.csv")
}

crowdforecastr::run_app(data = obs_filt_rt,
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
