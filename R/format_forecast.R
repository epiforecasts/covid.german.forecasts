#' Format Forecasts
#'
#' @param forecasts A data frame of forecasts containing the following variables:
#' `date`, `value`, `region`, and `sample`.
#' @param locations A data frame data dictionary linking locations with location names.
#' Must contain: `location` and `location_name`
#' @param cumulative A data frame but defaults to NULL. Previous cumulative case 
#' counts. Must contain: `target_end_date`, `location`, and `value`.
#' @param forecast_date A date indicating when the forecast took place.
#' @param submission_date A date indicating the target submission date.
#' @param CrI_samples A fraction of the posterior samples to include. Defaults to 1.
#' Can be helpful for models that have more uncertainty than is reasonable.
#' @param target_value Character string indicating the target value name.
#' @return A data frame
#' @export
#' @importFrom data.table rbindlist setorder setcolorder := .N .SD
format_forecast<- function(forecasts, 
                           locations,
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
  forecasts_format <- merge(forecasts_format, locations[, .(location, location_name)], by = "location_name", all.x = TRUE)
  
  # Add point forecasts
  forecasts_point <- forecasts_format[quantile == 0.5]
  forecasts_point <- forecasts_point[, `:=` (type = "point", quantile = NA)]
  forecasts_format <- rbindlist(list(forecasts_format, forecasts_point))
  
  # drop unnecessary columns
  forecasts_format <- forecasts_format[, !c("epiweek", "region")]
  forecasts_format <- forecasts_format[target_end_date > forecast_date]
  forecasts_format <- forecasts_format[, horizon := 1 + as.numeric(target_end_date - min(target_end_date)) / 7]
  forecasts_format <- forecasts_format[, target := paste0(horizon, " wk ahead inc ", target_value)]
  setorder(forecasts_format, location_name, horizon, quantile)
  
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
    forecasts_format <- rbindlist(list(forecasts_format, forecasts_cum))
  }
  
  setorder(forecasts_format, location, target, horizon)
  # Set column order
  forecasts_format <- setcolorder(forecasts_format,
                                  c("location", "location_name", "type", "quantile", 
                                    "horizon", "value", "target_end_date","forecast_date",
                                    "target"))
  
  forecasts_format <- forecasts_format[, c("horizon", "submission_date") := NULL]
  return(forecasts_format)
}