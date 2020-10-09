library(plotly)
library(purrr)
library(shiny)
library(shinyBS)

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
  # headerPanel("Predictions"),
  
  # tags$style(HTML("
  #     #first {
  #         border: 4px double red;
  #     }
  #     #second {
  #         border: 2px dashed blue;
  #     }
  #   ")),
  fluidRow(column(10, h1("Covid Human Forecast App")), 
           column(1,
                  style = 'padding-top: 20px',
                  tipify(actionButton("reset", label = "Reset"), 
                                   title = "Use this to reset all forecast to their previous default values", 
                                   placement = "bottom")),  
           column(1, 
                  style = 'padding-top: 20px; padding-left: 20px',
                  actionButton("instructions", label = "Instructions", icon = NULL))),
  br(),
  fluidRow(column(9, 
                  fluidRow(column(4,
                                  tipify(selectInput(inputId = "selection",
                                                     label = "Selection:",
                                                     choices = selection_names, 
                                                     selected = "Germany"), 
                                         title = "Select location and data type", 
                                         placement = "bottom")),
                           column(4, 
                                  tipify(numericInput(inputId = "num_past_obs", 
                                                      value = 12,
                                                      label = "Number of weeks to show"), 
                                         title = "Change the number of past weeks to show", 
                                         placement = "bottom")), 
                           column(4, 
                                  tipify(checkboxGroupInput("ranges", "Prediction intervals to show", 
                                                            choices = c("20%", "50%", "90%", "95%"), 
                                                            selected = "90%",
                                                            inline = TRUE), 
                                         title = "Change the prediction intervals you want to see", 
                                         placement = "top"))
                                  ),
                  tipify(tabsetPanel(type = "tabs",
                                     tabPanel("Make a Forecast", plotlyOutput("p")),
                                     tabPanel("For Reference: Show Daily Cases",
                                              plotlyOutput("plot_cases"))), 
                         title = "Visualisation of the Forecast. You can drag the points in the plot to alter the  forecasts. Toggle the tab to see more data visualisations.")
                  ),
           column(3, 
                  offset = 0,
                  style = 'padding: 20px; background-color: aliceblue',
                  # fluidRow(column(8, tipify(selectInput(inputId = "selection",
                  #                      label = "Selection:",
                  #                      choices = selection_names, 
                  #                      selected = "Germany"), 
                  #          title = "Select location and data type", 
                  #          placement = "bottom")), 
                  #          column(4, tipify(numericInput(inputId = "num_past_obs", 
                  #                                        value = 12,
                  #                                        label = "Number weeks"), 
                  #                           title = "Change the number of past weeks to show", 
                  #                           placement = "bottom"))),
                  # fluidRow(column(12,
                  #                 tipify(checkboxGroupInput("ranges", "Prediction intervals to show", 
                  #                                              choices = c("20%", "50%", "90%", "95%"), 
                  #                                              selected = "90%",
                  #                                              inline = TRUE), 
                  #                           title = "Change the prediction intervals you want to see", 
                  #                           placement = "top"))),
                  fluidRow(column(8, 
                                  fluidRow(column(6, textInput("first_name", label = "First name")), 
                                           column(6, textInput("last_name", label = "Last name"))), 
                                  fluidRow(column(12, tipify(textInput("leaderboardname", label = "Name for Performance Board"), 
                                                             title = "The name with which you want to appear on the Performance Board")))),
                           column(4, tipify(radioButtons(inputId = "appearboard", label = "Appear on the Performance Board?", 
                                                                choices = c("yes", "no", "anonymous"), selected = "anonymous", inline = FALSE), 
                                                   title = "Do you want to appear on the Performance Board at all?"))),
                  fluidRow(column(12, textInput("email", label = "Email"))),
                  fluidRow(column(12, 
                                  tipify(checkboxInput(inputId = "expert", 
                                                       label = "Do you have domain expertise?"),
                                         title = "Do you work in infectious disease modelling, have professional experience in any related field, or have spent a lot of time thinking about forecasting or Covid-19?", 
                                         placement = "left"))),
                  fluidRow(column(6, tipify(actionButton("submit", label = "Submit"), 
                                            title = "You can submit multiple times, but only the last submission will be counted.",
                                            placement = "bottom"))), 
                  
                  br(),
                  fluidRow(column(12, h3("Forecasts"))),
                  fluidRow(column(4, 
                                  tipify(numericInput(inputId = "median_forecast_1", 
                                                      value = 0,
                                                      label = "Median 1", 
                                                      step = 10), 
                                         title = "Change the median forecast. This corresponds to the location parameter of a log-normal distribution. Click update for changes to take effect.")),
                           column(4, 
                                  tipify(numericInput(inputId = "shape_log_normal_1", 
                                                      value = 0,
                                                      label = "Width 1", 
                                                      step = 0.01),
                                         title = "Change the shape parameter of the log-normal distribution to make forecasts wider or narrower, Click update for changes to take effect.")), 
                           column(4, 
                                  tipify(actionButton(inputId = "propagate_1", "Propagate", 
                                                      style = 'margin-top: 25px'), 
                                         title = "Press to propagate changes forward to following weeks"))
                           ), 
                  fluidRow(column(4, 
                                  tipify(numericInput(inputId = "median_forecast_2", 
                                                      value = 0,
                                                      label = "Median 2", 
                                                      step = 10), 
                                         title = "Change the median forecast. This corresponds to the location parameter of a log-normal distribution. Click update for changes to take effect.")),
                           column(4, 
                                  tipify(numericInput(inputId = "shape_log_normal_2", 
                                                      value = 0,
                                                      label = "Width 2", 
                                                      step = 0.01),
                                         title = "Change the shape parameter of the log-normal distribution to make forecasts wider or narrower, Click update for changes to take effect.")), 
                           column(4, 
                                  tipify(actionButton(inputId = "propagate_2", "Propagate", 
                                                      style = 'margin-top: 25px'), 
                                         title = "Press to propagate changes forward to following weeks"))
                  ), 
                  fluidRow(column(4, 
                                  tipify(numericInput(inputId = "median_forecast_3", 
                                                      value = 0,
                                                      label = "Median 3", 
                                                      step = 10), 
                                         title = "Change the median forecast. This corresponds to the location parameter of a log-normal distribution. Click update for changes to take effect.")),
                           column(4, 
                                  tipify(numericInput(inputId = "shape_log_normal_3", 
                                                      value = 0,
                                                      label = "Width 3", 
                                                      step = 0.01),
                                         title = "Change the shape parameter of the log-normal distribution to make forecasts wider or narrower, Click update for changes to take effect.")), 
                           column(4, 
                                  tipify(actionButton(inputId = "propagate_3", "Propagate", 
                                                      style = 'margin-top: 25px'), 
                                         title = "Press to propagate changes forward to following weeks"))
                  ), 
                  fluidRow(column(4, 
                                  tipify(numericInput(inputId = "median_forecast_4", 
                                                      value = 0,
                                                      label = "Median 4", 
                                                      step = 10), 
                                         title = "Change the median forecast. This corresponds to the location parameter of a log-normal distribution. Click update for changes to take effect.")),
                           column(4, 
                                  tipify(numericInput(inputId = "shape_log_normal_4", 
                                                      value = 0,
                                                      label = "Width 4", 
                                                      step = 0.01),
                                         title = "Change the shape parameter of the log-normal distribution to make forecasts wider or narrower, Click update for changes to take effect.")), 
                           column(4, 
                                  tipify(actionButton(inputId = "update_1", HTML('<b>Update</b>'), 
                                                      style = 'margin-top: 25px'), 
                                         title = "Press for your changes to take effect"))
                  ), 
                  
                  )
           ),

  fluidRow(column(3, 
                  h3("One week ahead forecast"),
                  style = 'padding-left: 30px; padding-right: 30px; background-color: aliceblue',
                  fluidRow(column(3,  tipify(numericInput(inputId = "median_forecast_1", 
                                                   value = 0,
                                                   label = "Median"), 
                                             title = "Change the median forecast. This corresponds to the location parameter of a log-normal distribution. Click update for changes to take effect.")), 
                           column(3,  tipify(numericInput(inputId = "shape_log_normal_1", 
                                                   value = 0,
                                                   label = "Width", 
                                                   step = 0.01),
                                             title = "Change the shape parameter of the log-normal distribution to make forecasts wider or narrower, Click update for changes to take effect.")), 
                           column(3, tipify(actionButton(inputId = "propagate_1", "Propagate", 
                                                         style = 'margin-top: 25px'), 
                                            title = "Press to propagate changes forward to following weeks")),
                           column(3, tipify(actionButton(inputId = "update_1", "Update", 
                                                         style = 'margin-top: 25px'), 
                                            title = "Press so that your changes take effect"))),
                  tipify(fluidRow(plotlyOutput("forecast_distribution_1")),
                         placement = "top",
                         title = "Visualisation of your forecast distribution (log-normal). The red line shows the median prediction, blue lines show the boundaries of the selected prediction intervals. High values on the y-axis indicate a high probability given to a specific value")),
           column(3, 
                  h3("Two week ahead forecast"),
                  style = 'padding-left: 30px; padding-right: 30px; background-color: aliceblue',
                  fluidRow(column(3,  tipify(numericInput(inputId = "median_forecast_2", 
                                                          value = 0,
                                                          label = "Median"), 
                                             title = "Change the median forecast. This corresponds to the location parameter of a log-normal distribution. Click update for changes to take effect.")), 
                           column(3,  tipify(numericInput(inputId = "shape_log_normal_2", 
                                                          value = 0,
                                                          label = "Width", 
                                                          step = 0.01),
                                             title = "Change the shape parameter of the log-normal distribution to make forecasts wider or narrower, Click update for changes to take effect.")), 
                           column(3, tipify(actionButton(inputId = "propagate_2", "Propagate", 
                                                         style = 'margin-top: 25px'), 
                                            title = "Press to propagate changes forward to following weeks")),
                           column(3, tipify(actionButton(inputId = "update_2", "Update", 
                                                         style = 'margin-top: 25px'), 
                                            title = "Press so that your changes take effect"))),
                  tipify(fluidRow(plotlyOutput("forecast_distribution_2")),
                         placement = "left",
                         title = "Visualisation of your forecast distribution (log-normal). The red line shows the median prediction, blue lines show the boundaries of the selected prediction intervals. High values on the y-axis indicate a high probability given to a specific value")), 
           column(3, 
                  h3("Three week ahead forecast"),
                  style = 'padding-left: 30px; padding-right: 30px; background-color: aliceblue',
                  fluidRow(column(3,  tipify(numericInput(inputId = "median_forecast_3", 
                                                          value = 0,
                                                          label = "Median"), 
                                             title = "Change the median forecast. This corresponds to the location parameter of a log-normal distribution. Click update for changes to take effect.")), 
                           column(3,  tipify(numericInput(inputId = "shape_log_normal_3", 
                                                          value = 0,
                                                          label = "Width", 
                                                          step = 0.01),
                                             title = "Change the shape parameter of the log-normal distribution to make forecasts wider or narrower, Click update for changes to take effect.")), 
                           column(3, tipify(actionButton(inputId = "propagate_3", "Propagate", 
                                                         style = 'margin-top: 25px'), 
                                            title = "Press to propagate changes forward to following weeks")),
                           column(3, tipify(actionButton(inputId = "update_3", "Update", 
                                                         style = 'margin-top: 25px'), 
                                            title = "Press so that your changes take effect"))),
                  tipify(fluidRow(plotlyOutput("forecast_distribution_3")),
                         placement = "top",
                         title = "Visualisation of your forecast distribution (log-normal). The red line shows the median prediction, blue lines show the boundaries of the selected prediction intervals. High values on the y-axis indicate a high probability given to a specific value")), 
           column(3, 
                  h3("Four week ahead forecast"),
                  style = 'padding-left: 30px; padding-right: 30px; background-color: aliceblue',
                  fluidRow(column(3,  tipify(numericInput(inputId = "median_forecast_4", 
                                                          value = 0,
                                                          label = "Median"), 
                                             title = "Change the median forecast. This corresponds to the location parameter of a log-normal distribution. Click update for changes to take effect.")), 
                           column(3,  tipify(numericInput(inputId = "shape_log_normal_4", 
                                                          value = 0,
                                                          label = "Width", 
                                                          step = 0.01),
                                             title = "Change the shape parameter of the log-normal distribution to make forecasts wider or narrower, Click update for changes to take effect.")), 
                           column(3, tipify(actionButton(inputId = "update_4", "Update", 
                                                         style = 'margin-top: 25px'), 
                                            title = "Press so that your changes take effect"))),
                  tipify(fluidRow(plotlyOutput("forecast_distribution_4")),
                         placement = "top",
                         title = "Visualisation of your forecast distribution (log-normal). The red line shows the median prediction, blue lines show the boundaries of the selected prediction intervals. High values on the y-axis indicate a high probability given to a specific value"))
  ),
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
  
  update_values <- function(horizon = NULL, 
                            update_forecasts = TRUE, 
                            update_bounds = TRUE) {
    
    if (is.null(horizon)) {
      steps <- 1:4
    } else {
      steps <- horizon
    }
    
    rv$median <- rv$median_latent
    rv$sigma_log_normal <- rv$sigma_log_normal_latent
    
    for (i in steps) {
      if (update_forecasts) {
        rv[[paste0("forecasts_week_", i)]] <<- qlnorm(quantile_grid, 
                                                      meanlog = log(rv$median[i]), 
                                                      sdlog = as.numeric(rv$sigma_log_normal[i]))
        rv[[paste0("forecast_values_y_", i)]] <- dlnorm(rv[[paste0("forecasts_week_", i)]],
                                                        meanlog = log(rv$median[i]), 
                                                        sdlog = rv$sigma_log_normal[i])
      }
      if (update_bounds) {
        rv$lower_bound[i] <<- qlnorm(as.numeric(rv$lower_quantile_level), 
                                     meanlog = log(rv$median[i]), 
                                     sdlog = as.numeric(rv$sigma_log_normal[i]))
        rv$upper_bound[i] <<- qlnorm(as.numeric(rv$upper_quantile_level), 
                                     meanlog = log(rv$median[i]), 
                                     sdlog = as.numeric(rv$sigma_log_normal[i]))
      }
    }
    
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
  
  forecaster_name <- reactive({
    
    paste(stringr::str_to_lower(input$first_name), 
          stringr::str_to_lower(input$last_name), 
          sep = "_")
  })
  
  quantile_grid <- c(0.01, 0.025, seq(0.05, 0.95, 0.05), 0.975, 0.99)

  tmp_cases <- reactive({
    cases_daily_inc %>%
      dplyr::mutate(date = as.Date(date)) %>%
      dplyr::filter(location_name == location_input(), 
                    date >= max(date) - input$num_past_obs * 7)
  })
  
  rv <- reactiveValues(
    median  = NULL,
    median_latent = NULL, # latent median variable before updating
    # forecasts for large plot
    forecasts_week_1 = NULL,
    forecasts_week_2 = NULL,
    forecasts_week_2 = NULL,
    forecasts_week_4 = NULL,
    
    #forecasts for individual week plots
    forecast_values_y_1 = NULL,
    forecast_values_y_2 = NULL,
    forecast_values_y_3 = NULL,
    forecast_values_y_4 = NULL,
    
    lower_quantile_level = NULL,
    upper_quantile_level = NULL,
    lower_bound = NULL,
    upper_bound = NULL,
    selection_number = NULL,
    sigma_log_normal = NULL,
    sigma_log_normal_latent = NULL
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
    
    
    
    p <- plot_ly() %>%
      add_trace(x = df()$target_end_date,
                y = df()$value, type = "scatter",
                name = 'observed data',mode = 'lines+markers') %>%     
      add_trace(x = x_pred(),
                y = rv$median, type = "scatter",
                name = 'median prediction',mode = 'lines+markers', color = I("dark green")) %>%
      layout(title = paste(input$selection), list(
        xanchor = "left"
      )) %>%
      layout(xaxis = list(range = c(min(x()), max(x_pred()) + 5))) %>%
      layout(yaxis = list(hoverformat = '.1f', rangemode = "tozero")) %>%
      layout(shapes = c(circles_pred, circles_upper_90, circles_lower_90)) %>%
      layout(legend = list(orientation = 'h')) %>%
      config(edits = list(shapePosition = TRUE))
    
    for (i in prediction_intervals()) {
      
      lower_quantile <- round((100 - i) / (2 * 100), 3)
      upper_quantile <- 1 - lower_quantile
      
      print(quantile_grid)
      print(paste("ul",quantile_grid - upper_quantile))
      
      lower_bound <- c(rv$forecasts_week_1[round(quantile_grid, 3) == lower_quantile], 
                       rv$forecasts_week_2[round(quantile_grid, 3) == lower_quantile], 
                       rv$forecasts_week_3[round(quantile_grid, 3) == lower_quantile], 
                       rv$forecasts_week_4[round(quantile_grid, 3) == lower_quantile])
      print(lower_bound)
      
      upper_bound <- c(rv$forecasts_week_1[round(quantile_grid, 3) == upper_quantile], 
                       rv$forecasts_week_2[round(quantile_grid, 3) == upper_quantile], 
                       rv$forecasts_week_3[round(quantile_grid, 3) == upper_quantile], 
                       rv$forecasts_week_4[round(quantile_grid, 3) == upper_quantile])
      print(paste("test", upper_bound))
      
      p <- p %>%
        add_ribbons(x = x_pred(), ymin = lower_bound, ymax = upper_bound,
                    name = paste0(i, "% prediction interval"),
                    line = list(color = "transparent"),
                    fillcolor = paste0("'rgba(26,150,65,", (1 - i/100 + 0.1), ")'"))
        
    }
    p
    
    
  })
  
  
  output$plot_cases <- renderPlotly({
    
    plot_ly() %>%
      add_trace(x = tmp_cases()$date,
                y = tmp_cases()$value, type = "scatter", 
                name = 'observed data',mode = 'lines') %>%
      layout(xaxis = list(hoverformat = '.1f')) %>%
      layout(yaxis = list(hoverformat = '.1f', rangemode = "tozero")) %>%
      layout(title = list(text = paste("Daily cases in", location_input(), sep = " ")))
  })
  

  output$forecast_distribution_1 <- renderPlotly({
    
    plot_ly() %>%
      add_trace(x = rv$forecasts_week_1,
                y = rv$forecast_values_y_1, type = "scatter",
                color = I("dark green"),
                name = 'observed data',mode = 'lines+markers') %>%
      layout(xaxis = list(hoverformat = '.1f')) %>%
      layout(yaxis = list(hoverformat = '.1f', rangemode = "tozero")) %>%
      layout(title = list(text = paste("Forecast Distribution"), 
                          x = 0.1)) %>%
      layout(shapes = list(vline(rv$median[1]), 
                           vline(rv$lower_bound[1], color = "CornflowerBlue"), 
                           vline(rv$upper_bound[1], color = "CornflowerBlue")))
  })
  output$forecast_distribution_2 <- renderPlotly({
    
    plot_ly() %>%
      add_trace(x = rv$forecasts_week_2,
                y = rv$forecast_values_y_2, type = "scatter",
                color = I("dark green"),
                name = 'observed data',mode = 'lines+markers') %>%
      layout(title = list(text = paste("Forecast Distribution"), 
                          x = 0.1)) %>%
      layout(xaxis = list(hoverformat = '.1f')) %>%
      layout(yaxis = list(hoverformat = '.1f', rangemode = "tozero")) %>%
      layout(shapes = list(vline(rv$median[2]), 
                           vline(rv$lower_bound[2], color = "CornflowerBlue"), 
                           vline(rv$upper_bound[2], color = "CornflowerBlue")))
  })
  output$forecast_distribution_3 <- renderPlotly({
    
    plot_ly() %>%
      add_trace(x = rv$forecasts_week_3,
                y = rv$forecast_values_y_3, type = "scatter",
                color = I("dark green"),
                name = 'observed data',mode = 'lines+markers') %>%
      layout(title = list(text = paste("Forecast Distribution"), 
                          x = 0.1)) %>%
      layout(xaxis = list(hoverformat = '.1f')) %>%
      layout(yaxis = list(hoverformat = '.1f', rangemode = "tozero")) %>%
      layout(shapes = list(vline(rv$median[3]), 
                           vline(rv$lower_bound[3], color = "CornflowerBlue"), 
                           vline(rv$upper_bound[3], color = "CornflowerBlue")))
  })
  output$forecast_distribution_4 <- renderPlotly({
    
    plot_ly() %>%
      add_trace(x = rv$forecasts_week_4,
                y = rv$forecast_values_y_4, type = "scatter",
                color = I("dark green"),
                name = 'observed data',mode = 'lines+markers') %>%
      layout(title = list(text = paste("Forecast Distribution"), 
                          x = 0.1)) %>%
      layout(xaxis = list(hoverformat = '.1f')) %>%
      layout(yaxis = list(hoverformat = '.1f', rangemode = "tozero")) %>%
      layout(shapes = list(vline(rv$median[4]), 
                           vline(rv$lower_bound[4], color = "CornflowerBlue"), 
                           vline(rv$upper_bound[4], color = "CornflowerBlue")))
  })

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
                   rv$median_latent[row_index] <- y_coord

                   updateNumericInput(session,
                                      paste0("median_forecast_", row_index),
                                      value = round(y_coord, 2))

                   update_values()
                 } 
               })
  
  # set default values when changing a location
  observeEvent(c(input$selection, input$reset),
               {
                 rv$median_latent <- rep(last_value(), 4)
                 rv$sigma_log_normal_latent <- rep(0.1, 4)
                 
                 update_values()
                 
                 for (i in 1:4) {
                   
                   updateNumericInput(session,
                                      paste0("median_forecast_", i),
                                      value = round(rv$median[i], 2))
                   updateNumericInput(session,
                                      paste0("shape_log_normal_", i),
                                      value = round(rv$sigma_log_normal[i], 2))
                   
                 }
                 
               }, 
               priority = 2)

  
  # propagate values
  observeEvent(c(input$propagate_1), 
               {
                 for (i in 2:4) {
                   rv$median_latent[i] <- rv$median_latent[1]
                   rv$sigma_log_normal_latent[i] <- rv$sigma_log_normal_latent[1]
                   updateNumericInput(session,
                                      paste0("median_forecast_", i),
                                      value = round(rv$median_latent[i], 2))
                   print(round(rv$sigma_log_normal_latent[i], 3))
                   updateNumericInput(session,
                                      paste0("shape_log_normal_", i),
                                      value = round(rv$sigma_log_normal_latent[i], 2))
                 }
               })
  
  observeEvent(c(input$propagate_2), 
               {
                 for (i in 3:4) {
                   rv$median_latent[i] <- rv$median_latent[2]
                   rv$sigma_log_normal_latent[i] <- rv$sigma_log_normal_latent[2]
                   updateNumericInput(session,
                                      paste0("median_forecast_", i),
                                      value = round(rv$median_latent[i], 2))
                   print(round(rv$sigma_log_normal_latent[i], 3))
                   updateNumericInput(session,
                                      paste0("shape_log_normal_", i),
                                      value = round(rv$sigma_log_normal_latent[i], 2))
                 }
               })
  observeEvent(c(input$propagate_3), 
               {
                 for (i in 4:4) {
                   rv$median_latent[i] <- rv$median_latent[3]
                   rv$sigma_log_normal_latent[i] <- rv$sigma_log_normal_latent[3]
                   updateNumericInput(session,
                                      paste0("median_forecast_", i),
                                      value = round(rv$median_latent[i], 2))
                   print(round(rv$sigma_log_normal_latent[i], 3))
                   updateNumericInput(session,
                                      paste0("shape_log_normal_", i),
                                      value = round(rv$sigma_log_normal_latent[i], 2))
                 }
               })
  
  # update
  observeEvent(c(input$update_1, input$update_2, input$update_3, input$update_4), 
               {
                 update_values()
               })


  # change values by numeric input
  observeEvent(input$median_forecast_1,
               {
                 rv$median_latent[1] <- input$median_forecast_1
                 # update_values()
               }, 
               priority = 99)
  observeEvent(input$median_forecast_2,
               {
                 rv$median_latent[2] <- input$median_forecast_2
                 # update_values()
               }, 
               priority = 99)
  observeEvent(input$median_forecast_3,
               {
                 rv$median_latent[3] <- input$median_forecast_3
                 # update_values()
               }, 
               priority = 99)
  observeEvent(input$median_forecast_4,
               {
                 rv$median_latent[4] <- input$median_forecast_4
                 # update_values()
               }, 
               priority = 99)
  
  
  observeEvent(input$shape_log_normal_1,
               {
                 rv$sigma_log_normal_latent[1] <- input$shape_log_normal_1
                 
                 # update_values()
               }, 
               priority = 99)
  observeEvent(input$shape_log_normal_2,
               {
                 rv$sigma_log_normal_latent[2] <- input$shape_log_normal_2
                 # update_values()
               }, 
               priority = 99)
  observeEvent(input$shape_log_normal_3,
               {
                 rv$sigma_log_normal_latent[3] <- input$shape_log_normal_3
                 # update_values()
               }, 
               priority = 99)
  observeEvent(input$shape_log_normal_4,
               {
                 rv$sigma_log_normal_latent[4] <- input$shape_log_normal_4
                 # update_values()
               }, 
               priority = 99)
  
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
  
}

shinyApp(ui, server)