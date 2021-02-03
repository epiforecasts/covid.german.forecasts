# Package -----------------------------------------------------------------
library(covid.german.forecasts)
library(data.table)
library(EpiNow2)
library(lubridate)
library(here)

# Dates -------------------------------------------------------------------
target_date <- latest_weekday(char = TRUE)

# Get forecasts -----------------------------------------------------------
case_forecast <- suppressWarnings(
  get_regional_results(results_dir = here("rt-forecast", "data", "samples", "cases"),
                       date = ymd(target_date), forecast = TRUE, 
                       samples = TRUE)$estimated_reported_cases$samples)

death_forecast <- suppressWarnings(
  get_regional_results(results_dir = here("rt-forecast", "data", "samples", "deaths"),
                       date = ymd(target_date), forecast = TRUE, 
                       samples = TRUE)$estimated_reported_cases$samples)

death_from_cases_forecast <- fread(here("rt-forecast", "data", "samples", "deaths-from-cases",
                                         target_date, "samples.csv"))

# Cumulative data ---------------------------------------------------------
cum_cases <- fread(here("data-raw", "weekly-cumulative-cases.csv"))
cum_deaths <- fread(here("data-raw", "weekly-cumulative-deaths.csv"))
  
# Format forecasts --------------------------------------------------------
case_forecast <- format_forecast(case_forecast[, value := cases], 
                                 locations = locations,
                                 cumulative =  cum_cases,
                                 forecast_date = target_date,
                                 submission_date = target_date,
                                 CrI_samples = 0.8,
                                 target_value = "case")

death_forecast <- format_forecast(death_forecast[, value := cases], 
                                  locations = locations,
                                  cumulative = cum_deaths,
                                  forecast_date = target_date,
                                  submission_date = target_date,
                                  CrI_samples = 0.8,
                                  target_value = "death")

death_from_cases_forecast <- format_forecast(death_from_cases_forecast, 
                                             locations = locations,
                                             cumulative = cum_deaths,
                                             forecast_date = target_date,
                                             submission_date = target_date,
                                             target_value = "death")

# Save forecasts ----------------------------------------------------------
rt_folder <- here("submissions", "rt-forecasts", target_date)
deaths_folder <- here("submissions", "deaths-from-cases", target_date)

check_dir(rt_folder)
check_dir(deaths_folder)

name_forecast <- function(name, type = ""){
  paste0(target_date, "-", name, "-epiforecasts-EpiNow2", type, ".csv")
}
save_forecast <- function(forecast, name, loc, type = "",
                          folder = rt_folder) {
  fwrite(forecast[grepl(loc, location)], file.path(folder, name_forecast(name, type)))
}

save_forecast(case_forecast, "Germany", "GM", "-case")
save_forecast(case_forecast, "Poland", "PL", "-case")
save_forecast(death_forecast, "Germany", "GM")
save_forecast(death_forecast, "Poland", "PL")
save_forecast(death_from_cases_forecast, "Germany", "GM", "_secondary", deaths_folder)
save_forecast(death_from_cases_forecast, "Poland", "PL", "_secondary", deaths_folder)

