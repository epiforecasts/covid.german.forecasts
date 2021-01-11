# Packages ----------------------------------------------------------------
library(EpiNow2)
library(data.table)
library(lubridate)
library(here)
source(here::here("functions/dates-to-epiweek.R"))
 
format_forecast<- function(forecasts, 
                           cumulative = NULL,
                           forecast_date = NULL, 
                           submission_date = NULL,
                           CrI_samples = 1,
                           target_value = NULL) {
  
  # Filter to full epiweeks
  forecasts <- dates_to_epiweek(forecasts)
  forecasts <- forecasts[epiweek_full == TRUE]
  forecasts <- forecasts[,  epiweek := lubridate::epiweek(date)]
  
  # Aggregate to weekly incidence
  weekly_forecasts_inc <- forecasts[,.(value = sum(value, na.rm = TRUE), target_end_date = max(date)), 
                                    by = .(epiweek, region, sample)]
  
  shrink_per <- (1 - CrI_samples) / 2
  weekly_forecasts_inc <- weekly_forecasts_inc[order(value)][,
                                               .SD[round(.N * shrink_per, 0):round(.N * (1 - shrink_per), 0)],
                                               by = .(epiweek, region)]
  
  # Take quantiles
  weekly_forecasts <- weekly_forecasts_inc[, 
                                           .(value = quantile(value, probs = c(0.01, 0.025, seq(0.05, 0.95, by = 0.05), 0.975, 0.99), na.rm=T),
                                             quantile = c(0.01, 0.025, seq(0.05, 0.95, by = 0.05), 0.975, 0.99), 
                                             target_end_date = max(target_end_date)), 
                                              by = .(region, epiweek)][order(region, epiweek)]
  
  # Add necessary columns
  forecasts_format <- weekly_forecasts[, `:=`(forecast_date = forecast_date,
                                              submission_date = submission_date,
                                              type = "quantile",
                                              location_name = region)]
  
  ## add in location from cumulative
  locations <- unique(data.table::copy(cumulative)[, .(location, location_name)])
  forecasts_format <- merge(forecasts_format, locations, by = "location_name", all.x = TRUE)
  
  # Add point forecasts
  forecasts_point <- forecasts_format[quantile == 0.5]
  forecasts_point <- forecasts_point[, `:=` (type = "point", quantile = NA)]
  forecasts_format <- data.table::rbindlist(list(forecasts_format, forecasts_point))
  
  # drop unnecessary columns
  forecasts_format <- forecasts_format[, !c("epiweek", "region")]
  forecasts_format <- forecasts_format[target_end_date > forecast_date]
  forecasts_format <- forecasts_format[, horizon := 1 + as.numeric(target_end_date - min(target_end_date)) / 7]
  forecasts_format <- forecasts_format[, target := paste0(horizon, " wk ahead inc ", target_value)]
  data.table::setorder(forecasts_format, location_name, horizon, quantile)
  
  # cumulative forecast 
  if (!is.null(cumulative)) {
    cumulative <- cumulative[target_end_date < forecast_date]
    cumulative <- cumulative[, .SD[target_end_date == max(target_end_date)], by = location]
    cumulative <- cumulative[, .(location, cum_value = value)]
    forecasts_cum <- data.table::copy(forecasts_format)[cumulative, on = "location"]
    forecasts_cum <- forecasts_cum[order(horizon)][, value := cumsum(value), 
                                                by = .(location, type, quantile)]
    forecasts_cum <- forecasts_cum[, value := value + cum_value][, cum_value := NULL]
    forecasts_cum <- forecasts_cum[, target := paste0(horizon, " wk ahead cum ", target_value)]
    forecasts_format <- data.table::rbindlist(list(forecasts_format, forecasts_cum))
  }
  
  data.table::setorder(forecasts_format, location, target, horizon)
  # Set column order
  forecasts_format <- data.table::setcolorder(forecasts_format,
                                              c("location", "location_name", "type", 
                                                "quantile", "horizon", "value", "target_end_date",
                                                "forecast_date", "target"))
  
  forecasts_format <- forecasts_format[, c("horizon", "submission_date") := NULL]
  return(forecasts_format)
}