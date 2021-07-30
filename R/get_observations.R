#' Get Observed Cases linked with Deaths
#'
#' @param dir A character string indicating the path to the target data folder.
#' @param target_date Date or character string indicating the target forecast
#' date.
#' @param weeks Numeric, defaults to 8. Number of weeks of data to include.
#' @param locs An optional character vector to use to filter locations by name.
#' @return A dataframe of primary and secondary observations
#' @export
#' @importFrom data.table fread setnames setorder
get_observations <- function(dir, target_date = Sys.Date(),
                             weeks = 8, locs) {
  deaths <- fread(file.path(dir, "daily-incidence-deaths.csv"))
  cases <- fread(file.path(dir, "daily-incidence-cases.csv"))
  deaths <- setnames(deaths, "value", "secondary")
  cases <- setnames(cases, "value", "primary")
  obs <- merge(
    cases, deaths,
    by = c("location", "location_name", "date")
  )
  obs <- obs[,
    .(region = as.character(location_name),
      date = as.Date(date), primary, secondary)
  ]
  obs <- obs[date >= (max(target_date) - weeks * 7)]
  obs <- obs[date <= target_date]
  obs <- obs[primary < 0, primary := 0]
  obs <- obs[secondary < 0, secondary := 0]
  setorder(obs, region, date)

  if (!missing(locs)) {
    obs <- obs[region %in% locs]
  }
  return(obs)
}
