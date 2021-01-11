# load data --------------------------------------------------------------------

library(magrittr)
root_dir <- "human-forecasts/processed-forecast-data/"
file_paths_forecast <- paste0(root_dir, list.files(root_dir))

prediction_data <- purrr::map_dfr(file_paths_forecast, readr::read_csv) %>%
  dplyr::mutate(target_type = ifelse(grepl("death", target), "death", "case")) %>%
  dplyr::rename(prediction = value) %>%
  dplyr::mutate(forecast_date = submission_date) %>%
  dplyr::rename(model = board_name) %>%
  dplyr::filter(type == "quantile") %>%
  dplyr::select(location, location_name, forecast_date, quantile, prediction, model, target_end_date, horizon, target, target_type)
  


files <- list.files("data/")
file_paths <- paste0("data/", files[grepl("weekly-incident", files)])
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




