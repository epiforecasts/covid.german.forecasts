source(here::here("functions", "dates-to-epiweek.R"))

download_data <- function(save_dir = "data") {
    
  incident_cases <- data.table::rbindlist(list(
    data.table::fread("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/RKI/truth_RKI-Incident%20Cases_Germany.csv"), 
    data.table::fread("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/MZ/truth_MZ-Incident%20Cases_Poland.csv")
  ), 
  use.names=TRUE)
  cumulative_cases <- data.table::rbindlist(list(
    data.table::fread("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/RKI/truth_RKI-Cumulative%20Cases_Germany.csv"), 
    data.table::fread("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/MZ/truth_MZ-Cumulative%20Cases_Poland.csv")
  ), 
  use.names=TRUE)
  incident_deaths <- data.table::rbindlist(list(
    data.table::fread("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/RKI/truth_RKI-Incident%20Deaths_Germany.csv"), 
    data.table::fread("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/MZ/truth_MZ-Incident%20Deaths_Poland.csv")
  ), 
  use.names=TRUE)
  cumulative_deaths <- data.table::rbindlist(list(
    data.table::fread("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/RKI/truth_RKI-Cumulative%20Deaths_Germany.csv"), 
    data.table::fread("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/MZ/truth_MZ-Cumulative%20Deaths_Poland.csv")
  ), 
  use.names=TRUE)
  
  # write incident cases and deaths
  data.table::fwrite(incident_cases, here::here(save_dir, paste0("daily-incidence-cases.csv")))
  data.table::fwrite(incident_deaths, here::here(save_dir, paste0("daily-incidence-deaths.csv")))
  
  data.table::fwrite(cumulative_cases, here::here(save_dir, paste0("daily-cumulative-cases.csv")))
  data.table::fwrite(cumulative_deaths, here::here(save_dir, paste0("daily-cumulative-deaths.csv")))
}






get_data <- function(load_from_server = FALSE, 
                     cumulative = FALSE,
                     cases = TRUE,
                     national_only = TRUE,
                     root_dir = "data",
                     weekly = TRUE) {
  
  filter_national <- function(data) {
    if (national_only) {
      return(dplyr::filter(data, location %in% c("GM", "PL", "US")))
    } else {
      return(data)
    }
  }
  
  if (load_from_server) {
    download_data(save_dir = root_dir)
  } 
  
  incident_cases <- data.table::fread(here::here(root_dir, paste0("daily-incidence-cases.csv")))
  incident_deaths <- data.table::fread(here::here(root_dir, paste0("daily-incidence-deaths.csv")))
  
  # cumulative cases are only relevant for daily data. for weekly, they get computed
  # could in principle just omit that and have cumulative computed as well. 
  # leaving it as we actually have ground truth data available
  if (!weekly) {
    cumulative_cases <- data.table::fread(here::here(root_dir, paste0("daily-cumulative-cases.csv")))
    cumulative_deaths <- data.table::fread(here::here(root_dir, paste0("daily-cumulative-deaths.csv")))
  }
  
  
  if (weekly) {
    # cases
    if (cases) {
      incident_cases_weekly <- incident_cases %>%
        dates_to_epiweek() %>% 
        dplyr::filter(epiweek_full == TRUE) %>% 
        dplyr::group_by(location, location_name, epiweek) %>%
        dplyr::summarise(value = sum(value), 
                         target_end_date = max(date),
                         .groups = "drop_last") %>% 
        ungroup()
      
      if (cumulative) {
        cumulative_cases_weekly <- incident_cases_weekly %>%
          dplyr::arrange(target_end_date) %>% 
          dplyr::group_by(location, location_name) %>% 
          dplyr::mutate(value = cumsum(value))
        return(filter_national(cumulative_cases_weekly))
      } else {
        return(filter_national(incident_cases_weekly))
      }
      
    # deaths
    } else {
      incident_deaths_weekly <- incident_deaths %>%
        dates_to_epiweek() %>% 
        dplyr::filter(epiweek_full == TRUE) %>% 
        dplyr::group_by(location, location_name, epiweek) %>%
        dplyr::summarise(value = sum(value), 
                         target_end_date = max(date),
                         .groups = "drop_last") %>% 
        ungroup()
      if (cumulative) {
        cumulative_deaths_weekly <- incident_deaths_weekly %>%
          dplyr::arrange(target_end_date) %>% 
          dplyr::group_by(location, location_name) %>% 
          dplyr::mutate(value = cumsum(value))
        return(filter_national(cumulative_deaths_weekly))
      } else {
        return(filter_national(incident_deaths_weekly))
      }
    }
  }
  
  # if not weekly
  if (cases) {
    if (cumulative) {
      return(filter_national(cumulative_cases))
    } else {
      return(filter_national(incident_cases))
    }
  } else {
    if (cumulative) {
      return(filter_national(cumulative_deaths))
    } else {
      return(filter_national(incident_deaths))
    }
  }
}

