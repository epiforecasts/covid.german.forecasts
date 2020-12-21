# Package -----------------------------------------------------------------
library(data.table)
library(EpiNow2)
library(lubridate)
library(here)
library(data.table)

# Dates -------------------------------------------------------------------
target_date <- Sys.Date()
# Get forecasts -----------------------------------------------------------
case_forecast <- suppressWarnings(
  EpiNow2::get_regional_results(results_dir = here("rt-forecast", "data", "samples", "cases"),
                                date = ymd(target_date), forecast = TRUE, 
                                samples = TRUE)$estimated_reported_cases$samples)

death_forecast <- suppressWarnings(
  get_regional_results(results_dir = here("rt-forecast", "data", "samples", "deaths"),
                       date = ymd(target_date), forecast = TRUE, 
                       samples = TRUE)$estimated_reported_cases$samples)

death_from_cases_forecast <- fread(here("rt-forecast", "data", "samples", "deaths-from-cases",
                                         target_date, "samples.csv"))


# Cumulative data ---------------------------------------------------------
cum_cases <- fread(here("data", "weekly-cumulative-cases.csv"))[location_name %in% c("Germany", "Poland")]
cum_deaths <- fread(here("data", "weekly-cumulative-deaths.csv"))[location_name %in% c("Germany", "Poland")]
  
# Format forecasts --------------------------------------------------------
source(here("rt-forecast", "functions", "format-forecast.R"))

case_forecast <- format_forecast(case_forecast[, value := cases], 
                                 cumulative =  cum_cases,
                                 forecast_date = target_date,
                                 submission_date = target_date,
                                 CrI_samples = 0.6,
                                 target_value = "case")

death_forecast <- format_forecast(death_forecast[, value := cases], 
                                  cumulative = cum_deaths,
                                  forecast_date = target_date,
                                  submission_date = target_date,
                                  CrI_samples = 0.6,
                                  target_value = "death")

death_from_cases_forecast <- format_forecast(death_from_cases_forecast, 
                                  cumulative = cum_deaths,
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
save_forecast(death_from_cases_forecast, "Germany", "_secondary", deaths_folder)
save_forecast(death_from_cases_forecast, "Poland", "_secondary", deaths_folder)

