# update-rt-data by copying it from the Rt folder
library(here)
library(covid.german.forecasts)
locations <- c("Germany", "Poland")

date <- latest_weekday(Sys.Date())

for (location in locations) {

  file_names <- c("summarised_estimates.rds", "estimate_samples.rds", 
                  "model_fit.rds", "model_args.rds", "reported_cases.rds")
  target_dir <- here("rt-crowd-forecast", "data-raw", "rt-epinow-data", 
                     location)
  check_dir(target_dir)
  for (file_name in file_names) {
    file.copy(from = here::here("rt-forecast", "data", "samples", "cases", 
                                location, date, file_name), 
              to = here(target_dir, file_name))
  }
}