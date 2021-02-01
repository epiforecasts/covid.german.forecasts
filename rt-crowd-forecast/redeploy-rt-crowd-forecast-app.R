# reinstall crowdforecastr from github if necessary
devtools::install_github("epiforecasts/crowdforecastr", force = FALSE)

# helper function to determine the correct forecast date
next_monday <- function(date){
  nm <- rep(NA, length(date))
  for(i in seq_along(date)){
    nm[i] <- date[i] + (0:6)[weekdays(date[i] + (0:6)) == "Monday"]
  }
  return(as.Date(nm, origin = "1970-01-01"))
}

# if today is not Monday, set submission date to the next Monday
if (weekdays(Sys.Date()) != "Monday") {
  submission_date <- next_monday(Sys.Date())
} else {
  submission_date <- Sys.Date()
}

saveRDS(submission_date, "rt-crowd-forecast/data/submission_date.RDS")
first_forecast_date <- as.character(as.Date(submission_date) - 16)

# copy Rt data into app
obs_filt_rt_cases <- data.table::fread(paste0("rt-forecast/data/summary/cases/", submission_date, "/rt.csv")) %>%
  dplyr::rename(value = median,
                target_end_date = date) %>%
  dplyr::mutate(target_type = "case",
                target_end_date = as.Date(target_end_date)) %>%
  dplyr::filter(target_end_date <= (as.Date(first_forecast_date) + 7 * 6)) %>%
  dplyr::filter(region %in% c("Poland", "Germany"))
obs_filt_rt_deaths <- data.table::fread(paste0("rt-forecast/data/summary/deaths/", submission_date, "/rt.csv")) %>%
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
                   "rt-crowd-forecast/data/observations.csv")



rsconnect::deployApp(appDir = "rt-crowd-forecast/", 
                     appName = "rt-crowd-forecast",
                     account = "cmmid-lshtm", 
                     forceUpdate = TRUE,
                     appFiles = c("data", "app.R", ".secrets"))
