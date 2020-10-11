# Packages ----------------------------------------------------------------
require(EpiNow2)
require(data.table)
require(lubridate)
source(here::here("rt-forecast/functions/dates-to-epiweek.R"))


# forecast_date -> date forecast was made
format_forecast<- function(forecasts, 
                           shrink_per = 0,
                           forecast_date = NULL, 
                           submission_date = NULL,
                           target = NULL) {
  
  # Filter to full epiweeks
  forecasts <- dates_to_epiweek(forecasts)
  forecasts <- forecasts[epiweek_full == TRUE]
  forecasts <- forecasts[,  epiweek := lubridate::epiweek(date)]
  
  # Aggregate to weekly incidence
  weekly_forecasts_inc <- forecasts[,.(value = sum(value, na.rm = TRUE), target_end_date = max(date)), 
                                    by = .(epiweek, region, sample)]
  
  weekly_forecasts_inc <- weekly_forecasts_inc[order(value)][,
                                               .SD[round(.N * shrink_per, 0):round(.N * (1 - shrink_per), 0)],
                                               by = .(epiweek, region)]
  
  # Take quantiles
  weekly_forecasts <- weekly_forecasts_inc[, 
                                           .(value = quantile(deaths, probs = c(0.01, 0.025, seq(0.05, 0.95, by = 0.05), 0.975, 0.99), na.rm=T),
                                             quantile = c(0.01, 0.025, seq(0.05, 0.95, by = 0.05), 0.975, 0.99), 
                                             target_end_date = max(target_end_date), target_value = "inc"), 
                                              by = .(region, epiweek)][order(region, epiweek)]
  
  

  # Add necessary columns
  # dates and types
  forecasts_format <- weekly_forecasts[, `:=`(forecast_date = forecast_date,
                                              submission_date = submission_date,
                                              type = "quantile",
                                              location = region,
                                              horizon = 1 + epiweek - lubridate::epiweek(submission_date))][,
                                   target := paste0(horizon, " wk ahead ", target_value, " ", target)]
  
  # Add point forecasts
  forecasts_point <- forecasts_format[quantile == 0.5]
  forecasts_point <- forecasts_point[, `:=` (type = "point", quantile = NA)]
  forecasts_format <- data.table::rbindlist(list(forecasts_format, forecasts_point))
  
  # drop unnecessary columns
  forecasts_format <- forecasts_format[, !c("horizon", "target_value", "epiweek", "region")]
  
  # Set column order
  forecasts_format <- data.table::setcolorder(forecasts_format,
                                              c("forecast_date", "submission_date", 
                                                "target", "target_end_date", "location", 
                                                "type", "quantile", "value"))
  
  forecasts_format <- forecasts_format[target_end_date > forecast_date]
  return(forecasts_format)
}