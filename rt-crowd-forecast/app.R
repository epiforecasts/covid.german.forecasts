# Launch the ShinyApp (Do not remove this comment)
# RT app
library(data.table)
library(dplyr)
library(crowdforecastr)
library(magrittr)
library(rstantools)
library(lubridate)

options("golem.app.prod" = TRUE)

# load submission date from data if on server
if (!dir.exists("rt-crowd-forecast")) {
  submission_date <- readRDS("data-raw/submission_date.rds")
} else {
  submission_date <- floor_date(Sys.Date(), unit = "week", day)
}
first_forecast_date <- as.character(as.Date(submission_date) - 16)

# Run on local machine to load the latest data.
# Will be skipped on the shiny server
if (dir.exists("rt-forecast")) {
  obs <- fread(
    paste0("rt-forecast/data/summary/cases/", submission_date, "/rt.csv")
    ) %>%
    rename(value = median, target_end_date = date) %>%
    mutate(target_type = "case", target_end_date = as.Date(target_end_date)) %>%
    filter(target_end_date <= (as.Date(first_forecast_date) + 7 * 6)) %>%
    filter(region %in% c("Poland", "Germany")) %>%
    arrange(region, target_type, target_end_date)

  fwrite(obs, "rt-crowd-forecast/external-ressources/observations.csv")
} else {
  obs <- read.csv("data-raw/observations.csv")
}

run_app(
  data = obs,
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
  path_past_forecasts = "external_ressources/processed-forecast-data/"
)