# Launch the ShinyApp (Do not remove this comment)
# To deploy, run: rsconnect::deployApp()
# Or use the blue button on top of this file
library(data.table)
library(here)
library(crowdforecastr)

# load submission date from data if on server
if (!dir.exists("crowd-forecast")) {
  submission_date <- readRDS(here("data-raw", "submission_date.rds"))
} else {
  # just for local testing, set arbitrary submission date
  submission_date <- Sys.Date() + 7
}

# set first forecast date to the Saturday after that
first_forecast_date <- submission_date + 5

# load observations
deaths_inc <- fread(here("data-raw", "weekly-incident-deaths.csv"))[
  location %in% c("GM", "PL")][, target_type := "deaths"]
cases_inc <- fread(here("data-raw", "weekly-incident-cases.csv"))[
  location %in% c("GM", "PL")][, target_type := "cases"]

# bind together and sort according to date
observations <- rbindlist(list(deaths_inc, cases_inc))
observations <- observations[epiweek <= max(epiweek)]
setorder(observations, target_type, target_end_date)

# run app
run_app(data = observations, 
        first_forecast_date = as.character(first_forecast_date),
        selection_vars = c("location_name", "target_type"),
        google_account_mail = "epiforecasts@gmail.com",
        forecast_sheet_id = "1nOy3BfHoIKCHD4dfOtJaz4QMxbuhmEvsWzsrSMx_grI",
        user_data_sheet_id = "1GJ5BNcN1UfAlZSkYwgr1-AxgsVA2wtwQ9bRwZ64ZXRQ", 
        submission_date = as.character(submission_date))
