library(here)
library(blastula)
library(googledrive)
library(googlesheets4)
library(covid.german.forecasts)
library(data.table)

# Google sheets authentification -----------------------------------------------
options(gargle_oauth_cache = ".secrets")
drive_auth(cache = ".secrets", email = "epiforecasts@gmail.com")
gs4_auth(token = drive_token())

spread_sheet <- "1nOy3BfHoIKCHD4dfOtJaz4QMxbuhmEvsWzsrSMx_grI"
identification_sheet <- "1GJ5BNcN1UfAlZSkYwgr1-AxgsVA2wtwQ9bRwZ64ZXRQ"

ids <- try_and_wait(read_sheet(ss = identification_sheet, sheet = "ids"))


participant_data <- ids %>%
  dplyr::filter(!is.na(email)) %>%
  dplyr::select(name, username, email, forecaster_id, board_name) %>%
  dplyr::mutate(name = ifelse(is.na(name), username, name))

participant_data <- participant_data %>% 
  dplyr::filter(name %in% c("Habakuk"))

for (i in 1:nrow(participant_data)) {
  
  temp_data <- as.data.table(participant_data)[i]

  name <- temp_data[["name"]]
  board_name <- temp_data[["board_name"]]
  mail_address <- temp_data[["email"]]
  
  # render email
  email <- render_email(here("crowd-forecast", "email-templates", "email-template.Rmd"))
  
  # send email
  smtp_send(email, to = mail_address, from = "epiforecasts@gmail.com", 
            credentials = creds_key(id = "epiforecasts@gmail.com"), 
            subject = paste("EpiForecasts Crowd Forecast Update -", Sys.Date()))
}





create_smtp_creds_key(
  id = "epiforecasts@gmail.com",
  user = "epiforecasts@gmail.com",
  provider = "gmail",
  overwrite = FALSE, 
  use_ssl = TRUE
)




