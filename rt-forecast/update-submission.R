# Package -----------------------------------------------------------------
library(data.table)
library(EpiNow2)

# Dates -------------------------------------------------------------------
target_date <- Sys.Date()

# Get forecasts -----------------------------------------------------------
case_forecast <- suppressWarnings(
  EpiNow2::get_regional_results(results_dir = here::here("rt-forecast", "data", "samples", "cases"),
                                date = lubridate::ymd(target_date),
                                forecast = TRUE, samples = TRUE)$estimated_reported_cases$samples)

death_forecast <- suppressWarnings(
  EpiNow2::get_regional_results(results_dir = here::here("rt-forecast", "data", "samples", "deaths"),
                                date = lubridate::ymd(target_date),
                                forecast = TRUE, samples = TRUE)$estimated_reported_cases$samples)

# Format forecasts --------------------------------------------------------
source(here::here("rt-forecast", "functions", "format-forecast.R"))

case_forecast <- format_forecast(case_forecast[, value := cases], 
                                 cumulative =  data.table::fread(here::here("data", "weekly-cumulative-cases.csv")),
                                 forecast_date = target_date,
                                 submission_date = target_date,
                                 CrI_samples = 1,
                                 target_value = "case")

death_forecast <- format_forecast(death_forecast[, value := cases], 
                                  cumulative = data.table::fread(here::here("data", "weekly-cumulative-deaths.csv")),
                                  forecast_date = target_date,
                                  submission_date = target_date,
                                  CrI_samples = 1,
                                  target_value = "death")

# Save forecasts ----------------------------------------------------------
target_folder <- here::here("submissions", "rt-forecasts", target_date)
if (!dir.exists(target_folder)) {
  dir.create(target_folder, recursive = TRUE)
}

name_forecast <- function(name, type = ""){
  paste0(target_date, "-", name, "-epiforecasts-EpiNow2", type, ".csv")
}

save_forecast <- function(forecast, name, type = "") {
  data.table::fwrite(forecast[location_name == name], 
                     file.path(target_folder, name_forecast(name, type)))
}

save_forecast(case_forecast, "Germany", "-case")
save_forecast(case_forecast, "Poland", "-case")
save_forecast(death_forecast, "Germany")
save_forecast(death_forecast, "Poland")
