# script to update data and store data
library(magrittr)
source(here::here("utility-functions", "load-data.R"))

# maybe it would be cleaner to separate the saving step from the get data step
get_data(load_from_server = TRUE)

weekly_cases <- get_data(cases = TRUE)
weekly_deaths <- get_data(cases = FALSE)

data.table::fwrite(weekly_cases, 
                   here::here("data", "weekly-incident-cases.csv"))
data.table::fwrite(weekly_deaths, 
                   here::here("data", "weekly-incident-deaths.csv"))


# copy data into human forecast app
file.copy(from = here::here("data"), 
          to = here::here("human-forecasts"), recursive = TRUE)

