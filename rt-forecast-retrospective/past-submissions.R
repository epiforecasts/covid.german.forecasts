# Package -----------------------------------------------------------------
library(covid.german.forecasts)
library(data.table)
library(EpiNow2)
library(lubridate)
library(here)

# Dates -------------------------------------------------------------------
dates <- as.character(as.Date("2020-10-12") + 7*(0:9))

for (target_date in dates) {
  
  
}

# Get forecasts -----------------------------------------------------------
case_forecast <- suppressWarnings(
  get_regional_results(results_dir = here("rt-forecast-retrospective", "data", "samples", "cases"),
                       date = ymd(target_date), forecast = TRUE,
                       samples = TRUE)$estimated_reported_cases$samples)

death_from_cases_forecast <- fread(here("rt-forecast-retrospective", "data", "samples", "deaths-from-cases",
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

death_from_cases_forecast <- format_forecast(death_from_cases_forecast,
                                             locations = locations,
                                             cumulative = cum_deaths,
                                             forecast_date = target_date,
                                             submission_date = target_date,
                                             target_value = "death")

# Save forecasts ----------------------------------------------------------
rt_folder <- here("submissions", "rt-forecasts-retrospective", target_date)
deaths_folder <- here("submissions", "deaths-from-cases-retrospective", target_date)

check_dir(rt_folder)
check_dir(deaths_folder)

save_rt <- function(...) {
  save_forecast(model = "-epiforecasts-EpiNow2-retrospective", 
                folder = rt_folder,
                date = target_date,
                ...)
}

save_rt(case_forecast, "Germany", "GM", "-case")
save_rt(case_forecast, "Poland", "PL", "-case")

save_conv <- function(...) {
  save_forecast(model = "-epiforecasts-EpiNow2_secondary-retrospective", 
                folder = deaths_folder,
                date = target_date,
                ...)
}
save_conv(death_from_cases_forecast, "Germany", "GM")
save_conv(death_from_cases_forecast, "Poland", "PL")
