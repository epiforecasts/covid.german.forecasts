library(plotly)
library(purrr)
library(shiny)

library(googledrive)
library(googlesheets4)

library(magrittr)

# Google authentification
# options(gargle_oauth_cache = ".secrets")
# options(gargle_quiet = FALSE)
# drive_auth()
# drive_auth(cache = ".secrets", email = "nikosbosse@gmail.com")

# 
# options(gargle_oauth_cache = ".secrets")
# drive_auth(cache = ".secrets", email = "epiforecasts@gmail.com")
# sheets_auth(token = drive_token())

# source(here::here("dialog-messages.R"))
source(here::here("human-forecasts", "dialog-messages.R"))

spread_sheet <- "1xdJDgZdlN7mYHJ0D0QbTcpiV9h1Dmga4jVoAg5DhaKI"

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
  dplyr::filter(epiweek < max(epiweek))


  
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
  headerPanel("Predictions"),
  
  # tags$style(HTML("
  #     #first {
  #         border: 4px double red;
  #     }
  #     #second {
  #         border: 2px dashed blue;
  #     }
  #   ")),
  fluidRow(column(1, offset = 1, 
                  actionButton("instructions", label = "Instructions", icon = NULL)), 
           column(1, 
                  actionButton("datapolicy", label = "Data Policy", icon = NULL))),
  fluidRow(column(9, plotlyOutput("p", width = "100%")), 
           column(2, 
                  offset = 0,
                  style = 'padding: 20px; border: 2px double black; background-color: aliceblue',
                  fluidRow(selectInput(inputId = "selection",
                                       label = "Selection:",
                                       choices = selection_names, 
                                       selected = "Germany")),
                  fluidRow(numericInput(inputId = "num_past_obs", 
                                        value = 12,
                                        label = "Past weeks to show")), 
                  fluidRow(selectInput(inputId = "interval_range", 
                                       choices = c(seq(10, 90, 10), 95, 98),
                                       label = "interval range", 
                                       selected = 90)), 
                  # fluidRow(numericInput(inputId = "move_forecast", 
                  #                       value = 0,
                  #                       label = "Move forecast up or down")),
                  fluidRow(column(6,textInput("first_name", label = "First name")), 
                           column(6,textInput("last_name", label = "Last name"))),
                  fluidRow(column(6, actionButton("reset", label = "Reset")), 
                           column(6, actionButton("submit", label = "Submit"))
                           )
                  )
           ),
  
  br(),
  br(),
  br(),
  
  fluidRow(
    column(6, 
           fluidRow(
             column(2, helpText("1 week ahead predictions")),
             column(2, numericInput(inputId = "median_forecast_1", 
                                    value = 0,
                                    label = "median")), 
             column(2, numericInput(inputId = "lower_90_forecast_1", 
                                    value = 0,
                                    label = "Lower 90%")),
             column(2, numericInput(inputId = "upper_90_forecast_1", 
                                    value = 0,
                                    label = "Upper 90%")),
             column(2, numericInput(inputId = "shape_log_normal_1", 
                                    value = 0,
                                    label = "Shape Log Normal"))
           ), 
           fluidRow(
             column(2, helpText("2 week ahead predictions")),
             column(2, numericInput(inputId = "median_forecast_2", 
                                    value = 0,
                                    label = "median")), 
             column(2, numericInput(inputId = "lower_90_forecast_2", 
                                    value = 0,
                                    label = "Lower 90%")), 
             column(2, numericInput(inputId = "upper_90_forecast_2", 
                                    value = 0,
                                    label = "Upper 90%")),
             column(2, numericInput(inputId = "shape_log_normal_2", 
                                    value = 0,
                                    label = "Shape Log Normal"))
           ),
           fluidRow(
             column(2, helpText("3 week ahead predictions")),
             column(2, numericInput(inputId = "median_forecast_3", 
                                    value = 0,
                                    label = "median")), 
             column(2, numericInput(inputId = "lower_90_forecast_3", 
                                    value = 0,
                                    label = "Lower 90%")), 
             column(2, numericInput(inputId = "upper_90_forecast_3", 
                                    value = 0,
                                    label = "Upper 90%")),
             column(2, numericInput(inputId = "shape_log_normal_3", 
                                    value = 0,
                                    label = "Shape Log Normal"))
           ),
           fluidRow(
             column(2, helpText("4 week ahead predictions")),
             column(2, numericInput(inputId = "median_forecast_4", 
                                    value = 0,
                                    label = "median")), 
             column(2, numericInput(inputId = "lower_90_forecast_4", 
                                    value = 0,
                                    label = "Lower 90%")), 
             column(2, numericInput(inputId = "upper_90_forecast_4", 
                                    value = 0,
                                    label = "Upper 90%")),
             column(2, numericInput(inputId = "shape_log_normal_4", 
                                    value = 0,
                                    label = "Shape Log Normal"))
           )
           ), 
    column(4, offset = 1, 
           fluidRow(plotlyOutput("plot_cases")), 
           fluidRow(plotlyOutput("forecast_distribution")))
  )
  
  # fluidRow(id = "first",
  #          column(2, selectInput(inputId = "selection", 
  #                                label = "Selection:", 
  #                                choices = selection_names, 
  #                                selected = "Germany")),
  #          column(2, numericInput(inputId = "num_past_obs", 
  #                                 value = 999,
  #                                 label = "Number of past weeks of data")),
  #          column(2, numericInput(inputId = "move_forecast", 
  #                                 value = 0,
  #                                 label = "Move forecast up or down")), 
  #          column(2, helpText("Reset forecasts"), actionButton("reset", label = "Reset")),
  #          column(2, helpText("Enter your name in the format firstname_lastname in all lower letters. Please be consistent."), 
  #                 textInput("forecaster_name", label = "Enter name")),
  #          column(2, helpText("Submit Forecasts"), actionButton("submit", label = "Submit"))
  # )
  
  
)

server <- function(input, output, session) {
  
  vline <- function(x = 0, color = "red") {
    list(
      type = "line", 
      y0 = 0, 
      y1 = 1, 
      yref = "paper",
      x0 = x, 
      x1 = x, 
      line = list(color = color)
    )
  }
  
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
  
  observations_dates <- reactive({
    
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
  
  forecaster_name <- reactive({
    
    paste(stringr::str_to_lower(input$first_name), 
          stringr::str_to_lower(input$last_name), 
          sep = "_")
  })
  
  quantile_grid <- c(0.01, 0.025, seq(0.05, 0.95, 0.05), 0.975, 0.99)

  forecast_values_x <- reactive({
    qlnorm(quantile_grid, 
           meanlog = log(rv$median[1]), 
           sdlog = rv$sigma_log_normal[1])
  })
  
  forecast_values_y <- reactive({
    dlnorm(forecast_values_x(), 
           meanlog = log(rv$median[1]), 
           sdlog = rv$sigma_log_normal[1])
  })
  
  
  tmp_cases <- reactive({
    cases_daily_inc %>%
      dplyr::mutate(date = as.Date(date)) %>%
      dplyr::filter(location_name == location_input(), 
                    date >= max(date) - input$num_past_obs * 7)
  })
  
  rv <- reactiveValues(
    median  = NULL,
    upper_50 = NULL,
    lower_50 = NULL,
    upper_90 = NULL,
    lower_90 = NULL,
    lower_quantile_level = NULL,
    upper_quantile_level = NULL,
    selection_number = NULL,
    sigma_log_normal = NULL
  )
  
  output$p <- renderPlotly({
    circles_pred <- map2(.x = x_pred(), .y  = rv$median, 
                         ~list(type = "circle",
                               # anchor circles at (mpg, wt)
                               xanchor = .x,
                               yanchor = .y,
                               # give each circle a 2 pixel diameter
                               x0 = -5, x1 = 5,
                               y0 = -5, y1 = 5,
                               xsizemode = "pixel", 
                               ysizemode = "pixel",
                               # other visual properties
                               fillcolor = "green",
                               line = list(color = "transparent"))
    )
    
    circles_upper_90 <- map2(.x = x_pred(), .y  = rv$upper_90, 
                             ~list(type = "circle",
                                   # anchor circles at (mpg, wt)
                                   xanchor = .x,
                                   yanchor = .y,
                                   # give each circle a 2 pixel diameter
                                   x0 = -5, x1 = 5,
                                   y0 = -5, y1 = 5,
                                   xsizemode = "pixel", 
                                   ysizemode = "pixel",
                                   # other visual properties
                                   fillcolor = "red",
                                   line = list(color = "transparent"))
    )
    circles_lower_90 <- map2(.x = x_pred(), .y  = rv$lower_90, 
                             ~list(type = "circle",
                                   # anchor circles at (mpg, wt)
                                   xanchor = .x,
                                   yanchor = .y,
                                   # give each circle a 2 pixel diameter
                                   x0 = -5, x1 = 5,
                                   y0 = -5, y1 = 5,
                                   xsizemode = "pixel", 
                                   ysizemode = "pixel",
                                   # other visual properties
                                   fillcolor = "red",
                                   line = list(color = "transparent"))
    )
    
    
    
    plot_ly() %>%
      add_trace(x = df()$target_end_date,
                y = df()$value, type = "scatter",
                name = 'observed data',mode = 'lines+markers') %>%     
      add_trace(x = x_pred(),
                y = rv$median, type = "scatter",
                name = 'median prediction',mode = 'lines+markers', color = I("dark green")) %>%
      add_ribbons(x = x_pred(), ymin = rv[["lower_90"]], ymax = rv$upper_90, 
                  name = "95% prediction interval",
                  line = list(color = "transparent"),
                  fillcolor = 'rgba(26,150,65,0.4)') %>%
      layout(title = paste(input$selection), list(
        xanchor = "left"
      )) %>%
      layout(xaxis = list(range = c(min(x()), max(x_pred()) + 5))) %>%
      layout(shapes = c(circles_pred, circles_upper_90, circles_lower_90)) %>%
      layout(legend = list(orientation = 'h')) %>%
      config(edits = list(shapePosition = TRUE))
    
    
    
  })
  
  
  output$plot_cases <- renderPlotly({
    
    plot_ly(height=200) %>%
      add_trace(x = tmp_cases()$target_end_date,
                y = tmp_cases()$value, type = "scatter",
                name = 'observed data',mode = 'lines') %>%
      layout(title = list(text = paste("Daily cases in", location_input(), sep = " "), 
             x = 0.1))
  })
  
  
  output$forecast_distribution <- renderPlotly({
    
    plot_ly(height=400) %>%
      add_trace(x = forecast_values_x(),
                y = forecast_values_y(), type = "scatter",
                name = 'observed data',mode = 'lines+markers') %>%
      layout(title = list(text = paste("Forecast Distribution"), 
                          x = 0.1)) %>%
      layout(shapes = list(vline(rv$median[1]), 
                           vline(rv$lower_90[1], color = "blue"), 
                           vline(rv$upper_90[1], color = "blue")))
  })
  
  # output$plot_deaths <- renderPlotly({
  #   
  #   plot_ly() %>%
  #     add_trace(x = as.Date(tmp_deaths$target_end_date),
  #               y = tmp_deaths$value, type = "scatter",
  #               name = 'observed data',mode = 'lines+markers') %>%
  #     layout(title = paste(inc_input(), "deaths in", location_input(), sep = " "))
  # })
  
  observeEvent(input$instructions, 
               {
                 showModal(modalDialog(
                   title = "Instructions",
                   HTML(instructions),
                   # a("test", href = "https://google.de", target = "_blank"), 
                   footer = modalButton("I understand and consent")
                 ))
               }, 
               ignoreNULL = FALSE)
  
  observeEvent(input$datapolicy, 
               {
                 showModal(modalDialog(
                   title = "Data Policy",
                   HTML(data_policy),
                   # a("test", href = "https://google.de", target = "_blank"), 
                   footer = modalButton("OK")
                 ))
               })
  
  # update x/y reactive values in response to changes in shape anchors
  observeEvent(event_data("plotly_relayout"), 
               {
                 ed <- event_data("plotly_relayout", priority = "input")
                 shape_anchors <- ed[grepl("^shapes.*anchor$", names(ed))]
                 if (length(shape_anchors) != 2) return()
                 row_index <- unique(readr::parse_number(names(shape_anchors)) + 1)
                 y_coord <- as.numeric(shape_anchors[2])
                 
                 if (row_index %in% 1:4) {
                   # median was moved
                   rv$median[row_index] <- y_coord
                   
                   updateNumericInput(session, 
                                      paste0("median_forecast_", row_index), 
                                      value = round(y_coord, 2))
                   
                   print("relayout trigger")
                   print(rv$median)
                 } else if (row_index %in% 5:8) {
                   # upper quantile was moved
                   rv$upper_90[row_index - 4] <- y_coord
                   updateNumericInput(session, 
                                      paste0("upper_90_forecast_", (row_index - 4)), 
                                      value = round(y_coord, 2))
                   
                 } else if (row_index %in% 9:12) {
                   # upper quantile was moved
                   rv$lower_90[row_index - 8] <- y_coord
                   updateNumericInput(session, 
                                      paste0("lower_90_forecast_", (row_index - 8)), 
                                      value = round(y_coord, 2))
                 } else if (row_index %in% 13:16) {
                   # upper quantile was moved
                   rv$lower_50[row_index - 12] <- y_coord
                 } else if (row_index %in% 17:20) {
                   # upper quantile was moved
                   rv$upper_50[row_index - 16] <- y_coord
                 }
               })
  
  # set default values when changing a location
  observeEvent(input$selection,
               {
                 print("selection trigger")
                 rv$median <- rep(last_value(), 4)
                 rv$upper_50 <- rep(last_value() * 1.7, 4)
                 rv$lower_50 <- rep(last_value() * 0.3, 4)
                 rv$upper_90 <- rep(last_value() * 2.5, 4)
                 rv$lower_90 <- rep(last_value() * 0.1, 4)
                 rv$sigma_log_normal <- rep(0.1, 4)
               }, 
               priority = 2)
  
  observeEvent(input$interval_range,
               {
                 print("interval trigger")
                 rv$lower_quantile_level <- (100 - as.numeric(input$interval_range)) / (2 * 100)
                 rv$upper_quantile_level <- 1 - rv$lower_quantile_level
               }, 
               priority = 2)
  
  observeEvent(input$reset,
               {
                 rv$median <- rep(last_value(), 4)
                 rv$upper_90 <- rep(last_value() * 2.5, 4)
                 rv$lower_90 <- rep(last_value() * 0.1, 4)
                 
                 for (i in 1:4) {
                   
                   updateNumericInput(session, 
                                      paste0("median_forecast_", i), 
                                      value = round(rv$median[i], 2))
                   updateNumericInput(session, 
                                      paste0("lower_90_forecast_", i), 
                                      value = round(rv$lower_90[i], 2))
                   updateNumericInput(session, 
                                      paste0("upper_90_forecast_", i), 
                                      value = round(rv$upper_90[i], 2))
                   updateNumericInput(session, 
                                      paste0("shape_log_normal_", i), 
                                      value = round(rv$sigma_log_normal[i], 2))
                   
                 }
                 
               }, 
               priority = -2,
               ignoreNULL = FALSE)
  
  
  observeEvent(input$submit,
               {
                 print(forecaster_name())
                 if(forecaster_name() == "") {
                   showNotification("Please enter a name", type = "error")
                 } else {
                   
                   value <- c(rv$median, rv$lower_50, rv$upper_50, 
                              rv$lower_90, rv$upper_90)
                   horizon <- rep(1:4, 5)
                   quantile <- rep(c(0.5, 0.25, 0.75, 0.05, 0.95), each = 4)
                   target_end_dates <- rep(x_pred(), 5)
                   
                   submissions <- data.frame(forecaster = forecaster_name(), 
                                             location = unique(df()$location),
                                             location_name = location_input(),
                                             inc = inc_input(),
                                             type = type_input(),
                                             forecast_date = Sys.Date(),
                                             forecast_time = Sys.time(),
                                             forecast_week = lubridate::epiweek(Sys.Date()),
                                             value = value, 
                                             quantile = quantile,
                                             horizon = horizon,
                                             target_end_date = target_end_dates)
                   
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
  
  # move forecast up or down
  observeEvent(input$move_forecast,
               {
                 # check_condition <- purrr::safely(.f = function(x) {
                 #   return(as.integer(x) == x)
                 # }, otherwise = FALSE)
                 # 
                 # if (check_condition(input$move_forecast)$result) {
                 rv$median <- rv$median + input$move_forecast
                 rv$upper_50 <- rv$upper_50 + input$move_forecast
                 rv$lower_50 <- rv$lower_50 + input$move_forecast
                 rv$upper_90 <- rv$upper_90 + input$move_forecast
                 rv$lower_90 <- rv$lower_90 + input$move_forecast
                 # }
                 
               }, 
               priority = -5)
  
  # change values by numeric input
  observeEvent(input$median_forecast_1,
               {
                 rv$median[1] <- input$median_forecast_1
               }, 
               priority = 99)
  observeEvent(input$median_forecast_2,
               {
                 rv$median[2] <- input$median_forecast_2
               }, 
               priority = 99)
  observeEvent(input$median_forecast_3,
               {
                 rv$median[3] <- input$median_forecast_3
               }, 
               priority = 99)
  observeEvent(input$median_forecast_4,
               {
                 rv$median[4] <- input$median_forecast_4
               }, 
               priority = 99)
  
  
  
  
  
  observeEvent(input$lower_90_forecast_1,
               {
                 rv$lower_90[1] <- input$lower_90_forecast_1
               }, 
               priority = 99)
  observeEvent(input$lower_90_forecast_2,
               {
                 rv$lower_90[2] <- input$lower_90_forecast_2
               }, 
               priority = 99)
  observeEvent(input$lower_90_forecast_3,
               {
                 rv$lower_90[3] <- input$lower_90_forecast_3
               }, 
               priority = 99)
  observeEvent(input$lower_90_forecast_4,
               {
                 rv$lower_90[4] <- input$lower_90_forecast_4
               }, 
               priority = 99)
  
  
  observeEvent(input$upper_90_forecast_1,
               {
                 rv$upper_90[1] <- input$upper_90_forecast_1
               }, 
               priority = 99)
  observeEvent(input$upper_90_forecast_2,
               {
                 rv$upper_90[2] <- input$upper_90_forecast_2
               }, 
               priority = 99)
  observeEvent(input$upper_90_forecast_3,
               {
                 rv$upper_90[3] <- input$upper_90_forecast_3
               }, 
               priority = 99)
  observeEvent(input$upper_90_forecast_4,
               {
                 rv$upper_90[4] <- input$upper_90_forecast_4
               }, 
               priority = 99)
  
  
  observeEvent(input$shape_log_normal_1,
               {
                 rv$sigma_log_normal[1] <- input$shape_log_normal_1
               }, 
               priority = 99)
  observeEvent(input$shape_log_normal_2,
               {
                 rv$sigma_log_normal[2] <- input$shape_log_normal_2
               }, 
               priority = 99)
  observeEvent(input$shape_log_normal_3,
               {
                 rv$sigma_log_normal[3] <- input$shape_log_normal_3
               }, 
               priority = 99)
  observeEvent(input$shape_log_normal_4,
               {
                 rv$sigma_log_normal[4] <- input$shape_log_normal_4
               }, 
               priority = 99)
}

shinyApp(ui, server)