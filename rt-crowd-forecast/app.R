# Launch the ShinyApp (Do not remove this comment)
# RT app

# devtools::install_github("epiforecasts/crowdforecastr")

library(crowdforecastr)
library(magrittr)

options("golem.app.prod" = TRUE)

# Assume the submission date to be a Monday and the target end dates to be Saturdays
submission_date <- "2021-01-18" 
first_forecast_date <- as.character(as.Date(submission_date) - 16)

# obs_filt_rt_cases <- data.table::fread(paste0("rt-forecast/data/summary/cases/", submission_date, "/rt.csv")) %>%
#     dplyr::rename(value = median,
#                   target_end_date = date) %>%
#   dplyr::mutate(target_type = "case",
#                 target_end_date = as.Date(target_end_date)) %>%
#     dplyr::filter(target_end_date <= (as.Date(first_forecast_date) + 7 * 6)) %>%
#   dplyr::filter(region %in% c("Poland", "Germany"))
# obs_filt_rt_deaths <- data.table::fread(paste0("rt-forecast/data/summary/deaths/", submission_date, "/rt.csv")) %>%
#   dplyr::rename(value = median,
#                 target_end_date = date) %>%
#   dplyr::mutate(target_type = "death",
#                 target_end_date = as.Date(target_end_date)) %>%
#   dplyr::filter(target_end_date <= (as.Date(first_forecast_date) + 7 * 6)) %>%
#   dplyr::filter(region %in% c("Poland", "Germany"))
# obs_filt_rt <- dplyr::bind_rows(obs_filt_rt_cases, obs_filt_rt_deaths) %>%
#   dplyr::arrange(region, target_type, target_end_date)
# data.table::fwrite(obs_filt_rt,
#                    "rt-crowd-forecast/external-ressources/observations.csv")


obs_filt_rt <- read.csv("external-ressources/observations.csv") %>%
  dplyr::arrange(region, target_type, target_end_date)

obs_filt_rt %>%
  dplyr::filter(target_type == "case") %>%
  dplyr::pull(target_end_date)


crowdforecastr::run_app(data = obs_filt_rt,
                        selection_vars = c("region", "target_type"), 
                        first_forecast_date = first_forecast_date,
                        submission_date = submission_date,
                        horizons = 7,
                        horizon_interval = 7,
                        google_account_mail = "epiforecasts@gmail.com", 
                        forecast_sheet_id = "1g4OBCcDGHn_li01R8xbZ4PFNKQmV-SHSXFlv2Qv79Ks",
                        user_data_sheet_id = "1GJ5BNcN1UfAlZSkYwgr1-AxgsVA2wtwQ9bRwZ64ZXRQ", 
                        path_past_forecasts = "external_ressources/processed-forecast-data/")