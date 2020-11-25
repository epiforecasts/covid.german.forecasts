# load data --------------------------------------------------------------------

library(magrittr)
root_dir <- "human-forecasts/processed-forecast-data/"
file_paths_forecast <- paste0(root_dir, list.files(root_dir))

prediction_data <- purrr::map_dfr(file_paths_forecast, readr::read_csv) %>%
  dplyr::mutate(target_type = ifelse(grepl("death", target), "death", "case")) %>%
  dplyr::rename(prediction = value) %>%
  dplyr::mutate(forecast_date = submission_date) %>%
  dplyr::rename(model = board_name)
  


files <- list.files("data/")
file_paths <- paste0("data/", files[grepl("weekly-incident", files)])
names(file_paths) <- c("case", "death")

truth_data <- purrr::map_dfr(file_paths, readr::read_csv, .id = "target_type") %>%
  dplyr::rename(true_value = value)


params <- list(locations = c("Germany", "Poland"),
               forecast_dates = "all",
               horizons = c(1:4),
               target_types = "all")



scoringutils::render_scoring_report(truth_data = truth_data, 
                                    params = params,
                                    prediction_data = prediction_data, 
                                    save_dir = "evaluation/")




