library(plotly)
library(purrr)
library(shiny)
library(shinyBS)
library(shinyauthr)
library(sodium)
# library(shinyjs)

library(googledrive)
library(googlesheets4)

library(magrittr)

# Google authentification
# options(gargle_oauth_cache = ".secrets")
# options(gargle_quiet = FALSE)
# drive_auth()



options(gargle_oauth_cache = ".secrets")
drive_auth(cache = ".secrets", email = "epiforecasts@gmail.com")
sheets_auth(token = drive_token())

# for server
# source(here::here("dialog-messages.R"))
# for use on computer
source(here::here("human-forecasts", "dialog-messages.R"))

spread_sheet <- "1xdJDgZdlN7mYHJ0D0QbTcpiV9h1Dmga4jVoAg5DhaKI"
identification_sheet <- "1GJ5BNcN1UfAlZSkYwgr1-AxgsVA2wtwQ9bRwZ64ZXRQ"

# load data
deaths_inc <- data.table::fread(here::here("data", "weekly-incident-deaths.csv")) %>%
  dplyr::mutate(inc = "incident", 
                type = "deaths")

cases_inc <- data.table::fread(here::here("data", "weekly-incident-cases.csv")) %>%
  dplyr::mutate(inc = "incident", 
                type = "cases")

cases_daily_inc <- data.table::fread(here::here("data", "daily-incidence-cases-Germany_Poland.csv")) %>%
  dplyr::mutate(inc = "incident", 
                type = "cases")

observations <- dplyr::bind_rows(deaths_inc, 
                                 cases_inc)  %>%
  # this has to be treated with care depending on when you update the data
  dplyr::filter(epiweek <= max(epiweek))


location_vector <- observations %>%
  dplyr::filter(!grepl("County", location_name)) %>%
  dplyr::pull(location_name) %>%
  unique()

selections <- expand.grid(list(location = location_vector, 
                               inc = c("incident"), 
                               type = c("cases", "deaths"))) %>%
  dplyr::arrange(location)

selection_names <- apply(selections, MARGIN = 1, 
                         FUN = function(x) {
                           paste(x, collapse = "-")
                         })




ui <- fluidPage(
  # headerPanel("Predictions"),
  
  # tags$style(HTML("
  #     #first {
  #         border: 4px double red;
  #     }
  #     #second {
  #         border: 2px dashed blue;
  #     }
  #   ")),
  
  shinyjs::useShinyjs(),
  
  fluidRow(column(12,
                  tipify(h2("Covid Human Forecast App"), 
                         title = "If you can't see the entire user interface, you may want to zoom out in your browser."))),
  fluidRow(column(2,
                  selectInput(inputId = "selection",
                                     label = "Selection:",
                                     choices = selection_names, 
                                     selected = "Germany")),
           column(2, 
                  numericInput(inputId = "num_past_obs", 
                                      value = 12,
                                      label = "Number of weeks to show")), 
           column(2, radioButtons("plotscale", label = "Plot Scale", selected = "linear",
                                  choices = c("linear", "logarithmic"), 
                                  inline = TRUE)),
           column(3, 
                  checkboxGroupInput("ranges", "Prediction intervals to show", 
                                            choices = c("20%", "50%", "90%", "95%"), 
                                            selected = c("50%", "90%"),
                                            inline = TRUE)),
           column(1, style = 'padding-top: 20px',
                  checkboxInput(inputId = "tooltip", label = "Show tooltips", 
                                value = TRUE)),
           column(1,
                  style = 'padding-top: 20px',
                  actionButton("reset", label = "Reset Forecasts")),  
           column(1, 
                  style = 'padding-top: 20px; padding-left: 20px',
                  actionButton("instructions", label = HTML('<b>Terms/Info</b>'), icon = NULL))),
  
  
  # code for distribution UI and quantile only UI
  # source("ui-distribution-code.R", local = TRUE)$value,
  # source("ui-quantile-code.R", local = TRUE)$value,
  
  selectInput("num", "Choose a number", 1:10),
  conditionalPanel(
    condition = "output.squa_re == true",
    "That's a perfect square!"
  ),
  br(),
  conditionalPanel(
    condition = "output.squa_re == false",
    "That's not a perfect square!"
  ),
  
 
  
  br(),
  fluidRow(column(3, actionButton("submit", label = HTML('<b>Submit</b>'))), 
           column(12, "(Please click 'update' before submitting)")), 
  br(), 
  br(), 
  br(), 
  fluidRow(column(12, textInput(inputId = "comments", 
                                label = "Do you have any additional comments, suggestions, feedback?"))), 
  fluidRow(column(12, HTML('Preferably, you can submit an issue on <a href="https://github.com/epiforecasts/covid-german-forecasts">github</a>')))
)








server <- function(input, output, session) {
  
  output$squa_re <- reactive({
    
    sqrt(as.numeric(input$num)) %% 1 == 0
  })
  outputOptions(output, 'squa_re', suspendWhenHidden = FALSE)
  
  
  
  distribut_cond <- TRUE
    #sample(c(TRUE, TRUE), 1)
  
  # distribution or quantile condition
  output$condition_distribution <- reactive({
    # distribut_cond
    distribut_cond
  })
  output$condition_quantile <- reactive({
    # !distribut_cond
    !distribut_cond
  })
  outputOptions(output, 'condition_distribution', 
                suspendWhenHidden = FALSE)
  outputOptions(output, 'condition_quantile', 
                suspendWhenHidden = FALSE)
  
  
  source("server-user-management.R", local = TRUE)$value
  
  
  
  zero_baseline <- sample(c(TRUE,FALSE), 1, prob = c(1/3, 2/3))
  
  # if (distribut_cond) {
  #   source("server-distribution-code.R", local = TRUE)$value
  # } else {
  #   source("server-quantile-code.R", local = TRUE)$value
  # }

  location_input <- reactive({
    selection_number <- which(selection_names == input$selection)
    selections$location[selection_number]
  })
  type_input <- reactive({
    selection_number <- which(selection_names == input$selection)
    selections$type[selection_number]
  })
  inc_input <- reactive({
    selection_number <- which(selection_names == input$selection)
    selections$inc[selection_number]
  })
  
  
  df <- reactive({
    observations %>%
      dplyr::mutate(target_end_date = as.Date(target_end_date)) %>%
      dplyr::filter(location_name == location_input(), 
                    inc == inc_input(),
                    type == type_input(),
                    target_end_date >= max(target_end_date) - input$num_past_obs * 7)
  })
  
  prediction_intervals <- reactive({
    sub(pattern = "%", replacement = "", input$ranges) %>%
      as.numeric()
  })
  
  x <- reactive({
    as.Date(df()$target_end_date)
  })
  
  x_pred <- reactive({
    max(x()) + seq(7, 28, 7)
  })
  
  last_value <- reactive({
    df()$value[nrow(df())]
  })
  
  baseline_sigma <- reactive({
    observations %>%
      dplyr::mutate(target_end_date = as.Date(target_end_date), 
                    difference = c(NA, diff(log(value)))) %>%
      dplyr::filter(location_name == location_input(), 
                    inc == inc_input(),
                    type == type_input(),
                    target_end_date > max(target_end_date) - 4 * 7) %>%
      dplyr::pull(difference) %>%
      sd()
  })
  
  quantile_grid <- c(0.01, 0.025, seq(0.05, 0.95, 0.05), 0.975, 0.99)
  
  
  rv <- reactiveValues(
    median  = NULL,
    median_latent = NULL, # latent median variable before updating
    # forecasts for large plot
    forecasts_week_1 = NULL,
    forecasts_week_2 = NULL,
    forecasts_week_2 = NULL,
    forecasts_week_4 = NULL,
    
    lower_90 = NULL,
    upper_90 = NULL,
    
    # lower_1 = NULL, 
    # lower_2 = NULL, 
    # lower_3 = NULL, 
    # lower_4 = NULL, 
    # 
    # upper_1 = NULL,
    # upper_2 = NULL,
    # upper_3 = NULL,
    # upper_4 = NULL,
    
    selection_number = NULL,
    width = NULL,
    width_latent = NULL
  )
  

  tmp_cases <- reactive({
    cases_daily_inc %>%
      dplyr::mutate(date = as.Date(date)) %>%
      dplyr::filter(location_name == location_input(), 
                    date >= max(date) - input$num_past_obs * 7)
  })
  
  output$name_field <- renderUI({
    str1 <- paste0("<b>Name</b>: ", credentials()$info$name)
    str11 <- paste0("<b>ID</b>: ", credentials()$info$forecaster_id)
    str2 <- paste0("<b>Email</b>: ", credentials()$info$email)
    str3 <- paste0("<b>Expert</b>: ", credentials()$info$expert)
    str4 <- paste0("<b>Appear on Performance Board</b>: ", credentials()$info$appearboard)
    str5 <- paste0("<b>Affiliation</b>: ", credentials()$info$affiliation, ", ", credentials()$info$website)
    HTML(paste(str1, str11, str2, str3, str4, str5, sep = '<br/>'))
  })
  
  
  
  
  
  
  # Plot with daily cases
  output$plot_cases <- renderPlotly({
    
    plot <- plot_ly() %>%
      add_trace(x = tmp_cases()$date,
                y = tmp_cases()$value, type = "scatter", 
                name = 'observed data',mode = 'lines') %>%
      layout(xaxis = list(hoverformat = '0f')) %>%
      layout(yaxis = list(hoverformat = '0f', rangemode = "tozero")) %>%
      layout(title = list(text = paste("Daily cases in", location_input(), sep = " ")))
    
    if (input$plotscale == "logarithmic") {
      plot <- layout(plot, yaxis = list(type = "log"))
    }
    
    plot
    
  })

  
  # Instruction button
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
  
  
  observeEvent(input$submit,
               {
                 # error handling
                 if (all(rv$median == rv$median_latent && 
                         all(rv$width == rv$width_latent))) {
                   mismatch <- FALSE
                 } else {
                   mismatch <- TRUE
                 }
                 
                 if (mismatch) {
                   showNotification("Your forecasts don't match your inputs yet. Please press 'update' for all changes to take effect and submit again.", type = "error")
                 } else {
                   
                   submissions <- data.frame(forecaster_id = credentials()$info$forecaster_id, 
                                             location = unique(df()$location),
                                             location_name = location_input(),
                                             inc = inc_input(),
                                             type = type_input(),
                                             forecast_date = Sys.Date(),
                                             forecast_time = Sys.time(),
                                             forecast_week = lubridate::epiweek(Sys.Date()),
                                             expert = credentials()$info$expert,
                                             leader_board = credentials()$info$appearboard,
                                             name_board = "NA",
                                             median = rv$median, 
                                             width = rv$width,
                                             distribution = input$distribution,
                                             horizon = 1:4,
                                             target_end_date = x_pred(), 
                                             zero_baseline = zero_baseline,
                                             comments = input$comments)
                   if(credentials()$info$appearboard == "anonymous") {
                     submissions <- dplyr::mutate(submissions, 
                                                  name_board = "anonymous")
                   } else if (credentials()$info$appearboard == "yes") {
                     submissions <- dplyr::mutate(submissions, 
                                                 name_board = credentials()$info$username)
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
               priority = 99)
  
  
}

shinyApp(ui, server)