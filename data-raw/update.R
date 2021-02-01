# Packages ----------------------------------------------------------------
library(covid.german.forecasts)
library(data.table)
library(dplyr)
library(here)
library(lubridate)

# Source raw data ---------------------------------------------------------
raw_dt <- list()
raw_dt[["cases"]] <- rbindlist(list(
  fread("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/RKI/truth_RKI-Incident%20Cases_Germany.csv"), 
  fread("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/MZ/truth_MZ-Incident%20Cases_Poland.csv")
), 
use.names=TRUE)
raw_dt[["cum_cases"]]  <- rbindlist(list(
  fread("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/RKI/truth_RKI-Cumulative%20Cases_Germany.csv"), 
  fread("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/MZ/truth_MZ-Cumulative%20Cases_Poland.csv")
), 
use.names=TRUE)
raw_dt[["deaths"]]  <- rbindlist(list(
  fread("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/RKI/truth_RKI-Incident%20Deaths_Germany.csv"), 
  fread("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/MZ/truth_MZ-Incident%20Deaths_Poland.csv")
), 
use.names=TRUE)
raw_dt[["cum_deaths"]]  <- rbindlist(list(
  fread("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/RKI/truth_RKI-Cumulative%20Deaths_Germany.csv"), 
  fread("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/MZ/truth_MZ-Cumulative%20Deaths_Poland.csv")
), 
use.names=TRUE)

# Assign location names ---------------------------------------------------
dt <- lapply(raw_dt, function(dt) {
  dt <- merge(dt[, .(date = as_date(date), location, value)], locations[, .(location, location_name)], all.x = TRUE)
  setcolorder(dt, c("location", "location_name", "date", "value"))
  dt <- as_tibble(dt)
})

# Make cumulative data ----------------------------------------------------

# Calculate weekly
weekly_cases <- make_weekly(dt[["cases"]])
weekly_deaths <- make_weekly(dt[["deaths"]])
  
# Calculate cumulative  
weekly_cases_cum <- make_cumulative(weekly_cases)
weekly_deaths_cum <- make_cumulative(weekly_deaths)

# Save data ---------------------------------------------------------------

# daily data
fwrite(dt[["cases"]], here("data-raw", "daily-incidence-cases.csv"))
fwrite(dt[["deaths"]], here("data-raw", "daily-incidence-deaths.csv"))
fwrite(dt[["cum_cases"]], here("data-raw", "daily-cumulative-cases.csv"))
fwrite(dt[["cum_deaths"]], here("data-raw", "daily-cumulative-deaths.csv"))  

# weekly data
fwrite(weekly_cases, here("data-raw", "weekly-incident-cases.csv"))
fwrite(weekly_deaths, here("data-raw", "weekly-incident-deaths.csv"))
fwrite(weekly_cases_cum, here("data-raw", "weekly-cumulative-cases.csv"))
fwrite(weekly_deaths_cum, here("data-raw", "weekly-cumulative-deaths.csv"))


  





