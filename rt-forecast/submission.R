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

save_rt <- function(...) {
  save_forecast(model = "-epiforecasts-EpiNow2", 
                folder = rt_folder,
                date = target_date,
                ...)
}

save_rt(case_forecast, "Germany", "GM", "-case")
save_rt(case_forecast, "Poland", "PL", "-case")
save_rt(death_forecast, "Germany", "GM")
save_rt(death_forecast, "Poland", "PL")

save_conv <- function(...) {
  save_forecast(model = "-epiforecasts-EpiNow2_secondary", 
                folder = deaths_folder,
                date = target_date,
                ...)
}
save_conv(death_from_cases_forecast, "Germany", "GM")
save_conv(death_from_cases_forecast, "Poland", "PL")
