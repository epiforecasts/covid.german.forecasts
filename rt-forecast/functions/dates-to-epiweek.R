library(tibble)
library(dplyr)

dates_to_epiweek <- function(df){
  
  seq <- tibble::tibble(date = unique(df$date),
                        epiweek = lubridate::epiweek(date),
                        day = weekdays(date))
  
  epiweek_end_date <- seq %>%
    dplyr::filter(day == "Saturday")
  
  epiweek_complete <- seq %>%
    dplyr::group_by(epiweek) %>%
    dplyr::count() %>%
    dplyr::filter(n == 7) %>%
    dplyr::left_join(epiweek_end_date, by = "epiweek")
  
  df_dated <- df %>%
    dplyr::mutate(epiweek = lubridate::epiweek(date),
                  epiweek_end = date %in% epiweek_end_date$date,
                  epiweek_full = epiweek %in% epiweek_complete$epiweek)
  
  return(df_dated)
}