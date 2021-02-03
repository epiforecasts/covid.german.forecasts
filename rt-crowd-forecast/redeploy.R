# reinstall crowdforecastr from github if necessary
devtools::install_github("epiforecasts/crowdforecastr", force = FALSE)

# if today is not Monday, set submission date to the next Monday
if (weekdays(Sys.Date()) != "Monday") {
  submission_date <- floor_date(Sys.Date(), unit = "week", 1) + 7
} else {
  submission_date <- Sys.Date()
}

saveRDS(submission_date, here::here("rt-crowd-forecast", "data", "submission_date.RDS"))
first_forecast_date <- as.character(as.Date(submission_date) - 16)

# copy Rt data into app
obs_filt_rt_cases <- data.table::fread(here::here("rt-forecast", "data", "summary", "cases", submission_date, "rt.csv")) %>%
  dplyr::rename(value = median,
                target_end_date = date) %>%
  dplyr::mutate(target_type = "case",
                target_end_date = as.Date(target_end_date)) %>%
  dplyr::filter(target_end_date <= (as.Date(first_forecast_date) + 7 * 6)) %>%
  dplyr::filter(region %in% c("Poland", "Germany"))
obs_filt_rt_deaths <- data.table::fread(here::here("rt-forecast", "data", "summary", "deaths", submission_date, "rt.csv")) %>%
  dplyr::rename(value = median,
                target_end_date = date) %>%
  dplyr::mutate(target_type = "death",
                target_end_date = as.Date(target_end_date)) %>%
  dplyr::filter(target_end_date <= (as.Date(first_forecast_date) + 7 * 6)) %>%
  dplyr::filter(region %in% c("Poland", "Germany"))
obs_filt_rt <- dplyr::bind_rows(obs_filt_rt_cases, obs_filt_rt_deaths) %>%
  dplyr::arrange(region, target_type, target_end_date) %>%
  dplyr::arrange(region, target_type, target_end_date)

data.table::fwrite(obs_filt_rt,
                   here::here("rt-crowd-forecast", "data", "observations.csv"))



rsconnect::deployApp(appDir = here::here("rt-crowd-forecast"), 
                     appName = "rt-crowd-forecast",
                     account = "cmmid-lshtm", 
                     forceUpdate = TRUE,
                     appFiles = c("data", "app.R", ".secrets"))
