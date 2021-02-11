# packages ---------------------------------------------------------------------
library(purrr)
library(dplyr)
library(here)
library(readr)
library(scoringutils)
library(rmarkdown)
library(data.table)


# helper function to read in all past submissions from a model, bind them together
# to one file and copy them into the crowd forecast app folder 
# having them in one place allows to easily include other models in the 
# crowd forecast report. Could in principle also do without copying
load_and_copy_forecasts <- function(root_dir,
                                    out_file_path,
                                    new_board_name) {
  folders <- list.files(root_dir)
  files <- map(folders,
               .f = function(folder_name) {
                 files <- list.files(here(root_dir, folder_name))
                 paste(here(root_dir, folder_name, files))
               }) %>%
    unlist()
  
  forecasts <- suppressMessages(map_dfr(files, read_csv) %>%
                                  mutate(board_name = new_board_name,
                                         submission_date = forecast_date,
                                         horizon = as.numeric(gsub("([0-9]+).*$", "\\1", target))) %>%
                                  filter(grepl("inc", target),
                                         type == "quantile"))
  fwrite(forecasts, out_file_path)
}

# read in the EpiExpert ensemble forecast and EpiNow2 models
load_and_copy_forecasts(
  root_dir = here("submissions", "crowd-forecasts"), 
  out_file_path = here("crowd-forecast", "processed-forecast-data",
                       "all-epiexpert-forecasts.csv"), 
  new_board_name = "EpiExpert-ensemble"
)

# also read all EpiNow2 forecasts, give them a board_name 
load_and_copy_forecasts(
  root_dir = here("submissions", "rt-forecasts"), 
  out_file_path = here("crowd-forecast", "processed-forecast-data", 
                       "all-epinow2-forecasts.csv"), 
  new_board_name = "EpiNow2"
)

# also read all EpiNow2 secondary forecasts, give them a board_name 
load_and_copy_forecasts(
  root_dir = here("submissions", "deaths-from-cases"), 
  out_file_path = here("crowd-forecast", "processed-forecast-data", 
                       "all-epinow2_secondary-forecasts.csv"), 
  new_board_name = "EpiNow2_secondary"
)

# also read all EpiNow2 Rt crowd forecasts, give them a board_name 
load_and_copy_forecasts(
  root_dir = here("submissions", "crowd-rt-forecasts"), 
  out_file_path = here("crowd-forecast", "processed-forecast-data", 
                       "all-crowd-rt-forecasts.csv"), 
  new_board_name = "Crowd-Rt-Forecast")

rmarkdown::render(here::here("evaluation", "report-template.Rmd"),
                  output_format = "html_document",
                  output_file = here::here("docs", "index.html"),
                  envir = new.env(),
                  clean = TRUE)
