# Google sheets authentification -----------------------------------------------
# not sure this works as intended
sheets_auth(token = drive_token())
spread_sheet <- "1xdJDgZdlN7mYHJ0D0QbTcpiV9h1Dmga4jVoAg5DhaKI"


# setup ------------------------------------------------------------------------
submission_date <- Sys.Date()


# load forecasts from Google Sheet and store locally ---------------------------
forecasts <- googlesheets4::read_sheet(ss = spread_sheet)

data.table::fwrite(forecasts, 
                   here::here("human-forecasts", "raw-forecast-data", 
                              paste0(submission_date, "-raw-forecasts.csv")))

# empty google sheet
cols <- data.frame(matrix(ncol = 12, nrow = 0))
names(cols) <- names(forecasts)
googlesheets4::write_sheet(data = cols, 
                           ss = spread_sheet, 
                           sheet = "predictions")



# filter forecasts -------------------------------------------------------------
# use only the latest forecast from a given forecaster
filtered_forecasts <- forecasts %>%
  dplyr::group_by(forecaster, location, inc, type) %>%
  dplyr::filter(forecast_time == max(forecast_time))
# maybe filter by some sanity check again
# i.e. quantiles must be monotonously increasin


# make median ensemble ---------------------------------------------------------
# fit distribution to quantiles to obtain more quantiles. Then make median ensemble
median_ensemble <- filtered_forecasts %>%
  dplyr::group_by(location, location_name, inc, type, quantile, horizon) %>%
  dplyr::summarise(value = median(value), 
                   target_end_date = unique(target_end_date)) %>%
  dplyr::ungroup()

# missinng: fit distribution and add more quantiles


# format ensemble for submission -----------------------------------------------
forecast_submission <- median_ensemble %>%
  dplyr::mutate(forecast_date = Sys.Date(), 
                inc = ifelse(inc == "incident", "inc", "cum"),
                type = ifelse(type == "deaths", "death", "case"),
                target = paste(horizon, "wk ahead", inc, type, sep = " "), 
                target_end_date = as.Date(target_end_date), 
                type = "quantile") %>%
  dplyr::select(-inc) %>%
  dplyr::arrange(forecast_date, target, target_end_date, location, type, quantile, value, location_name)

forecast_submission <- dplyr::bind_rows(forecast_submission, 
                 forecast_submission %>%
                   dplyr::filter(quantile == 0.5) %>%
                   dplyr::mutate(type = "point", 
                                 quantile = NA))

# missing: make cumulative 



# write submission files -------------------------------------------------------
forecast_submission %>%
  dplyr::filter(location_name %in% "Germany", 
                grepl("death", target)) %>%
  data.table::fwrite(here::here("submissions", "human-forecasts",
                                paste0(submission_date, 
                                       "-Germany-EpiExpert.csv")))

forecast_submission %>%
  dplyr::filter(location_name %in% "Germany", 
                grepl("case", target)) %>%
  data.table::fwrite(here::here("submissions", "human-forecasts",
                                paste0(submission_date, 
                                       "-Germany-EpiExpert-case.csv")))

forecast_submission %>%
  dplyr::filter(location_name %in% "Poland", 
                grepl("death", target)) %>%
  data.table::fwrite(here::here("submissions", "human-forecasts",
                                paste0(submission_date, 
                                       "-Poland-EpiExpert.csv")))

forecast_submission %>%
  dplyr::filter(location_name %in% "Poland", 
                grepl("case", target)) %>%
  data.table::fwrite(here::here("submissions", "human-forecasts",
                                paste0(submission_date, 
                                       "-Poland-EpiExpert-case.csv")))

