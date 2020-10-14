

manual_update <- function(file = "2020-10-12/2020-10-12-Germany-EpiNow2-case.csv", cum_value) {
  
  target_file <- here::here("submissions", "rt-forecasts", file)
  df <- data.table::fread(target_file)
  
  df_inc <- df[grepl("inc", target)]
  df_cum <- df[grepl("cum", target)]
  df_cum  <- df_cum [, value := value - cum_value]
  df_cum  <- df_cum [, value := cumsum(value), by = .(type, quantile)][,
                       value := value + cum_value]
  df <- data.table::rbindlist(list(df_inc, df_cum))
  data.table::fwrite(df, target_file)
  return(invisible(NULL))
}


cum <- data.table::fread(here::here("data", "weekly-cumulative-cases.csv"))
cum <- cum[epiweek == max(epiweek)]

cum_death <- data.table::fread(here::here("data", "weekly-cumulative-deaths.csv"))
cum_death <- cum_death[epiweek == max(epiweek)]


manual_update(file = "2020-10-12/2020-10-12-Germany-EpiNow2-case.csv", cum_value = 319381)
manual_update(file = "2020-10-12/2020-10-12-Poland-EpiNow2-case.csv", cum_value = 116338)
manual_update(file = "2020-10-12/2020-10-12-Germany-EpiNow2.csv", cum_value = 9604)
manual_update(file = "2020-10-12/2020-10-12-Poland-EpiNow2.csv", cum_value = 2919)