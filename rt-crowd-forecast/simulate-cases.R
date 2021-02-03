# Packages ----------------------------------------------------------------
library(covid.german.forecasts)
library(EpiNow2)
library(data.table)
library(here) 
library(purrr)
library(ggplot2)
library(lubridate)

# Set forecasting date ----------------------------------------------------
target_date <- floor_date(Sys.Date(), unit = "week", 1)

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
  locs <- unique(crowd_rt$location)
  sims <- map(locs, function(loc) {
    dt <- copy(crowd_rt)[location %in% loc]
    tars <- unique(dt$target)
    sims <- map(tars, function(tar) {
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
      est_R <- est_R[date < min(dt_tar$date)]
      
      # join estimates and forecast
      forecast_rt <- rbindlist(list(est_R, dt_tar))
      setorder(forecast_rt, sample, date)
      
      sims <- simulate_infections(model, forecast_rt)
      sims$plot <- plot(sims)
      return(sims)
    })
    names(sims) <- tars
    return(sims)
  })
  names(sims) <- locs
  return(sims)
}

simulations <- simulate_crowd_cases(crowd_rt)

# Extract output ----------------------------------------------------------
# extract samples
extract_samples <- function(output, target) {
  samples <- map(names(output), function(loc) {
    dt <- output[[loc]][[target]]$samples[, region := loc][variable %in% "reported_cases"]
    dt <- dt[, .(region, date, sample, value)]
    setorder(dt, region, date, sample) 
    return(dt)
    })
  
  samples <- rbindlist(samples)
  return(samples)
}
crowd_cases <- extract_samples(simulations, "cases")
crowd_deaths <- extract_samples(simulations, "deaths")

# save output
plot_dir <- here("rt-crowd-forecast", "data", "plots", target_date)
check_dir(plot_dir)

walk(names(simulations), function(loc) {
  walk(names(simulations[[1]]), function(tar) {
    ggsave(paste0(loc, "-", tar, ".png"), 
                  simulations[[loc]][[tar]]$plot,
           path = plot_dir, height = 9, width = 9)
  })
})

# Submission --------------------------------------------------------------
# Cumulative data
cum_cases <- fread(here("data-raw", "weekly-cumulative-cases.csv"))
cum_deaths <- fread(here("data-raw", "weekly-cumulative-deaths.csv"))

crowd_cases <- format_forecast(crowd_cases,
                               locations = locations, 
                               cumulative = cum_cases[location_name %in% c("Germany", "Poland")],
                               forecast_date = target_date,
                               submission_date = target_date,
                               target_value = "case")

crowd_deaths <- format_forecast(crowd_deaths, 
                                locations = locations,
                                cumulative = cum_deaths[location_name %in% c("Germany", "Poland")],
                                forecast_date = target_date,
                                submission_date = target_date,
                                target_value = "death")

# save forecasts
crowd_folder <- here("submissions", "crowd-rt-forecasts", target_date)
check_dir(crowd_folder)

name_forecast <- function(name, type = ""){
  paste0(target_date, "-", name, "-epiforecasts-EpiExpert_Rt", type, ".csv")
}
save_forecast <- function(forecast, name, loc, type = "",
                          folder = crowd_folder) {
  fwrite(forecast[grepl(loc, location)], file.path(folder, name_forecast(name, type)))
}
save_forecast(crowd_cases, "Germany", "GM", "-case")
save_forecast(crowd_cases, "Poland", "PL", "-case")
save_forecast(crowd_deaths, "Germany", "GM")
save_forecast(crowd_deaths, "Poland", "PL")