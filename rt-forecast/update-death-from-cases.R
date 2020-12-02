# Packages -----------------------------------------------------------------
library(EpiNow2, quietly = TRUE)
library(data.table, quietly = TRUE)
library(here, quietly = TRUE)
library(future, quietly = TRUE)
library(devtools, quietly = TRUE)

# Set target date ---------------------------------------------------------
target_date <- "2020-11-30" #as.character(Sys.Date()) 

# Get Observations --------------------------------------------------------
deaths <- fread(file.path("data", "daily-incidence-deaths-Germany_Poland.csv"))
cases <- fread(file.path("data", "daily-incidence-cases-Germany_Poland.csv"))
deaths <- deaths[, secondary := value][, value := NULL]
cases <- cases[, primary := value][, value := NULL]
observations <- merge(cases, deaths, by = c("location", "location_name", "date"))
observations <- observations[, .(region = as.character(location_name), date = as.Date(date), 
                                 primary, secondary)]
observations <- observations[date >= (max(date) - 8*7)][date <= target_date]
setorder(observations, region, date)

# Get case forecasts ------------------------------------------------------
case_forecast <- suppressWarnings(
  EpiNow2::get_regional_results(results_dir = here::here("rt-forecast", "data", "samples", "cases"),
                                date = lubridate::ymd(target_date),
                                forecast = TRUE, samples = TRUE)$estimated_reported_cases$samples)

# Forecast deaths from cases ----------------------------------------------
# set up parallel options
options(mc.cores = 4)
plan("sequential")

# load the prototype regional_secondary function
source_gist("https://gist.github.com/seabbs/4dad3958ca8d83daca8f02b143d152e6")

# run across Poland and Germany specifying options for estimate_secondary
forecast <- regional_secondary(observations, case_forecast,
                               delays = delay_opts(list(mean = 2.5, mean_sd = 0.2, 
                                                        sd = 0.47, sd_sd = 0.1, max = 30)),
                               secondary = secondary_opts(type = "incidence"),
                               obs = obs_opts(scale = list(mean = 0.01, sd = 0.0025)),
                               burn_in = as.integer(max(observations$date) - min(observations$date)) - 4*7,
                               control = list(adapt_delta = 0.95, max_treedepth = 15))



