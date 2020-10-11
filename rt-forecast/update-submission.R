# Package -----------------------------------------------------------------
library(data.table)
library(EpiNow2)

# Dates -------------------------------------------------------------------
target_date <- Sys.Date()

# Get forecasts -----------------------------------------------------------
case_forecast <- suppressWarnings(
  EpiNow2::get_regional_results(results_dir = here::here("rt-forecast", "samples", "cases"),
                                date = lubridate::ymd(target_date),
                                forecast = TRUE, samples = TRUE)$estimated_reported_cases$samples)

death_forecast <- suppressWarnings(
  EpiNow2::get_regional_results(results_dir = here::here("rt-forecast", "samples", "deaths"),
                                date = lubridate::ymd(target_date),
                                forecast = TRUE, samples = TRUE)$estimated_reported_cases$samples)

# Format forecasts --------------------------------------------------------
source(here::here("rt-forecast", "functions", "format-forecast.R"))

case_forecast <- format_forecast(case_forecast[, value := cases], 
                                 forecast_date = target_date,
                                 submission_date = target_date,
                                 CrI_samples = 0.4,
                                 target = "cases")

death_forecast <- format_forecast(death_forecast[, value := cases], 
                                  forecast_date = target_date,
                                  submission_date = target_date,
                                  CrI_samples = 0.4,
                                  target = "deaths")

# Save forecasts ----------------------------------------------------------
target_folder <- here::here("rt-forecast", "submissions", target_date)
if (!dir.exists(target_folder)) {
  dir.create(target_folder, recursive = TRUE)
}

data.table::fwrite(case_forecast[location_name == "Germany"], file.path(target_folder, "cases-germany.csv"))
data.table::fwrite(case_forecast[location_name == "Poland"], file.path(target_folder, "cases-poland.csv"))
data.table::fwrite(death_forecast[location_name == "Germany"], file.path(target_folder, "deaths-germany.csv"))
data.table::fwrite(death_forecast[location_name == "Poland"], file.path(target_folder, "deaths-poland.csv"))