library(here)
library(blastula)
library(googledrive)
library(googlesheets4)
library(covid.german.forecasts)
library(data.table)

# set up email credential if not present
if (!file.exists(here(".secrets", "epiforecasts-email-creds"))) {
  create_smtp_creds_file(
    file = here(".secrets", "epiforecasts-email-creds"),
    user = "epiforecasts@gmail.com",
    provider = "gmail"
  )
}

# Google sheets authentification -----------------------------------------------
google_auth()

identification_sheet <- "1GJ5BNcN1UfAlZSkYwgr1-AxgsVA2wtwQ9bRwZ64ZXRQ"

ids <- try_and_wait(read_sheet(ss = identification_sheet, sheet = "ids"))

# filter participant data
participant_data <- ids %>%
  dplyr::filter(!is.na(email)) %>%
  dplyr::select(name, username, email, forecaster_id, board_name) %>%
  dplyr::mutate(name = ifelse(is.na(name), username, name))

# update data (probably needs to happen only on local machine)
source(here("data-raw", "update.R"))

# iterate over rows and send an email
for (i in seq_len(nrow(participant_data))) {

  temp_data <- as.data.table(participant_data)[i]

  name <- temp_data[["name"]]
  board_name <- temp_data[["board_name"]]
  mail_address <- temp_data[["email"]]

  # render email
  email <- render_email(
    here("crowd-forecast", "email-templates", "email-template.Rmd")
    )

  # send email
  smtp_send(
    email,
    to = mail_address, from = "epiforecasts@gmail.com",
    credentials = creds_file(here(".secrets", "epiforecasts-email-creds")),
    subject = paste("EpiForecasts Crowd Forecast Update -", Sys.Date())
    )
}
