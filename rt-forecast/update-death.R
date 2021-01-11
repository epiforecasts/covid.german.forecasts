# Packages -----------------------------------------------------------------
library(EpiNow2, quietly = TRUE)
library(data.table, quietly = TRUE)
library(future, quietly = TRUE)
library(here, quietly = TRUE)
library(lubridate, quietly = TRUE)

# Set target date ---------------------------------------------------------
target_date <- as.character(Sys.Date()) 

# Update delays -----------------------------------------------------------
generation_time <- readRDS(here("rt-forecast", "data", "delays", "generation_time.rds"))
incubation_period <- readRDS(here("rt-forecast", "data", "delays", "incubation_period.rds"))
onset_to_death <- readRDS(here("rt-forecast", "data", "delays", "onset_to_death.rds"))

# Get cases  ---------------------------------------------------------------
deaths <- fread(file.path("data", "daily-incidence-deaths.csv"))
deaths <- deaths[, .(region = as.character(location_name), date = as.Date(date), 
                   confirm = value)]
deaths <- deaths[confirm < 0, confirm := 0]
deaths <- deaths[date >= (max(date) - lubridate::weeks(12))]
setorder(deaths, region, date)

# Set up parallel execution -----------------------------------------------
no_cores <- setup_future(deaths)

# Run Rt estimation -------------------------------------------------------
# default Rt settings
rt <- opts_list(rt_opts(prior = list(mean = 1.1, sd = 0.2), 
                        future = "latest"), deaths)
# add population adjustment for each country
rt$Germany$pop <- 80000000
rt$Poland$pop <- 40000000
regional_epinow(reported_cases = deaths,
                generation_time = generation_time, 
                delays = delay_opts(incubation_period, onset_to_death),
                rt = rt,
                stan = stan_opts(samples = 2000, warmup = 250, 
                                 chains = 4, cores = no_cores), 
                obs = obs_opts(scale = list(mean = 0.005, sd = 0.0025)),
                horizon = 30,
                output = c("region", "summary", "timing", "samples", "fit"),
                target_date = target_date,
                target_folder = here("rt-forecast", "data", "samples", "deaths"), 
                summary_args = list(
                  summary_dir = here("rt-forecast", "data", "summary", "deaths", target_date)),
                logs = "rt-forecast/logs/deaths",
                verbose = TRUE)

plan("sequential")
