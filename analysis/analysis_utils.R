# helper function to get the file paths to all forecasts made
get_file_paths <- function(root_dir = here::here("analysis")) {
  folders <- here::here(root_dir, list.files(root_dir))
  folders <- folders[grepl("epiforecasts", folders)]
  
  file_paths <- purrr::map(folders, 
                           .f = function(folder) {
                             files <- list.files(folder)
                             out <- here::here(folder, files)
                             return(out)}) %>%
    unlist()
  file_paths <- file_paths[grepl(".csv", file_paths)]
  return(file_paths)
}


# helper function to get model name from a file path
get_model_name <- function(file_path) {
  split <- str_split(a, pattern = "/")[[1]]
  model <- split[length(split) - 1]
  return(model)
}

# helper function to load forecasts
# sorry for the mix of data.table and dplyr, will correct in the future
load_all_forecasts <- function(file_paths) {
  prediction_data <- purrr::map_dfr(file_paths, 
                                    .f = function(file_path) {
                                      data <- data.table::fread(file_path)
                                      data[, `:=`(
                                        target_end_date = as.Date(target_end_date), 
                                        submission_date = as.Date(submission_date), 
                                        forecast_date = as.Date(forecast_date), 
                                        model = get_model_name(file_path)
                                      )]
                                      return(data)
                                    }) %>%
    dplyr::mutate(target_type = ifelse(grepl("death", target), "death", "case")) %>%
    dplyr::rename(prediction = value) %>%
    dplyr::mutate(forecast_date = as.Date(submission_date)) %>%
    dplyr::filter(type == "quantile", 
                  location_name %in% c("Germany", "Poland")) %>%
    dplyr::select(location, location_name, forecast_date, quantile, prediction, model, target_end_date, target, target_type)
  return(prediction_data)
}


# helper function to load all truth
load_all_truth <- function() {
  weekly_cases <- fread(here("data-raw", "weekly-incident-cases.csv"))
  weekly_deaths <- fread(here("data-raw", "weekly-incident-deaths.csv"))
  truth <- rbindlist(list(weekly_cases, weekly_deaths)) 
  truth <- truth[location_name %in% c("Germany", "Poland")]
  return(truth)
}

