library(plotly)
library(purrr)
library(shiny)
library(shinyBS)
library(shinyauthr)
library(sodium)
library(googledrive)
library(googlesheets4)
library(magrittr)



# ------------------------------------------------------------------------------
# --------------------------- server and app setup -----------------------------
# ------------------------------------------------------------------------------

# define how long this app should accept forecasts -----------------------------
app_end_date <- "2020-11-17 12:00:00" # Time is UTC


# google authentification and connection ---------------------------------------
options(gargle_oauth_cache = ".secrets")
drive_auth(cache = ".secrets", email = "epiforecasts@gmail.com")
gs4_auth(token = drive_token())

spread_sheet <- "1xdJDgZdlN7mYHJ0D0QbTcpiV9h1Dmga4jVoAg5DhaKI"
identification_sheet <- "1GJ5BNcN1UfAlZSkYwgr1-AxgsVA2wtwQ9bRwZ64ZXRQ"



# load and format case and death data ------------------------------------------
# weekly observations for the big forecast plot
deaths_inc <- data.table::fread(here::here("data", "weekly-incident-deaths.csv")) %>%
  dplyr::mutate(inc = "incident", 
                type = "deaths")

cases_inc <- data.table::fread(here::here("data", "weekly-incident-cases.csv")) %>%
  dplyr::mutate(inc = "incident", 
                type = "cases")

observations <- dplyr::bind_rows(deaths_inc, 
                                 cases_inc)  %>%
  # this has to be treated with care depending on when you update the data
  dplyr::filter(epiweek <= max(epiweek))

# daily data for reference plot
cases_daily_inc <- data.table::fread(here::here("data", "daily-incidence-cases-Germany_Poland.csv")) %>%
  dplyr::mutate(inc = "incident", 
                type = "cases")



# create items for the dropdown selection lists of locations and type ----------
# extract information about all locations present
location_vector <- observations %>%
  dplyr::filter(!grepl("County", location_name)) %>%
  dplyr::pull(location_name) %>%
  unique()
# create names by combining locations with either 'case' or 'death'
selections <- expand.grid(list(location = location_vector, 
                               inc = c("incident"), 
                               type = c("cases", "deaths"))) %>%
  dplyr::arrange(location)
selection_names <- apply(selections, MARGIN = 1, 
                         FUN = function(x) {
                           paste(x, collapse = "-")
                         })







# ------------------------------------------------------------------------------
# ------------------------------------- UI -------------------------------------
# ------------------------------------------------------------------------------

ui <- fluidPage(
  
  shinyjs::useShinyjs(),
  
  fluidRow(column(12,
                  tipify(h1("Covid-19 Crowd Forecast"), 
                         title = "If you can't see the entire user interface, 
                         you may want to zoom out in your browser."))),
  fluidRow(column(2,
                  selectInput(inputId = "selection",
                                     label = "Selection:",
                                     choices = selection_names, 
                                     selected = "Germany")),
           column(2, 
                  numericInput(inputId = "num_past_obs", 
                                      value = 12,
                                      label = "Number of weeks to show")), 
           column(1, radioButtons("plotscale", label = "Plot Scale", selected = "linear",
                                  choices = c("linear", "log"), 
                                  inline = TRUE)),
           column(2, 
                  conditionalPanel(condition = "output.condition_distribution", 
                                   checkboxGroupInput("ranges", "Prediction intervals to show", 
                                                      choices = c("20%", "50%", "90%", "95%"), 
                                                      selected = c("50%", "90%"),
                                                      inline = TRUE))),
           column(2, selectInput("baseline_model", 
                                           label = "Baseline prediction",
                                           choices = c("constant", "zero"), 
                                           selected = "output.baseline_model")),  
           
           column(1, style = 'padding-top: 20px',
                  radioButtons(inputId = "tooltip", label = "Show tooltips",
                               choices = c("yes", "no"), 
                               inline = FALSE,
                               selected = "yes")),
           column(1,
                  style = 'padding-top: 20px',
                  actionButton("reset", label = "Reset Forecasts")),  
           column(1, 
                  style = 'padding-top: 20px; padding-left: 20px',
                  actionButton("instructions", label = HTML('<b>Terms/Info</b>'), icon = NULL))),
  
  # user interface if distribution condition
  conditionalPanel(
    condition = "output.condition_distribution == true",
    source("ui-distribution-code.R", local = TRUE)$value,
  ),
  br(),
  # user interface if quantile condition
  conditionalPanel(
    condition = "output.condition_quantile == true",
    source("ui-quantile-code.R", local = TRUE)$value,
  )
)




# ------------------------------------------------------------------------------
# ------------------------------------ Server-----------------------------------
# ------------------------------------------------------------------------------

server <- function(input, output, session) {
  
  # sample random conditions ---------------------------------------------------
  # make forecasts using distributions or quantiles
  condition_distribution <- sample(c(TRUE, FALSE), 1)
  output$condition_distribution <- reactive({
    condition_distribution
  })
  output$condition_quantile <- reactive({
    !condition_distribution
  })
  
  # randomise the baseline model that is shown
  baseline_model <- sample(c("zero", "constant"), size = 1)
  output$baseline_model <- reactive({
    baseline_model
  })

  outputOptions(output, 'condition_distribution', 
                suspendWhenHidden = FALSE)
  outputOptions(output, 'condition_quantile', 
                suspendWhenHidden = FALSE)
  outputOptions(output, 'baseline_model', 
                suspendWhenHidden = FALSE)
  
  
  # source additional code needed ----------------------------------------------
  # user management system and dialog messages
  source("server-user-management.R", local = TRUE)$value
  source("dialog-messages.R", local = TRUE)$value
  
  # server code for either condition
  if (condition_distribution) {
    source("server-distribution-code.R", local = TRUE)$value
  } else {
    source("server-quantile-code.R", local = TRUE)$value
  }
  
  
  # define values for observed data visualisation ------------------------------

  # obtain the location and the type (death / cases) and inident status
  # (incident / cumulative) from the selection input field
  location_input <- reactive({
    selection_number <- which(selection_names == input$selection)
    selections$location[selection_number]
  })
  type_input <- reactive({
    selection_number <- which(selection_names == input$selection)
    selections$type[selection_number]
  })
  # this is currently not needed as all data is incident data, but may be 
  # useful in the future
  inc_input <- reactive({
    selection_number <- which(selection_names == input$selection)
    selections$inc[selection_number]
  })
  
  # define data.frame used for plotting by subsetting the dataset of all 
  # observations
  df <- reactive({
    observations %>%
      dplyr::mutate(target_end_date = as.Date(target_end_date)) %>%
      dplyr::filter(location_name == location_input(), 
                    inc == inc_input(),
                    type == type_input(),
                    target_end_date >= max(target_end_date) - input$num_past_obs * 7)
  })
  
  
  # define the prediction intervals to be shown on the plot
  # (only relevant for distribution condition)
  prediction_intervals <- reactive({
    sub(pattern = "%", replacement = "", input$ranges) %>%
      as.numeric()
  })
  
  # obtain the x-values (i.e. the dates) of the data that is plotted
  x <- reactive({
    as.Date(df()$target_end_date)
  })
  
  # obtain the x-values (i.e. the dates) of the period to be predicted
  x_pred <- reactive({
    max(x()) + seq(7, 28, 7)
  })
  
  # subset daily case data according to selection for reference plot
  tmp_cases <- reactive({
    cases_daily_inc %>%
      dplyr::mutate(date = as.Date(date)) %>%
      dplyr::filter(location_name == location_input(), 
                    date >= max(date) - input$num_past_obs * 7)
  })
  
  
  
  # create baseline forecasts --------------------------------------------------
  # normal baseline model
  baseline_median <- reactiveVal()
  baseline_sigma <- reactiveVal()
  baseline_lower <- reactiveVal()
  baseline_upper <- reactiveVal()
  
  # switch baseline forecast according to selection (and also when resetting)
  observeEvent(c(input$baseline_model, input$selection, input$reset), 
               {
                 if (input$baseline_model == "constant") {
                   last_value <- df()$value[nrow(df())]
                   
                   # assign to reactive values
                   baseline_median(rep(last_value, 4))
                   
                   baseline_sigma <-  observations %>%
                     dplyr::mutate(target_end_date = as.Date(target_end_date), 
                                   difference = c(NA, diff(log(value)))) %>%
                     dplyr::filter(location_name == location_input(), 
                                   inc == inc_input(),
                                   type == type_input(),
                                   target_end_date > max(target_end_date) - 4 * 7) %>%
                     dplyr::pull(difference) %>%
                     sd()
                   
                   # assign to reactive values
                   baseline_sigma(rep(baseline_sigma, 4))
                   
                   baseline_lower <- exp(qnorm(0.05, 
                                               mean = log(baseline_median()),
                                               sd = as.numeric(baseline_sigma())))
                   
                   baseline_lower(baseline_lower)
                   
                   baseline_upper <- exp(qnorm(0.95, 
                                               mean = log(baseline_median()),
                                               sd = as.numeric(baseline_sigma())))
                   
                   baseline_upper(baseline_upper)
                 }
                 
                 if (input$baseline_model == "zero") {
                   baseline_median(rep(0, 4))
                   baseline_sigma(rep(0, 4))
                   baseline_lower(rep(0, 4))
                   baseline_upper(rep(0, 4))
                 }
                 
                 rv$median_latent <- baseline_median()
                 rv$width_latent <- baseline_sigma()
                 rv$upper_90_latent <- baseline_upper()
                 rv$lower_90_latent <- baseline_lower()
                 
                 update_values()
                 update_numeric_inputs()
                 
               }, priority = 99)
  
  
  
  # define quantile grid and reactive values to hold forecasts -----------------
  quantile_grid <- c(0.01, 0.025, seq(0.05, 0.95, 0.05), 0.975, 0.99)
  
  rv <- reactiveValues(
    median  = NULL,
    median_latent = NULL, # latent median variable before updating
    
    # hold forecasts for large plot
    forecasts_week_1 = NULL,
    forecasts_week_2 = NULL,
    forecasts_week_2 = NULL,
    forecasts_week_4 = NULL,
    
    # varibales needed for distribution condition
    width = NA,
    width_latent = NA,
    
    # variables needed for quantile condition
    lower_90 = NA,
    lower_90_latent = NA,
    upper_90 = NA,
    upper_90_latent = NA,

    # store the selection (location and death / case)
    selection_number = NULL
    
  )
  

  # combine comments from both conditions to a reactive value ------------------
  comments <- reactive({
    paste(input$comments, input$comments_q)
  })
  

  # functionality to show instructions -----------------------------------------
  observeEvent(input$instructions,
               {
                 showModal(modalDialog(
                   title = "Instructions",
                   HTML(instructions),
                   # a("test", href = "https://google.de", target = "_blank"),
                   footer = modalButton("OK")
                 ))
               },
               ignoreNULL = TRUE)
  
  # functionality to do submissions --------------------------------------------
  observeEvent(c(input$submit, input$submit_q),
               {
                 # error handling
                 # expand this at some point to handle both conditions
                 if (!is.na(rv$median) && all(rv$median == rv$median_latent)) {
                   mismatch <- FALSE
                 } else {
                   mismatch <- TRUE
                 }
                 
                 if (Sys.Date() > app_end_date) {
                   showNotification("The app does not currently allow submissions. Please wait until next Saturday, 17:00 CET to make new predictions", type = "error")
                 } else if (mismatch) {
                   showNotification("Your forecasts don't match your inputs yet. Please press 'update' for all changes to take effect and submit again.", type = "error")
                 } else {
                   
                   if (condition_distribution) {
                     condition <- "distribution_forecast"
                   } else {
                     condition <- "quantile_forecast"
                   }
                   
                   
                   submissions <- data.frame(forecaster_id = identification()$forecaster_id, 
                                             location = unique(df()$location),
                                             location_name = location_input(),
                                             inc = inc_input(),
                                             type = type_input(),
                                             forecast_date = Sys.Date(),
                                             forecast_time = Sys.time(),
                                             forecast_week = lubridate::epiweek(Sys.Date()),
                                             expert = identification()$expert,
                                             leader_board = identification()$appearboard,
                                             name_board = "NA",
                                             forecast_type = condition,
                                             distribution = input$distribution,
                                             median = rv$median, 
                                             lower_90 = rv$lower_90,
                                             upper_90 = rv$upper_90,
                                             width = rv$width,
                                             horizon = 1:4,
                                             target_end_date = x_pred(), 
                                             assigned_baseline_model = baseline_model,
                                             chosen_baseline_model = input$baseline_model,
                                             comments = comments())
                   if(identification()$appearboard == "anonymous") {
                     submissions <- dplyr::mutate(submissions, 
                                                  name_board = "anonymous")
                   } else if (identification()$appearboard == "yes") {
                     submissions <- dplyr::mutate(submissions, 
                                                 name_board = identification()$username)
                   } else {
                     submissions <- dplyr::mutate(submissions, 
                                                  name_board = "none")
                   }
                   
                   googlesheets4::sheet_append(data = submissions,
                                               ss = spread_sheet,
                                               sheet = "predictions")
                   
                   
                   
                   rv$selection_number <- which(selection_names == input$selection) + 1
                   newSelection <- selection_names[rv$selection_number]
                   if (rv$selection_number > length(selection_names)) {
                     showNotification("Thank you for your submissions. If you completed all previous locations, you are done now!", type = "message")
                   } else {
                     showNotification("Thank you for your submissions. Here is the next data set!", type = "message")
                     updateSelectInput(session, inputId = "selection", selected = newSelection)
                   }
                 }
               }, 
               priority = 99, 
               ignoreInit = TRUE)
  
  
}

shinyApp(ui, server)