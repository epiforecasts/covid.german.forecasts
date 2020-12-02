# Package -----------------------------------------------------------------
library(data.table)
library(EpiNow2)
library(lubridate)

# Dates -------------------------------------------------------------------
target_date <- Sys.Date()
# Get forecasts -----------------------------------------------------------
case_forecast <- suppressWarnings(
  EpiNow2::get_regional_results(results_dir = here::here("rt-forecast", "data", "samples", "cases"),
                                date = ymd(target_date), forecast = TRUE, 
                                samples = TRUE)$estimated_reported_cases$samples)

death_forecast <- suppressWarnings(
  get_regional_results(results_dir = here::here("rt-forecast", "data", "samples", "deaths"),
                       date = ymd(target_date), forecast = TRUE, 
                       samples = TRUE)$estimated_reported_cases$samples)

death_from_cases_forecast <- fread(here("rt-forecast", "data", "samples", "deaths-from-cases",
                                         target_date, "samples.csv"))
# Format forecasts --------------------------------------------------------
source(here("rt-forecast", "functions", "format-forecast.R"))

case_forecast <- format_forecast(case_forecast[, value := cases], 
                                 cumulative =  fread(here("data", "weekly-cumulative-cases.csv")),
                                 forecast_date = target_date,
                                 submission_date = target_date,
                                 CrI_samples = 0.6,
                                 target_value = "case")

death_forecast <- format_forecast(death_forecast[, value := cases], 
                                  cumulative = fread(here("data", "weekly-cumulative-deaths.csv")),
                                  forecast_date = target_date,
                                  submission_date = target_date,
                                  CrI_samples = 0.6,
                                  target_value = "death")

death_from_cases_forecast <- format_forecast(death_from_cases_forecast, 
                                  cumulative = fread(here("data", "weekly-cumulative-deaths.csv")),
                                  forecast_date = target_date,
                                  submission_date = target_date,
                                  target_value = "death")

# Save forecasts ----------------------------------------------------------
source(here("rt-forecast", "functions", "check-dir.R"))
rt_folder <- here("submissions", "rt-forecasts", target_date)
deaths_folder <- here("submissions", "deaths-from-cases", target_date)

check_dir(rt_folder)
check_dir(deaths_folder)

name_forecast <- function(name, type = ""){
  paste0(target_date, "-", name, "-epiforecasts-EpiNow2", type, ".csv")
}
save_forecast <- function(forecast, name, type = "",
                          folder = rt_folder) {
  fwrite(forecast[location_name == name], file.path(folder, name_forecast(name, type)))
}

save_forecast(case_forecast, "Germany", "-case")
save_forecast(case_forecast, "Poland", "-case")
save_forecast(death_forecast, "Germany")
save_forecast(death_forecast, "Poland")
save_forecast(death_from_cases_forecast, "Germany", "-secondary", deaths_folder)
save_forecast(death_from_cases_forecast, "Poland", "-secondary", deaths_folder)

