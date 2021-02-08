# packages
library(covid.german.forecasts)
library(here)
library(rsconnect)
# update data
source(here("data-raw", "update.R"))

# copy data into app
file.copy(c(here("data-raw", "weekly-incident-cases.csv"), 
            here("data-raw", "weekly-incident-deaths.csv")),
          to = here("crowd-forecast", "data-raw"), overwrite = TRUE)

# if today is not Monday, set submission date to the next Monday
if (weekdays(Sys.Date()) != "Monday") {
  submission_date <- latest_weekday() + 7
} else {
  submission_date <- Sys.Date()
}

saveRDS(
  submission_date, here("crowd-forecast", "data-raw", "submission_date.rds")
  )

deployApp(appDir = here("crowd-forecast"),
          appName = "crowd-forecast",
          account = "cmmid-lshtm", 
          forceUpdate = TRUE,
          appFiles = c("data-raw", "app.R", ".secrets"))