# Setup --------------------------------------------------------------------
## set core usage (note cores > 4 will have no effect on runtimes)
options(mc.cores = 4)

# Packages -----------------------------------------------------------------
library(EpiNow2, quietly = TRUE)
library(data.table, quietly = TRUE)
library(here, quietly = TRUE)

# Set target date ---------------------------------------------------------
target_date <- "2020-11-30" #as.character(Sys.Date()) 

# Get Observations --------------------------------------------------------
deaths <- fread(file.path("data", "daily-incidence-deaths-Germany_Poland.csv"))
cases <- fread(file.path("data", "daily-incidence-cases-Germany_Poland.csv"))
deaths <- deaths[, secondary := value][, value := NULL]
cases <- cases[, primary := value][, value := NULL]
obs <- merge(cases, deaths, by = c("location", "location_name", "date"))
obs <- obs[, .(region = as.character(location_name), date = as.Date(date), 
                  primary, secondary)]
obs <- obs[date >= (max(date) - 8*7)][date <= target_date]
setorder(obs, region, date)

# Get case forecasts ------------------------------------------------------
case_forecast <- suppressWarnings(
  EpiNow2::get_regional_results(results_dir = here::here("rt-forecast", "data", "samples", "cases"),
                                date = lubridate::ymd(target_date),
                                forecast = TRUE, samples = TRUE)$estimated_reported_cases$samples)



# Forecast deaths from cases ----------------------------------------------
regional_secondary <- function(obs, case_forecast, target_region) {
  # filter for target region
  target_obs <- obs[region == target_region][, region := NULL]
  pred_cases <- case_forecast[region == target_region && type == "gp_rt"]
  pred_cases <- pred_cases[, .(date, sample, value = cases)]
  pred_cases <- pred_cases[date > max(target_obs$date)]
  
  # estimate relationship fitting to just the last month of data
  cases_to_deaths <- estimate_secondary(target_obs, 
                                        delays = delay_opts(list(mean = 2.5, mean_sd = 0.2, 
                                                                 sd = 0.47, sd_sd = 0.1, max = 30)),
                                        secondary = secondary_opts(type = "incidence"),
                                        obs = obs_opts(scale = list(mean = 0.01, sd = 0.0025)),
                                        burn_in = nrow(target_obs) - 4*7,
                                        control = list(adapt_delta = 0.95, max_treedepth = 15))
  plot(cases_to_deaths)

  deaths_forecast <- forecast_secondary(cases_to_deaths, pred_cases)
  plot(deaths_forecast, from = max(target_obs$date) - 7)
}

