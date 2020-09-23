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

options(gargle_oauth_cache = ".secrets")
# drive_auth(cache = ".secrets", email = "epiforecasts@gmail.com")
sheets_auth(token = drive_token())

spread_sheet <- "1xdJDgZdlN7mYHJ0D0QbTcpiV9h1Dmga4jVoAg5DhaKI"

deaths_inc <- data.table::fread(here::here("data", "weekly-incident-deaths.csv")) %>%
  dplyr::mutate(inc = "incident", 
                type = "deaths")

cases_inc <- data.table::fread(here::here("data", "weekly-incident-cases.csv")) %>%
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
  
  fluidRow(column(12, 
                  helpText("Welcome! This app allows you to make Covid-19 forecasts for Poland and Germany. You can either drag the points to adjust forecasts or use the numeric input fields. Once you are satisfied, type in your name in the format firstname_lastname and press submit. If you prefer that you can also enter a fake name, but please be conistent in the name that you use. If you want to reset the forecasts, press reset. Once you submit a forecast, the next input will be selected until you have made forecasts for all targets. You can submit multiple times if you want and we will only count the latest submission. For reference, you see a smaller plot with incident cases in the chosen location. These may help you when forecasting deaths."))),
  
  fluidRow(column(9, plotlyOutput("p", width = "100%")), 
           column(2, 
                  offset = 0,
                  style = 'padding: 20px; border: 2px double black; background-color: aliceblue',
                  fluidRow(selectInput(inputId = "selection", 
                                       label = "Selection:", 
                                       choices = selection_names, 
                                       selected = "Germany")),
                  fluidRow(numericInput(inputId = "num_past_obs", 
                                        value = 999,
                                        label = "Number of past weeks of data")), 
                  fluidRow(numericInput(inputId = "move_forecast", 
                                        value = 0,
                                        label = "Move forecast up or down")),
                  fluidRow(textInput("forecaster_name", label = "Enter name as firstname_lastname")), 
                  fluidRow(column(5, actionButton("reset", label = "Reset")), 
                           column(6, actionButton("submit", label = "Submit Forecasts"))
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
             column(2, numericInput(inputId = "lower_95_forecast_1", 
                                    value = 0,
                                    label = "Lower 95%")), 
             column(2, numericInput(inputId = "lower_50_forecast_1", 
                                    value = 0,
                                    label = "Lower 50%")), 
             column(2, numericInput(inputId = "upper_50_forecast_1", 
                                    value = 0,
                                    label = "Upper 50%")),
             column(2, numericInput(inputId = "upper_95_forecast_1", 
                                    value = 0,
                                    label = "Upper 95%"))
           ), 
           fluidRow(
             column(2, helpText("2 week ahead predictions")),
             column(2, numericInput(inputId = "median_forecast_2", 
                                    value = 0,
                                    label = "median")), 
             column(2, numericInput(inputId = "lower_95_forecast_2", 
                                    value = 0,
                                    label = "Lower 95%")), 
             column(2, numericInput(inputId = "lower_50_forecast_2", 
                                    value = 0,
                                    label = "Lower 50%")), 
             column(2, numericInput(inputId = "upper_50_forecast_2", 
                                    value = 0,
                                    label = "Upper 50%")),
             column(2, numericInput(inputId = "upper_95_forecast_2", 
                                    value = 0,
                                    label = "Upper 95%"))
           ),
           fluidRow(
             column(2, helpText("3 week ahead predictions")),
             column(2, numericInput(inputId = "median_forecast_3", 
                                    value = 0,
                                    label = "median")), 
             column(2, numericInput(inputId = "lower_95_forecast_3", 
                                    value = 0,
                                    label = "Lower 95%")), 
             column(2, numericInput(inputId = "lower_50_forecast_3", 
                                    value = 0,
                                    label = "Lower 50%")), 
             column(2, numericInput(inputId = "upper_50_forecast_3", 
                                    value = 0,
                                    label = "Upper 50%")),
             column(2, numericInput(inputId = "upper_95_forecast_3", 
                                    value = 0,
                                    label = "Upper 95%"))
           ),
           fluidRow(
             column(2, helpText("4 week ahead predictions")),
             column(2, numericInput(inputId = "median_forecast_4", 
                                    value = 0,
                                    label = "median")), 
             column(2, numericInput(inputId = "lower_95_forecast_4", 
                                    value = 0,
                                    label = "Lower 95%")), 
             column(2, numericInput(inputId = "lower_50_forecast_4", 
                                    value = 0,
                                    label = "Lower 50%")), 
             column(2, numericInput(inputId = "upper_50_forecast_4", 
                                    value = 0,
                                    label = "Upper 50%")),
             column(2, numericInput(inputId = "upper_95_forecast_4", 
                                    value = 0,
                                    label = "Upper 95%"))
           )
           ), 
    column(4, offset = 1, plotlyOutput("plot_cases"))
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
    input$forecaster_name
  })
  
  tmp_cases <- reactive({
    observations %>%
      dplyr::mutate(target_end_date = as.Date(target_end_date)) %>%
      dplyr::filter(location_name == location_input(), 
                    inc == inc_input(),
                    type == "cases",
                    target_end_date >= max(target_end_date) - input$num_past_obs * 7)
  })
  
  rv <- reactiveValues(
    median  = NULL,
    upper_50 = NULL,
    lower_50 = NULL,
    upper_95 = NULL,
    lower_95 = NULL,
    selection_number = NULL
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
    
    circles_upper_95 <- map2(.x = x_pred(), .y  = rv$upper_95, 
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
    circles_lower_95 <- map2(.x = x_pred(), .y  = rv$lower_95, 
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
    
    circles_lower_50 <- map2(.x = x_pred(), .y  = rv$lower_50, 
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
    
    circles_upper_50 <- map2(.x = x_pred(), .y  = rv$upper_50, 
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
      add_ribbons(x = x_pred(), ymin = rv$lower_95, ymax = rv$upper_95, 
                  name = "95% prediction interval",
                  line = list(color = "transparent"),
                  fillcolor = 'rgba(26,150,65,0.1)') %>%
      add_ribbons(x = x_pred(), ymin = rv$lower_50, ymax = rv$upper_50, 
                  name = "50% prediction interval",
                  line = list(color = "transparent"),
                  fillcolor = 'rgba(26,150,65,0.5)') %>%
      layout(title = paste(input$selection), list(
        xanchor = "left"
      )) %>%
      layout(xaxis = list(range = c(min(x()), max(x_pred()) + 5))) %>%
      layout(shapes = c(circles_pred, circles_upper_95, circles_lower_95, 
                        circles_lower_50, circles_upper_50)) %>%
      config(edits = list(shapePosition = TRUE))
    
    
    
  })
  
  
  output$plot_cases <- renderPlotly({
    
    plot_ly() %>%
      add_trace(x = tmp_cases()$target_end_date,
                y = tmp_cases()$value, type = "scatter",
                name = 'observed data',mode = 'lines+markers') %>%
      layout(title = list(text = paste(inc_input(), "cases in", location_input(), sep = " "), 
             x = 0.1))
  })
  
  # output$plot_deaths <- renderPlotly({
  #   
  #   plot_ly() %>%
  #     add_trace(x = as.Date(tmp_deaths$target_end_date),
  #               y = tmp_deaths$value, type = "scatter",
  #               name = 'observed data',mode = 'lines+markers') %>%
  #     layout(title = paste(inc_input(), "deaths in", location_input(), sep = " "))
  # })
  
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
                   print("relayout trigger")
                   print(rv$median)
                 } else if (row_index %in% 5:8) {
                   # upper quantile was moved
                   rv$upper_95[row_index - 4] <- y_coord
                 } else if (row_index %in% 9:12) {
                   # upper quantile was moved
                   rv$lower_95[row_index - 8] <- y_coord
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
                 rv$upper_95 <- rep(last_value() * 2.5, 4)
                 rv$lower_95 <- rep(last_value() * 0.1, 4)
               }, 
               priority = 2)
  
  observeEvent(input$reset,
               {
                 rv$median <- rep(last_value(), 4)
                 rv$upper_50 <- rep(last_value() * 1.7, 4)
                 rv$lower_50 <- rep(last_value() * 0.3, 4)
                 rv$upper_95 <- rep(last_value() * 2.5, 4)
                 rv$lower_95 <- rep(last_value() * 0.1, 4)
               }, 
               priority = 99)
  
  
  observeEvent(input$submit,
               {
                 print(forecaster_name())
                 if(forecaster_name() == "") {
                   showNotification("Please enter a name", type = "error")
                 } else {
                   
                   value <- c(rv$median, rv$lower_50, rv$upper_50, 
                              rv$lower_95, rv$upper_95)
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
                 rv$upper_95 <- rv$upper_95 + input$move_forecast
                 rv$lower_95 <- rv$lower_95 + input$move_forecast
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
  
  
  
  # lower 50
  observeEvent(input$lower_50_forecast_1,
               {
                 rv$lower_50[1] <- input$lower_50_forecast_1
               }, 
               priority = 99)
  observeEvent(input$lower_50_forecast_2,
               {
                 rv$lower_50[2] <- input$lower_50_forecast_2
               }, 
               priority = 99)
  observeEvent(input$lower_50_forecast_3,
               {
                 rv$lower_50[3] <- input$lower_50_forecast_3
               }, 
               priority = 99)
  observeEvent(input$lower_50_forecast_4,
               {
                 rv$lower_50[4] <- input$lower_50_forecast_4
               }, 
               priority = 99)
  
  
  # upper 50
  observeEvent(input$upper_50_forecast_1,
               {
                 rv$upper_50[1] <- input$upper_50_forecast_1
               }, 
               priority = 99)
  observeEvent(input$upper_50_forecast_2,
               {
                 rv$upper_50[2] <- input$upper_50_forecast_2
               }, 
               priority = 99)
  observeEvent(input$upper_50_forecast_3,
               {
                 rv$upper_50[3] <- input$upper_50_forecast_3
               }, 
               priority = 99)
  observeEvent(input$upper_50_forecast_4,
               {
                 rv$upper_50[4] <- input$upper_50_forecast_4
               }, 
               priority = 99)
  
  
  
  observeEvent(input$lower_95_forecast_1,
               {
                 rv$lower_95[1] <- input$lower_95_forecast_1
               }, 
               priority = 99)
  observeEvent(input$lower_95_forecast_2,
               {
                 rv$lower_95[2] <- input$lower_95_forecast_2
               }, 
               priority = 99)
  observeEvent(input$lower_95_forecast_3,
               {
                 rv$lower_95[3] <- input$lower_95_forecast_3
               }, 
               priority = 99)
  observeEvent(input$lower_95_forecast_4,
               {
                 rv$lower_95[4] <- input$lower_95_forecast_4
               }, 
               priority = 99)
  
  
  observeEvent(input$upper_95_forecast_1,
               {
                 rv$upper_95[1] <- input$upper_95_forecast_1
               }, 
               priority = 99)
  observeEvent(input$upper_95_forecast_2,
               {
                 rv$upper_95[2] <- input$upper_95_forecast_2
               }, 
               priority = 99)
  observeEvent(input$upper_95_forecast_3,
               {
                 rv$upper_95[3] <- input$upper_95_forecast_3
               }, 
               priority = 99)
  observeEvent(input$upper_95_forecast_4,
               {
                 rv$upper_95[4] <- input$upper_95_forecast_4
               }, 
               priority = 99)
  
}

shinyApp(ui, server)