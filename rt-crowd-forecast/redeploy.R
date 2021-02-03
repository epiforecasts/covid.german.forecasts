library(covid.german.forecasts)
library(data.table)
library(dplyr)
library(rsconnect)

# if today is not Monday, set submission date to the next Monday
if (weekdays(Sys.Date()) != "Monday") {
  submission_date <- latest_weekday() + 7
} else {
  submission_date <- Sys.Date()
}
saveRDS(submission_date, 
        here("rt-crowd-forecast", "data", "submission_date.RDS"))
first_forecast_date <- as.character(as.Date(submission_date) - 16)

# copy Rt data into app
obs_filt_rt_cases <-
  fread(
    here("rt-forecast", "data", "summary", "cases", submission_date, "rt.csv")
    ) %>%
  rename(value = median, target_end_date = date) %>%
  mutate(target_type = "case", target_end_date = as.Date(target_end_date)) %>%
  filter(target_end_date <= (as.Date(first_forecast_date) + 7 * 6)) %>%
  filter(region %in% c("Poland", "Germany"))

obs_filt_rt_deaths <-
  fread(
    here("rt-forecast", "data", "summary", "deaths", submission_date, "rt.csv")
    ) %>%
  rename(value = median, target_end_date = date) %>%
  mutate(target_type = "death", target_end_date = as.Date(target_end_date)) %>%
  filter(target_end_date <= (as.Date(first_forecast_date) + 7 * 6)) %>%
  filter(region %in% c("Poland", "Germany"))

obs_filt_rt <- bind_rows(obs_filt_rt_cases, obs_filt_rt_deaths) %>%
  arrange(region, target_type, target_end_date) %>%
  arrange(region, target_type, target_end_date)

fwrite(obs_filt_rt, here("rt-crowd-forecast", "data", "observations.csv"))

rsconnect::deployApp(
  appDir = here("rt-crowd-forecast"),
  appName = "rt-crowd-forecast",
  account = "cmmid-lshtm",
  forceUpdate = TRUE,
  appFiles = c("data", "app.R", ".secrets")
)