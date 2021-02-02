# update data
source("data-raw/update.R")

# copy data into app
file.copy(c(here::here("data-raw", "weekly-incident-cases.csv"), 
            here::here("data-raw", "weekly-incident-deaths.csv")),
          to = here::here("human-forecasts", "data"), overwrite = TRUE)

# if today is not Monday, set submission date to the next Monday
if (weekdays(Sys.Date()) != "Monday") {
  submission_date <- floor_date(Sys.Date(), unit = "week", 1) + 7
} else {
  submission_date <- Sys.Date()
}

saveRDS(submission_date, here::here("human-forecasts", "data", "submission_date.RDS"))

rsconnect::deployApp(appDir = here::here("human-forecasts"), 
                     appName = "crowd-forecast",
                     account = "cmmid-lshtm", 
                     forceUpdate = TRUE,
                     appFiles = c("data", "app.R", ".secrets"))
