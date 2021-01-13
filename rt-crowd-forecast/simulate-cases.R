# Packages ----------------------------------------------------------------
library(EpiNow2)
library(data.table)
library(here) 

# Set forecasting date ----------------------------------------------------
#target_date <- Sys.Date() -1 
target_date <- "2021-01-11"

# Get Rt forecasts --------------------------------------------------------
# load
crowd_rt <- fread(here("rt-crowd-forecast", "processed-forecast-data", 
                       paste0(target_date, "-processed-forecasts.csv")))

# dropped redundant columns and get correct shape
crowd_rt <- crowd_rt[, .(location, target = paste0(target_type, "s"), 
                         date = target_end_date, value = round(value, 3))]
crowd_rt[, sample := 1:.N, by = .(location, date, target)]
crowd_rt[location %in% "GM", location := "Germany"]
crowd_rt[location %in% "PL", location := "Poland"]
crowd_rt[]
setorder(crowd_rt, location, target, date)

# Get forecast objects ----------------------------------------------------
load_epinow <- function(target_region, dir, date) { 
  out <- list()
  path <- file.path(dir, target_region, date)
  out$summarised <- readRDS(file.path(path, "summarised_estimates.rds"))
  out$samples <- readRDS(file.path(path, "estimate_samples.rds"))
  out$fit <- readRDS(file.path(path, "model_fit.rds"))
  out$args <- readRDS(file.path(path, "model_args.rds"))
  out$observations <- readRDS(file.path(path, "reported_cases.rds"))
  return(out)
}

crowd_rt