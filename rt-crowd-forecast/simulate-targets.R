# Packages ----------------------------------------------------------------
library(covid.german.forecasts)
library(EpiNow2)
library(data.table)
library(here)
library(purrr)
library(ggplot2)
library(lubridate)
library(devtools)

# parallel
options(mc.cores = 4)
# Set forecasting date ----------------------------------------------------
target_date <- latest_weekday()

# Get Rt forecasts --------------------------------------------------------
crowd_rt <- fread(
  here("rt-crowd-forecast", "processed-forecast-data",
       paste0(target_date, "-processed-forecasts.csv")
))

# dropped redundant columns and get correct shape
crowd_rt <- crowd_rt[, .(location,
  date = as.Date(target_end_date),
  value = round(value, 3)
)]
crowd_rt[location %in% "GM", location := "Germany"]
crowd_rt[location %in% "PL", location := "Poland"]
crowd_rt[, sample := 1:.N, by = .(location, date)]
crowd_rt[, target := "cases"]

# Simulate cases ----------------------------------------------------------
simulations <- simulate_crowd_cases(
  crowd_rt,
  model_dir = here("rt-forecast", "data", "samples"),
  target_date = target_date
)

# Extract output ----------------------------------------------------------
crowd_cases <- extract_samples(simulations, "cases")

# save output
plot_dir <- here("rt-crowd-forecast", "data", "plots", target_date)
check_dir(plot_dir)

walk(names(simulations), function(loc) {
  walk(names(simulations[[1]]), function(tar) {
    ggsave(paste0(loc, "-", tar, ".png"),
      simulations[[loc]][[tar]]$plot,
      path = plot_dir, height = 9, width = 9
    )
  })
})

# Simulate deaths --------------------------------------------------------------
observations <- get_observations(dir = here("data-raw"), target_date,
                                 locs = c("Germany", "Poland"))

# Forecast deaths from cases ----------------------------------------------
source_gist("https://gist.github.com/seabbs/4dad3958ca8d83daca8f02b143d152e6")

# run across Poland and Germany specifying
# options for estimate_secondary (EpiNow2)
deaths_forecast <- regional_secondary(
  observations, crowd_cases[, cases := value],
  delays = delay_opts(list(
    mean = 2.5, mean_sd = 0.5,
    sd = 0.47, sd_sd = 0.2, max = 30
  )),
  return_fit = FALSE,
  secondary = secondary_opts(type = "incidence"),
  obs = obs_opts(scale = list(mean = 0.01, sd = 0.02)),
  burn_in = as.integer(max(observations$date) - min(observations$date)) - 3 * 7,
  control = list(adapt_delta = 0.98, max_treedepth = 15),
  verbose = FALSE
)

# Submission --------------------------------------------------------------
# Cumulative data
cum_cases <- fread(here("data-raw", "weekly-cumulative-cases.csv"))
cum_deaths <- fread(here("data-raw", "weekly-cumulative-deaths.csv"))

crowd_cases <- format_forecast(crowd_cases,
  locations = locations,
  cumulative = cum_cases[location_name %in% c("Germany", "Poland")],
  forecast_date = target_date,
  submission_date = target_date,
  target_value = "case"
)

crowd_deaths <- format_forecast(deaths_forecast$samples,
  locations = locations,
  cumulative = cum_deaths[location_name %in% c("Germany", "Poland")],
  forecast_date = target_date,
  submission_date = target_date,
  target_value = "death"
)

# save forecasts
crowd_folder <- here("submissions", "crowd-rt-forecasts", target_date)
check_dir(crowd_folder)

save_crowd_rt <- function(...) {
  save_forecast(model = "-epiforecasts-EpiExpert_Rt", 
                folder = crowd_folder,
                date = target_date,
                 ...)
}
save_crowd_rt(crowd_cases, "Germany", "GM", "-case")
save_crowd_rt(crowd_cases, "Poland", "PL", "-case")
save_crowd_rt(crowd_deaths, "Germany", "GM")
save_crowd_rt(crowd_deaths, "Poland", "PL")