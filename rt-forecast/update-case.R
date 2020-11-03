# Packages -----------------------------------------------------------------
library(EpiNow2, quietly = TRUE)
library(data.table, quietly = TRUE)
library(future, quietly = TRUE)
library(here, quietly = TRUE)
library(lubridate, quietly = TRUE)

# Set target date ---------------------------------------------------------
target_date <- as.character(Sys.Date())

# Update delays -----------------------------------------------------------
generation_time <- readRDS(here::here("rt-forecast", "data", "delays", "generation_time.rds"))
incubation_period <- readRDS(here::here("rt-forecast", "data" ,"delays", "incubation_period.rds"))
onset_to_report <- readRDS(here::here("rt-forecast", "data", "delays", "onset_to_report.rds"))

# Get cases  ---------------------------------------------------------------
cases <- data.table::fread(file.path("data", "daily-incidence-cases-Germany_Poland.csv"))
cases <- cases[, .(region = as.character(location_name), date = as.Date(date), 
                   confirm = value)]
cases <- cases[date >= (max(date) - lubridate::weeks(12))]
data.table::setorder(cases, region, date)

# Run Rt estimation -------------------------------------------------------
regional_epinow(reported_cases = cases,
                future_rt = "estimate", 
                generation_time = generation_time, 
                delays = list(incubation_period, onset_to_report),
                rt_prior = list(mean = 1.1, sd = 0.2),
                samples = 2000, horizon = 30, burn_in = 14, 
                stan_args = list(warmup = 500, 
                                 cores = 4,
                                 control = list(adapt_delta = 0.99,
                                                max_treedepth = 15)),
                output = c("region", "summary", "timing", "samples"),
                target_date = target_date,
                target_folder = here::here("rt-forecast", "data", "samples", "cases"), 
                summary_args = list(summary_dir = here::here("rt-forecast", "data", "summary", 
                                                             "cases", target_date),
                                    all_regions = TRUE),
                logs = "rt-forecast/logs/cases", verbose = TRUE, max_execution_time = Inf)

