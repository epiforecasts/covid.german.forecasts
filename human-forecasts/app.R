# Launch the ShinyApp (Do not remove this comment)
# To deploy, run: rsconnect::deployApp()
# Or use the blue button on top of this file

library(magrittr)
library(crowdforecastr)

# devtools::install_github("epiforecasts/crowdforecastr")

deaths_inc <- data.table::fread("data/weekly-incident-deaths.csv") %>%
  dplyr::mutate(inc = "incident",
                type = "deaths")

cases_inc <- data.table::fread("data/weekly-incident-cases.csv") %>%
  dplyr::mutate(inc = "incident",
                type = "cases")

observations <- dplyr::bind_rows(deaths_inc,
                                 cases_inc)  %>%
  # this has to be treated with care depending on when you update the data
  dplyr::filter(epiweek <= max(epiweek)) %>%
  dplyr::rename(target_type = type) %>%
  dplyr::arrange(location_name, target_type, target_end_date)

crowdforecastr::run_app(data = observations, 
                        first_forecast_date = "2021-01-30",
                        selection_vars = c("location_name", "target_type"),
                        google_account_mail = "epiforecasts@gmail.com", 
                        forecast_sheet_id = "1nOy3BfHoIKCHD4dfOtJaz4QMxbuhmEvsWzsrSMx_grI",
                        user_data_sheet_id = "1GJ5BNcN1UfAlZSkYwgr1-AxgsVA2wtwQ9bRwZ64ZXRQ", 
                        submission_date = "2021-01-25")
