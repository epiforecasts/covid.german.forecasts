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
                         date = as.Date(target_end_date), value = round(value, 3))]
crowd_rt[location %in% "GM", location := "Germany"]
crowd_rt[location %in% "PL", location := "Poland"]
crowd_rt[, sample := 1:.N, by = .(location, date, target)]

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


# Simulate cases ----------------------------------------------------------
simulate_crowd_cases <- function(crowd_rt) {
  sims <- map(unique(crowd_rt$location), function(loc) {
    dt <- copy(crowd_rt)[location %in% loc]
    map(unique(dt$target), function(tar) {
      message("Simulating cases for ", tar, " in ", loc)
      # get data for target region
      dt_tar <- copy(dt)[target %in% tar]
      dt_tar <- dt_tar[, .(date, sample, value)]
      
      # load fit EpiNow2 model object
      model <- load_epinow(target_region = loc,
                           dir = here("rt-forecast", "data", "samples", tar),
                           date = target_date)
      
      # extracted estimated Rt and cut to length of forecast
      est_R <- model$samples[variable == "R"]
      est_R <- est_R[, .(date = as.Date(date), sample, value)]
      est_R <- est_R[sample <= max(dt_tar$sample)]
      future_R <- est_R[date > max(dt_tar$date)]
      est_R <- est_R[date < min(dt_tar$date)]
      
      # join estimates and forecast
      forecast_rt <- rbindlist(list(est_R, dt_tar, future_R))
      setorder(forecast_rt, sample, date)
      
      sims <- simulate_infections(model, forecast_rt)
      sims$plot <- plot(sims)
      return(sims)
    })
  })
}

crowd_cases <- simulate_crowd_cases(crowd_rt)

# Save output -------------------------------------------------------------


