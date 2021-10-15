#' Check if a Directory Exists and Create if Not
#'
#' @param dir Character string path to a directory.
#' @return NULL
#' @export
check_dir <- function(dir) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }
  return(invisible(NULL))
}
#' Dates to EpiWeeks
#'
#' @param df An input dataframe with a `date` column.
#'
#' @return A dataframe.
#' @export
#' @importFrom dplyr filter group_by count left_join mutate
#' @importFrom tibble tibble
#' @importFrom lubridate epiweek
#' @importFrom tidyr unnest
dates_to_epiweek <- function(df){

  seq <- tibble(date = unique(df$date),
                epiweek = epiweek(date),
                year = epiyear(date),
                 day = weekdays(date))

  epiweek_end_date <- seq %>%
    filter(day == "Saturday")

  epiweek_complete <- seq %>%
    group_by(epiweek, year) %>%
    count() %>%
    filter(n == 7) %>%
    left_join(epiweek_end_date, by = c("epiweek", "year")) %>%
    mutate(date = list(as.Date(date) - 0:6)) %>%
    unnest(cols = c(date))
 
  df_dated <- df %>%
    mutate(epiweek = epiweek(date),
           epiweek_end = date %in% epiweek_end_date$date,
           epiweek_full = date %in% epiweek_complete$date)

  return(df_dated)
}
#' Make Incidence data weekly
#'
#' @param inc A data frame containing: `location`, `location_name`, and 
#' `epiweek`.
#' @return A data frame grouped by week.
#' @export
#' @importFrom grates as_yearweek
#' @importFrom dplyr filter group_by summarise ungroup select
make_weekly <- function(inc) {
  inc_weekly <- inc %>%
    dates_to_epiweek() %>% 
    filter(epiweek_full == TRUE) %>% 
    mutate(year_week = as_yearweek(date, firstday = 7L)) %>%
    group_by(location, location_name, year_week) %>%
    summarise(value = sum(value), 
              target_end_date = max(date),
              .groups = "drop_last") %>% 
    ungroup() %>%
    select(-year_week)
  return(inc_weekly)
} 
#' Make Data Cumulative
#'
#' @param inc A data frame comtaining: `target_end_date`, `location`,
#' `location_name`.
#' @return A cumualtive weekly data frame.
#' @export
#' @importFrom dplyr arrange group_by mutate
make_cumulative <- function(inc) {
  inc_cum <- inc %>%
    arrange(target_end_date) %>%
    group_by(location, location_name) %>%
    mutate(value = cumsum(value))
}
#' Attempt to Execute an Expression and Retry After Failure
#' #'
#' @param expr an expression that shell be executed
#' @param time_to_wait time to wait until the next try after a failure
#' @param number_of_attempts numeric, how often shall we try?
#' @return outcome of the expression to be evaluated
#' @export
#' @importFrom attempt attempt is_try_error
try_and_wait <- function(expr,
                         time_to_wait = 120,
                         number_of_attempts = 10) {
  out <- attempt(expr)
  attempt_number <- 1
  while (is_try_error(out)){
    if (attempt_number > number_of_attempts) {
      stop("Failed - sorry!")
    }
    warning(
      paste("Attempt number", attempt_number, "failed, I'll wait and retry")
      )
    Sys.sleep(time_to_wait)
    out <- attempt(expr)
    attempt_number <- attempt_number + 1
  }
  return(out)
}
#' Find the Latest Target Weekday
#'
#' @param date A date, by default the current system date.
#' @param day Numeric, defaults to 1 (Monday). Day of the
#'  week to find. See ?floor_date for documentation.
#' @param char Logical, defaults to `TRUE`. Should the date be
#'  returned as a character string
#' @return A date or character string identifying
#'  the latest target day of the week
#' @export
#' @importFrom lubridate floor_date
latest_weekday <- function(date = Sys.Date(), day = 1, char = FALSE){
  weekday <- floor_date(date, unit = "week", day)
  if (char) {
    weekday <- as.character(weekday)
  }
  return(weekday)
}
#' Get Local Truth Data
#'
#' @param dir A character string indicating the path to the target data folder.
#' @param range A character string indicating the range
#'  of the data. Supported options are "daily" or "weekly".
#' @param type A character string indicating the type of data
#'  to load. Supports either "incident" or "cumulative'.
#' @param target A character string indicating the target type.
#'  Supports either "cases" or "deaths".
#' @param locs A character vector of target locations to filter for (by code).
#' @return A data table of required truth data.
#' @export
#' @importFrom data.table fread :=
get_truth_data <- function(dir, range = "daily", type = "incident",
                           target = "cases", locs) {
  dt <- fread(paste0(dir, "/", range, "-", type, "-", target, ".csv"))
  dt[, `:=`(inc = type, type = target)]
  if (!missing(locs)) {
    dt <- dt[location %in% locs]
  }
  return(dt)
}
#' Save a Forecast
#'
#' @param forecast A dataframe containing a forecast as produced by
#'  `format_forecast`.
#' @param loc_name Character string indicating the location name.
#' @param loc Character vecetor, indicates target regions.
#' @param type Character string default to "". Indicates the target type.
#' @param date A character string or Date indicating the date of forecast.
#' @param folder Character string indicating the target folder.
#' @param model Character string indicating the model name.
#' @export
#' @return NULL
#' @importFrom data.table fwrite
save_forecast <- function(forecast, loc_name, loc, type = "",
                          date, folder, model) {
  fwrite(
    forecast[grepl(loc, location)], 
    file.path(folder, paste0(target_date, "-", loc_name, model, type, ".csv"))
    )
    return(invisible(NULL))
  }

globalVariables(
  c("cum_value", "day", "epiweek_full", "horizon", "location", "location_name",
    "locations", "n", "quantile", "region", "target", "target_end_date",
    "type", "value", ".", "primary", "secondary", "target_date", "variable", 
    "epiyear", "year", "year_week"
  )
)

#' Authentificate for Google Sheets
#'
#' @param service_account the path to a JSON file that has all the information
#' of the Google service account. If a service account is presented it will 
#' be used and the other arguments will be ignored
#' @param email alternatively, provide the email address to an authorised 
#' account
#' @param cache_folder path to the folder where secrets for the email address
#' provided are stored. 
#' @importFrom here here
#' @importFrom googledrive drive_auth drive_token
#' @importFrom googlesheets4 gs4_auth
#' @export
#' @return NULL
google_auth <- function(service_account = "default", 
                        email = "epiforecasts@gmail.com", 
                        cache_folder = ".secrets") {
  
  if (service_account == "default") {
    service_account <- here(".secrets", "crowd-forecast-app-c98ca2164f6c-service-account-token.json")
  }
  # if service account is present, use that. Else try authentification via email
  if (file.exists(service_account)) {
    gs4_auth(path = service_account)
  } else {
    options(gargle_oauth_cache = cache_folder)
    drive_auth(cache = cache_folder, email = email)
    gs4_auth(token = drive_token())
  }
  return(invisible(NULL))
}

