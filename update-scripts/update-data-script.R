# script to update data and store data
library(magrittr)
source(here::here("functions", "load-data.R"))

if (!dir.exists(here::here("data"))) {
  dir.create("data", recursive = TRUE)
}

# maybe it would be cleaner to separate the saving step from the get data step
get_data(load_from_server = TRUE)

weekly_cases <- get_data(cases = TRUE)
weekly_deaths <- get_data(cases = FALSE)



data.table::fwrite(weekly_cases, 
                   here::here("data", "weekly-incident-cases.csv"))
data.table::fwrite(weekly_deaths, 
                   here::here("data", "weekly-incident-deaths.csv"))


weekly_cases_cum <- get_data(cases = TRUE, cumulative = TRUE)
weekly_deaths_cum <- get_data(cases = FALSE, cumulative = TRUE)

data.table::fwrite(weekly_cases_cum, 
                   here::here("data", "weekly-cumulative-cases.csv"))
data.table::fwrite(weekly_deaths_cum, 
                   here::here("data", "weekly-cumulative-deaths.csv"))


if (!dir.exists(here::here("human-forecasts", "data"))) {
  dir.create("human-forecasts", "data", recursive = TRUE)
}

# copy data into human forecast app
file.copy(from = here::here("data"), 
          to = here::here("human-forecasts"), recursive = TRUE)

