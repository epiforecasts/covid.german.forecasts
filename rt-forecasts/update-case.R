# Packages -----------------------------------------------------------------
library(EpiNow2, quietly = TRUE)
library(data.table, quietly = TRUE)
library(future, quietly = TRUE)
library(here, quietly = TRUE)
library(lubridate, quietly = TRUE)
# Set target date ---------------------------------------------------------
target_date <- as.character(Sys.Date())

# Update delays -----------------------------------------------------------
generation_time <- readRDS(here::here("rt-forecast", "delays", "generation_time.rds"))
incubation_period <- readRDS(here::here("rt-forecast", "delays", "incubation_period.rds"))
onset_to_report <- readRDS(here::here("data", "delays", "onset_to_report.rds"))

# Get cases  ---------------------------------------------------------------
cases <- data.table::fread(file.path("data", "daily-incidence-cases-Germany_Poland.csv"))
cases <- cases[, .(region = as.character(location_name), date = as.Date(date), 
                   confirm = value)]
cases <- cases[date >= (max(date) - lubridate::weeks(8))]
data.table::setorder(cases, region, date)

# Set up parallel ---------------------------------------------------------
setup_future(cases)

# Run Rt estimation -------------------------------------------------------
regional_epinow(reported_cases = cases, fixed_future_rt = TRUE, 
                generation_time = generation_time, 
                delays = list(incubation_period, onset_to_report),
                samples = 4000, horizon = 30, burn_in = 14, 
                stan_args = list(warmup = 1000, 
                                 control = list(adapt_delta = 0.95,
                                                max_treedepth = 15)), 
                output = c("region", "summary", "timing"),
                target_date = target_date,
                target_folder = here::here("rt-forecast", "samples", "cases"), 
                summary_args = list(summary_dir = here::here("rt-forecast", "summary", 
                                                             "cases", target_date),
                                    all_regions = TRUE),
                logs = "logs", future = TRUE, max_execution_time = 60 * 60)

