library(covid.german.forecasts)
library(data.table)
library(dplyr)
library(rsconnect)
library(here)

# if today is not Monday, set submission date to last monday
submission_date <- latest_weekday()

saveRDS(submission_date,
        here("rt-crowd-forecast", "data", "submission_date.rds"))
first_forecast_date <- as.character(as.Date(submission_date) - 16)

# copy Rt data into app
obs <-
  fread(
    here("rt-forecast", "data", "summary", "cases", submission_date, "rt.csv")
    ) %>%
  rename(value = median, target_end_date = date) %>%
  mutate(target_type = "case", target_end_date = as.Date(target_end_date)) %>%
  filter(target_end_date <= (as.Date(first_forecast_date) + 7 * 6)) %>%
  filter(region %in% c("Poland", "Germany")) %>%
  arrange(region, target_type, target_end_date)

fwrite(obs, here("rt-crowd-forecast", "data", "observations.csv"))

setAccountInfo(
  name = "cmmid-lshtm",
  token = readRDS(here(".secrets", "shiny_token.rds")),
  secret = readRDS(here(".secrets", "shiny_secret.rds"))
)

deployApp(
  appDir = here("rt-crowd-forecast"),
  appName = "rt-crowd-forecast",
  account = "cmmid-lshtm",
  forceUpdate = TRUE,
  appFiles = c("data", "app.R", ".secrets")
)
