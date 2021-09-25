# Packages -----------------------------------------------------------------
library(covid.german.forecasts)
library(EpiNow2, quietly = TRUE)
library(data.table, quietly = TRUE)
library(future, quietly = TRUE)
library(here, quietly = TRUE)
library(lubridate, quietly = TRUE)

# Set target dates ---------------------------------------------------------
dates <- as.character(as.Date("2020-10-12") + 7*(0:9))

# Update delays -----------------------------------------------------------
generation_time <- readRDS(here("rt-forecast", "data", "delays", "generation_time.rds"))
incubation_period <- readRDS(here("rt-forecast", "data" ,"delays", "incubation_period.rds"))
onset_to_report <- readRDS(here("rt-forecast", "data", "delays", "onset_to_report.rds"))

for (target_date in dates) {
  # Get cases  ---------------------------------------------------------------
  cases <- fread(file.path("rt-forecast", "data", "summary", 
                           "cases", target_date, "reported_cases.csv"))
  cases <- cases[region %in% c("Germany", "Poland")]
  cases[, date := as.Date(date)]
  setorder(cases, region, date)
  
  # Set up parallel execution -----------------------------------------------
  no_cores <- setup_future(cases)
  
  # Run Rt estimation -------------------------------------------------------
  
  if (target_date <= "2020-11-09") {
    future <- "estimate"
  } else {
    future <- "latest"
  }
  
  rt <- opts_list(rt_opts(prior = list(mean = 1.1, sd = 0.2), future = future), cases)
  # add population adjustment for each country
  loc_names <- names(rt)
  loc_names <- c("Germany", "Poland")
  rt <- lapply(loc_names,  function(loc) {
    rt_loc <- rt[[loc]]
    rt_loc$pop <- locations[location_name %in% loc, ]$population
    return(rt_loc)
  })
  names(rt) <- loc_names
  
  regional_epinow(reported_cases = cases,
                  generation_time = generation_time, 
                  delays = delay_opts(incubation_period, onset_to_report),
                  rt = rt,
                  stan = stan_opts(samples = 2000, warmup = 250, 
                                   chains = 4, cores = no_cores),
                  obs = obs_opts(scale = list(mean = 0.5, sd = 0.05)), #(mean = 0.25, sd = 0.05)), from 2020-12-07 on
                  horizon = 30,
                  output = c("region", "summary", "timing", "samples", "fit"),
                  target_date = target_date,
                  target_folder = here("rt-forecast-retrospective", "data", "samples", "cases"), 
                  summary_args = list(summary_dir = here("rt-forecast-retrospective", 
                                                         "data", "summary", 
                                                         "cases", target_date),
                                      all_regions = TRUE),
                  logs = "rt-forecast-retrospective/logs/cases", verbose = TRUE)
  
  plan("sequential")
}


