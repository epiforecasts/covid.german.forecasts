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
dates_to_epiweek <- function(df){
  
  seq <- tibble(date = unique(df$date),
                epiweek = epiweek(date),
                 day = weekdays(date))
  
  epiweek_end_date <- seq %>%
    filter(day == "Saturday")
  
  epiweek_complete <- seq %>%
    group_by(epiweek) %>%
    count() %>%
    filter(n == 7) %>%
    left_join(epiweek_end_date, by = "epiweek")
  
  df_dated <- df %>%
    mutate(epiweek = epiweek(date),
           epiweek_end = date %in% epiweek_end_date$date,
           epiweek_full = epiweek %in% epiweek_complete$epiweek)
  
  return(df_dated)
}
#' Make Incidence data weekly
#'
#' @param inc A data frame containing: `location`, `location_name`, and 
#' `epiweek`.
#' @return A data frame grouped by week.
#' @export
#' @importFrom dplyr filter group_by summarise ungroup
make_weekly <- function(inc) {
  inc_weekly <- inc %>%
    dates_to_epiweek() %>% 
    filter(epiweek_full == TRUE) %>% 
    group_by(location, location_name, epiweek) %>%
    summarise(value = sum(value), 
              target_end_date = max(date),
              .groups = "drop_last") %>% 
    ungroup()
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


globalVariables(
  c("cum_value", "day", "epiweek_full", "horizon", "location", "location_name",
    "locations", "n", "quantile", "region", "target", "target_end_date", "type", "value", 
    "."
  )
)
