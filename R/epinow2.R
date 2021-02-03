#' Load a EpiNow2 Model
#'
#' @param target_region A dataframe containing a forecast as produced by
#'  `format_forecast`.
#' @param dir Character string indicating the location name.
#' @param date Character vecetor, indicates target regions.
#' @return A EpiNow2 model
#' @export
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
#' Simulate Cases using Crowd Reproduction Number estimates
#'
#' @param crowd_rt A data frame containing the following variables:
#'  `location`, `target`, `date`, `value`, and `sample`.
#' @param model_dir A character string giving the path to the directory 
#' in which the saved EpiNow2 model objects are stored.
#' @param target_date A character string indicating the target date.
#' @return A list containing the output from EpiNow2::simulate_infections
#'  named by target and location.
#' @export
#' @importFrom EpiNow2 simulate_infections
#' @importFrom data.table copy rbindlist setorder
#' @importFrom purrr map
simulate_crowd_cases <- function(crowd_rt, model_dir, target_date) {
  locs <- unique(crowd_rt$location)
  sims <- map(locs, function(loc) {
    dt <- copy(crowd_rt)[location %in% loc]
    tars <- unique(dt$target)
    sims <- map(tars, function(tar) {
      message("Simulating: ", tar, " in ", loc)
      # get data for target region
      dt_tar <- copy(dt)[target %in% tar]
      dt_tar <- dt_tar[, .(date, sample, value)]

      # load fit EpiNow2 model object
      model <- load_epinow(
        target_region = loc,
        dir = file.path(model_dir, tar),
        date = target_date
      )

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
#' Extract Simulated Samples
#'
#' @param output A list as output by `simulate_crowd_cases`.
#' @param target A character string indicating the target.
#' @return A dataframe of sampled values by date.
#' @export
#' @importFrom data.table := setorder rbindlist
#' @importFrom purrr map
extract_samples <- function(output, target) {
  samples <- map(names(output), function(loc) {
    dt <- output[[loc]][[target]]$samples[, region := loc]
    dt <- dt[variable %in% "reported_cases"]
    dt <- dt[, .(region, date, sample, value)]
    setorder(dt, region, date, sample)
    return(dt)
  })
  samples <- rbindlist(samples)
  return(samples)
}