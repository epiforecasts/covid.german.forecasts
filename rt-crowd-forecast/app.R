# Launch the ShinyApp (Do not remove this comment)

# devtools::install_github("epiforecasts/crowdforecastr")

library(crowdforecastr)
library(magrittr)

options( "golem.app.prod" = TRUE)

# obs_filt_rt <- data.table::fread("../covid-german-forecasts/rt-forecast/data/summary/cases/2021-01-04/rt.csv") %>%
#     dplyr::rename(value = median, 
#                   target_end_date = date) %>%
#     dplyr::filter(target_end_date < Sys.Date())
# 
# data.table::fwrite(obs_filt_rt, 
#                    "./external-ressources/observations.csv")


obs_filt_rt <- read.csv("external-ressources/observations.csv")

submission_date <- "2021-01-11"
first_forecast_date <- as.character(as.Date("2021-01-11") - 14)

crowdforecastr::run_app(data = obs_filt_rt,
                        selection_vars = c("region"), 
                        first_forecast_date = first_forecast_date,
                        submission_date = submission_date,
                        horizons = 6,
                        horizon_interval = 7,
                        google_account_mail = "epiforecasts@gmail.com", 
                        forecast_sheet_id = "1g4OBCcDGHn_li01R8xbZ4PFNKQmV-SHSXFlv2Qv79Ks",
                        user_data_sheet_id = "1GJ5BNcN1UfAlZSkYwgr1-AxgsVA2wtwQ9bRwZ64ZXRQ", 
                        path_past_forecasts = "external_ressources/processed-forecast-data/")