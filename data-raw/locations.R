library(usethis)
library(data.table)
library(stringr)

# Locations ---------------------------------------------------------------
poland <- 
  fread("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/template/state_codes_poland.csv")
germany <- 
  fread("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/template/state_codes_germany.csv")

# Bind and save -----------------------------------------------------------
locations <- rbindlist(list(germany, poland))
locations <- locations[, .(location = state_code, location_name = state_name, population)]
locations[, location_name := str_replace_all(location_name, " Province", "")]
usethis::use_data(locations, overwrite = TRUE)