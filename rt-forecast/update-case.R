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
                generation_time = generation_time, 
                delays = delay_opts(incubation_period, onset_to_report),
                rt = rt_opts(prior = list(mean = 1.1, sd = 0.2), 
                             future = "latest"),
                stan = stan_opts(samples = 2000, warmup = 500, cores = 4),
                horizon = 30,
                output = c("region", "summary", "timing", "samples"),
                target_date = target_date,
                target_folder = here::here("rt-forecast", "data", "samples", "cases"), 
                summary_args = list(summary_dir = here::here("rt-forecast", "data", "summary", 
                                                             "cases", target_date),
                                    all_regions = TRUE),
                logs = "rt-forecast/logs/cases", verbose = TRUE)

