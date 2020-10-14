# Google sheets authentification -----------------------------------------------
# not sure this works as intended


library(googledrive)
library(googlesheets4)

options(gargle_oauth_cache = ".secrets")
drive_auth(cache = ".secrets", email = "epiforecasts@gmail.com")
sheets_auth(token = drive_token())

spread_sheet <- "1xdJDgZdlN7mYHJ0D0QbTcpiV9h1Dmga4jVoAg5DhaKI"
identification_sheet <- "1GJ5BNcN1UfAlZSkYwgr1-AxgsVA2wtwQ9bRwZ64ZXRQ"


# setup ------------------------------------------------------------------------
submission_date <- Sys.Date()


# load identifier from Google Sheet --------------------------------------------
ids <- googlesheets4::read_sheet(ss = identification_sheet)

# add identifiers
ids <- ids %>% 
  dplyr::rowwise() %>%
  dplyr::mutate(identifier = paste(forecaster, email, sep = "_")) %>%
  dplyr::ungroup() %>%
  unique()

# find potential problems
# see whether forecaster is unique
ids <- ids %>%
  dplyr::group_by(forecaster) %>%
  dplyr::mutate(forecaster_n = dplyr::n()) %>%
  dplyr::ungroup()

# see whether identifier is unique
ids <- ids %>%
  dplyr::group_by(identifier) %>%
  dplyr::mutate(identifier_n = dplyr::n()) %>%
  dplyr::ungroup()

# add problem flag
ids <- ids %>%
  dplyr::mutate(potential_problem = ifelse(identifier_n == forecaster_n, FALSE, TRUE))
  
  
# get existing ids
existing_ids <- ids %>%
  dplyr::filter(!is.na(forecaster_id)) %>%
  dplyr::select(forecaster, forecaster_id) %>%
  unique()

# merge with data
ids <- dplyr::full_join(ids %>%
                          dplyr::select(-forecaster_id), 
                        existing_ids)

# give new ids to the forecasters that do not have an ID yet
ids <- ids %>%
  dplyr::rowwise() %>%
  dplyr::mutate(forecaster_id = ifelse(is.na(forecaster_id), 
                                       round(runif(1) * 1000000), 
                                       forecaster_id)) %>%
  dplyr::ungroup() %>%
  unique()

# write updated sheet
googlesheets4::write_sheet(data = ids, 
                           ss = identification_sheet, 
                           sheet = "ids")

all_ids <- ids %>%
  dplyr::select(forecaster = forecaster_hash, forecaster_id) %>%
  unique()







# load forecasts from Google Sheet ---------------------------------------------
forecasts <- googlesheets4::read_sheet(ss = spread_sheet)

# merge with ids
forecasts <- dplyr::full_join(forecasts, all_ids)

# write raw forecasts
data.table::fwrite(forecasts %>%
                     dplyr::select(- forecaster),
                   here::here("human-forecasts", "raw-forecast-data", 
                              paste0(submission_date, "-raw-forecasts.csv")))

# filter forecasts -------------------------------------------------------------
# use only the latest forecast from a given forecaster
filtered_forecasts <- forecasts %>%
  dplyr::group_by(forecaster, location, inc, type) %>%
  dplyr::filter(forecast_time == max(forecast_time))
# maybe filter by some sanity check again
# i.e. quantiles must be monotonously increasing


# obtain quantiles
quantile_grid <- c(0.01, 0.025, seq(0.05, 0.95, 0.05), 0.975, 0.99)

forecast_quantiles <- filtered_forecasts %>%
  dplyr::rowwise() %>%
  dplyr::mutate(quantile = list(quantile_grid),
                value = list(qlnorm(quantile_grid, meanlog = log(median), 
                                   sdlog = shape_log_normal))) %>%
  tidyr::unnest(cols = c(quantile, value)) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(type = ifelse(type == "cases", "case", "death"), 
                target = paste0(horizon, " wk ahead inc ", type), 
                type = "quantile")


# empty google sheet
# cols <- data.frame(matrix(ncol = ncol(forecasts), nrow = 0))
# names(cols) <- names(forecasts)
# googlesheets4::write_sheet(data = cols, 
#                            ss = spread_sheet, 
#                            sheet = "predictions")





# make median ensemble ---------------------------------------------------------
# fit distribution to quantiles to obtain more quantiles. Then make median ensemble
median_ensemble <- forecast_quantiles %>%
  dplyr::group_by(location, location_name, target, type, quantile, horizon, target_end_date) %>%
  dplyr::summarise(value = median(value)) %>%
  dplyr::ungroup() %>%
  dplyr::select(target, target_end_date, location, type, quantile, value, location_name)

# missinng: fit distribution and add more quantiles


# format ensemble for submission -----------------------------------------------
# forecast_submission <- median_ensemble %>%
  # dplyr::mutate(forecast_date = Sys.Date(), 
  #               inc = ifelse(inc == "incident", "inc", "cum"),
  #               type = ifelse(type == "deaths", "death", "case"),
  #               target = paste(horizon, "wk ahead", inc, type, sep = " "), 
  #               target_end_date = as.Date(target_end_date), 
  #               type = "quantile") %>%
  # dplyr::select(-inc) %>%
  # dplyr::select(forecast_date, target, target_end_date, location, type, quantile, value, location_name)


# add median forecast
forecast_inc <- dplyr::bind_rows(median_ensemble, 
                                 median_ensemble %>%
                                   dplyr::filter(quantile == 0.5) %>%
                                   dplyr::mutate(type = "point", 
                                                 quantile = NA))

# add cumulative forecasts -----------------------------------------------------

# get latest cumulative forecast
first_forecast_date <- forecasts %>%
  dplyr::pull(target_end_date) %>%
  as.Date() %>%
  unique() %>%
  min()

source(here::here("utility-functions", "load-data.R"))

deaths <- get_data(cumulative = TRUE, weekly = TRUE, cases = FALSE) %>%
  dplyr::group_by(location) %>%
  dplyr::filter(target_end_date == as.Date(first_forecast_date - 7)) %>%
  dplyr::mutate(case = "death")

cases <- get_data(cumulative = TRUE, weekly = TRUE, cases = TRUE) %>%
  dplyr::group_by(location) %>%
  dplyr::filter(target_end_date == as.Date(first_forecast_date - 7)) %>%
  dplyr::mutate(case = "case")

last_obs <- dplyr::bind_rows(deaths, cases) %>%
  dplyr::select(location, value, case) %>%
  dplyr::rename(last_value = value)

# make cumulative
forecast_cum <- forecast_inc %>%
  dplyr::mutate(case = ifelse(grepl("case", target), "case", "death")) %>%
  dplyr::group_by(location, quantile, case) %>%
  dplyr::mutate(value = cumsum(value), 
                target = gsub("inc", "cum", target)) %>%
  dplyr::ungroup() %>%
  # add last observed value
  dplyr::inner_join(last_obs) %>%
  dplyr::mutate(value = value + last_value) %>%
  dplyr::select(-last_value, -case)

forecast_submission <- dplyr::bind_rows(forecast_inc, forecast_cum) %>%
  dplyr::mutate(forecast_date = submission_date)




# write submission files -------------------------------------------------------

if (!dir.exists(here::here("submissions", "human-forecasts", submission_date))) {
  dir.create(here::here("submissions", "human-forecasts", submission_date))
}

forecast_submission %>%
  dplyr::filter(location_name %in% "Germany", 
                grepl("death", target)) %>%
  data.table::fwrite(here::here("submissions", "human-forecasts", submission_date,
                                paste0(submission_date, 
                                       "-Germany-EpiExpert.csv")))

forecast_submission %>%
  dplyr::filter(location_name %in% "Germany", 
                grepl("case", target)) %>%
  data.table::fwrite(here::here("submissions", "human-forecasts", submission_date,
                                paste0(submission_date, 
                                       "-Germany-EpiExpert-case.csv")))

forecast_submission %>%
  dplyr::filter(location_name %in% "Poland", 
                grepl("death", target)) %>%
  data.table::fwrite(here::here("submissions", "human-forecasts", submission_date,
                                paste0(submission_date, 
                                       "-Poland-EpiExpert.csv")))

forecast_submission %>%
  dplyr::filter(location_name %in% "Poland", 
                grepl("case", target)) %>%
  data.table::fwrite(here::here("submissions", "human-forecasts", submission_date,
                                paste0(submission_date, 
                                       "-Poland-EpiExpert-case.csv")))

