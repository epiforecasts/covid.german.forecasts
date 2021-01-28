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
  submisison_date <- next_monday(Sys.Date())
} else {
  submission_date <- Sys.Date()
}

saveRDS(submisison_date, "human-forecasts/data/submission_date.RDS")



rsconnect::deployApp(appDir = "human-forecasts/", 
                     appName = "crowd-forecast",
                     account = "cmmid-lshtm", 
                     forceUpdate = TRUE,
                     appFiles = c("data", "app.R", ".secrets"))
