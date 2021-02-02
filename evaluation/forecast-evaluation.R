# packages ---------------------------------------------------------------------
library(magrittr)

# read in the EpiExpert ensemble forecast and EpiNow2 models
folders <- list.files(here::here("submissions", "human-forecasts"))
files <- purrr::map(folders, 
                    .f = function(folder_name) {
                      files <- list.files(paste0(here::here("submissions", "human-forecasts"), 
                                                 folder_name))
                      paste(paste0(here::here("submissions", "human-forecasts"), 
                                   folder_name, "/", 
                                   files))
                    }) %>%
  unlist()
epiexpert_forecasts <- purrr::map_dfr(files, readr::read_csv) %>%
  dplyr::mutate(board_name = "EpiExpert-ensemble", 
                submission_date = forecast_date,
                horizon = as.numeric(gsub("([0-9]+).*$", "\\1", target))) %>%
  dplyr::filter(grepl("inc", target), 
                type == "quantile")

data.table::fwrite(epiexpert_forecasts, 
                   here::here("human-forecasts", "processed-forecast-data", "all-epiexpert-forecasts.csv"))




# also read all EpiNow2 forecasts, give them a board_name 
folders <- list.files(here::here("submissions", "rt-forecasts/"))
files <- purrr::map(folders, 
                    .f = function(folder_name) {
                      files <- list.files(paste0(here::here("submissions", "rt-forecasts/"), 
                                                 folder_name))
                      paste(paste0(here::here("submissions", "rt-forecasts/"), 
                                   folder_name, "/", 
                                   files))
                    }) %>%
  unlist()
epinow_forecasts <- purrr::map_dfr(files, readr::read_csv) %>%
  dplyr::mutate(board_name = "EpiNow2", 
                submission_date = forecast_date,
                horizon = as.numeric(gsub("([0-9]+).*$", "\\1", target))) %>%
  dplyr::filter(grepl("inc", target), 
                type == "quantile")

data.table::fwrite(epinow_forecasts, 
                   here::here("human-forecasts", "processed-forecast-data", "all-epinow2-forecasts.csv"))





# also read all EpiNow2 secondary forecasts, give them a board_name 
folders <- list.files(here::here("submissions", "deaths-from-cases/"))
files <- purrr::map(folders, 
                    .f = function(folder_name) {
                      files <- list.files(paste0(here::here("submissions", "deaths-from-cases/"), 
                                                 folder_name))
                      paste(paste0(here::here("submissions", "deaths-from-cases/"), 
                                   folder_name, "/", 
                                   files))
                    }) %>%
  unlist()
epinow_forecasts <- purrr::map_dfr(files, readr::read_csv) %>%
  dplyr::mutate(board_name = "EpiNow2_secondary", 
                submission_date = forecast_date,
                horizon = as.numeric(gsub("([0-9]+).*$", "\\1", target))) %>%
  dplyr::filter(grepl("inc", target), 
                type == "quantile")

data.table::fwrite(epinow_forecasts, 
                   here::here("human-forecasts", "processed-forecast-data", "all-epinow2_secondary-forecasts.csv"))



# also read all EpiNow2 Rt crowd forecasts, give them a board_name 
folders <- list.files(here::here("submissions", "crowd-rt-forecasts/"))
files <- purrr::map(folders, 
                    .f = function(folder_name) {
                      files <- list.files(paste0(here::here("submissions", "crowd-rt-forecasts/"), 
                                                 folder_name))
                      paste(paste0(here::here("submissions", "crowd-rt-forecasts/"), 
                                   folder_name, "/", 
                                   files))
                    }) %>%
  unlist()
epinow__crowd_forecasts <- purrr::map_dfr(files, readr::read_csv) %>%
  dplyr::mutate(board_name = "Crowd-Rt-Forecast", 
                submission_date = forecast_date,
                horizon = as.numeric(gsub("([0-9]+).*$", "\\1", target))) %>%
  dplyr::filter(grepl("inc", target), 
                type == "quantile")

data.table::fwrite(epinow__crowd_forecasts, 
                   here::here("human-forecasts", "processed-forecast-data", "all-crowd-rt-forecasts.csv"))


# load data --------------------------------------------------------------------
root_dir <- here::here("human-forecasts", "processed-forecast-data")
file_paths_forecast <- paste0(root_dir, list.files(root_dir))

prediction_data <- purrr::map_dfr(file_paths_forecast, 
                                  .f = function(x) {
                                    data <- data.table::fread(x) %>%
                                      dplyr::mutate(target_end_date = as.Date(target_end_date), 
                                                    submission_date = as.Date(submission_date), 
                                                    forecast_date = as.Date(forecast_date))
                                    }) %>%
  dplyr::mutate(target_type = ifelse(grepl("death", target), "death", "case")) %>%
  dplyr::rename(prediction = value) %>%
  dplyr::mutate(forecast_date = as.Date(submission_date)) %>%
  dplyr::rename(model = board_name) %>%
  dplyr::filter(type == "quantile", 
                location_name %in% c("Germany", "Poland")) %>%
  dplyr::select(location, location_name, forecast_date, quantile, prediction, model, target_end_date, horizon, target, target_type)


files <- list.files("data-raw/")
file_paths <- paste0("data-raw/", files[grepl("weekly-incident", files)])
names(file_paths) <- c("case", "death")

truth_data <- purrr::map_dfr(file_paths, readr::read_csv, .id = "target_type") %>%
  dplyr::rename(true_value = value) %>%
  dplyr::mutate(target_end_date = as.Date(target_end_date)) %>%
  dplyr::arrange(location, target_type, target_end_date)

intro_text <- c("This our own evaluation of individual forecasts submitted to the 
EpiExpert model. This model is submitted to the 
[German and Polish Forecast Hub](https://github.com/KITmetricslab/covid19-forecast-hub-de)
each week. \n\n
These evaluations are preliminary - this means we cannot rule out any mistakes 
and the plots and analyses are subject to change. 
The evaluations are also not authorised by the German Forecast Hub team.

If you have questions or want to give feedback, please create an issue on our 
[github repository](https://github.com/epiforecasts/covid-german-forecasts).")


params <- list(locations = c("Germany", "Poland"),
               forecast_dates = "all",
               horizons = c(1:4),
               target_types = "all",
               intro_text = intro_text)



scoringutils::render_scoring_report(truth_data = truth_data, 
                                    document_title = "EpiExpert Crowd-Forecasting Performance Board",
                                    params = params,
                                    prediction_data = prediction_data, 
                                    save_dir = "docs/", 
                                    filename = "index.html")




