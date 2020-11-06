library(plotly)
library(purrr)
library(shiny)
library(shinyBS)
library(shinyauthr)
library(sodium)

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
  fluidRow(column(9, 
                  tabsetPanel(type = "tabs",
                                     id = "plotpanel",
                                     tabPanel("Make a Forecast", plotlyOutput("p", height = "800px")),
                                     tabPanel("For Reference: Daily Cases",
                                              plotlyOutput("plot_cases", height = "800px")))),
           column(3, 
                  offset = 0,
                  style = 'padding: 20px; background-color: aliceblue',
                  htmlOutput("name_field"),
                  
                  br(),
                  fluidRow(column(12, h3("Forecasts"))),
                  fluidRow(column(12, selectInput(inputId = "distribution", 
                                                  label = "Select distribution", 
                                                  choices = c("log-normal", 
                                                              "normal", 
                                                              "cubic-normal", 
                                                              "fifth-power-normal", 
                                                              "seventh-power-normal"), 
                                                  selected = "log-normal"))),
                  fluidRow(column(4, 
                                  numericInput(inputId = "median_forecast_1", 
                                               value = 0,
                                               label = "Median 1", 
                                               step = 10)),
                           column(4, 
                                  numericInput(inputId = "width_1", 
                                               value = 0,
                                               label = "Width 1", 
                                               step = 0.01)), 
                           column(4, 
                                  actionButton(inputId = "propagate_1", "Propagate", 
                                                      style = 'margin-top: 25px'))
                           ), 
                  fluidRow(column(4, 
                                  numericInput(inputId = "median_forecast_2", 
                                                      value = 0,
                                                      label = "Median 2", 
                                                      step = 10)),
                           column(4, 
                                  numericInput(inputId = "width_2", 
                                                      value = 0,
                                                      label = "Width 2", 
                                                      step = 0.01)), 
                           column(4, 
                                  actionButton(inputId = "propagate_2", "Propagate", 
                                                      style = 'margin-top: 25px'))
                  ), 
                  fluidRow(column(4, 
                                  numericInput(inputId = "median_forecast_3", 
                                                      value = 0,
                                                      label = "Median 3", 
                                                      step = 10)),
                           column(4, 
                                  numericInput(inputId = "width_3", 
                                                      value = 0,
                                                      label = "Width 3", 
                                                      step = 0.01)), 
                           column(4, 
                                  actionButton(inputId = "propagate_3", "Propagate", 
                                                      style = 'margin-top: 25px'))
                  ), 
                  fluidRow(column(4, 
                                 numericInput(inputId = "median_forecast_4", 
                                                      value = 0,
                                                      label = "Median 4", 
                                                      step = 10)),
                           column(4, 
                                  numericInput(inputId = "width_4", 
                                                      value = 0,
                                                      label = "Width 4", 
                                                      step = 0.01)), 
                           column(4, 
                                  actionButton(inputId = "update_1", HTML('<b>Update</b>'), 
                                                      style = 'margin-top: 25px'))),
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
           )
)








server <- function(input, output, session) {
  
  
  
  user_base <- googlesheets4::read_sheet(ss = identification_sheet, 
                                         sheet = "ids")
  
  credentials <- callModule(shinyauthr::login, 
                            id = "login", 
                            data = user_base,
                            user_col = username,
                            pwd_col = Password,
                            log_out = reactive(logout_init()), 
                            sodium_hashed = TRUE)
  
  logout_init <- callModule(shinyauthr::logout, 
                            id = "logout", 
                            active = reactive(TRUE))
  
  
  
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
  
  zero_baseline <- sample(c(TRUE,FALSE), 1, prob = c(1/3, 2/3))
  
  update_values <- function(horizon = NULL) {

    if (is.null(horizon)) {
      steps <- 1:4
    } else {
      steps <- horizon
    }
    
    rv$median <- rv$median_latent
    rv$width <- rv$width_latent
    
    for (i in steps) {
      
      # rv[[paste0("forecasts_week_", i)]] <<- qlnorm(quantile_grid, 
      #                                               meanlog = log(rv$median[i]), 
      #                                               sdlog = as.numeric(rv$width[i]))
      
      if (input$distribution == "log-normal") {
        rv[[paste0("forecasts_week_", i)]] <<- exp(qnorm(quantile_grid, 
                                                         mean = log(rv$median[i]),
                                                         sd = as.numeric(rv$width[i])))
      } else if (input$distribution == "normal") {
        rv[[paste0("forecasts_week_", i)]] <<- (qnorm(quantile_grid, 
                                                      mean = (rv$median[i]),
                                                      sd = as.numeric(rv$width[i])))
        
      } else if (input$distribution == "cubic-normal") {
        rv[[paste0("forecasts_week_", i)]] <<- (qnorm(quantile_grid, 
                                                      mean = (rv$median[i]) ^ (1 / 3),
                                                      sd = as.numeric(rv$width[i]))) ^ 3
      } else if (input$distribution == "fifth-power-normal") {
        rv[[paste0("forecasts_week_", i)]] <<- (qnorm(quantile_grid, 
                                                      mean = (rv$median[i]) ^ (1 / 5),
                                                      sd = as.numeric(rv$width[i]))) ^ 5
      } else if (input$distribution == "seventh-power-normal") {
        rv[[paste0("forecasts_week_", i)]] <<- (qnorm(quantile_grid, 
                                                      mean = (rv$median[i]) ^ (1 / 7),
                                                      sd = as.numeric(rv$width[i]))) ^ 7
      } 
      # if (update_bounds) {
      #   rv$lower_bound[i] <<- qlnorm(as.numeric(rv$lower_quantile_level), 
      #                                meanlog = log(rv$median[i]), 
      #                                sdlog = as.numeric(rv$width[i]))
      #   rv$upper_bound[i] <<- qlnorm(as.numeric(rv$upper_quantile_level), 
      #                                meanlog = log(rv$median[i]), 
      #                                sdlog = as.numeric(rv$width[i]))
      # }
      
      
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
    
    lower_quantile_level = NULL,
    upper_quantile_level = NULL,
    # lower_bound = NULL,
    # upper_bound = NULL,
    selection_number = NULL,
    width = NULL,
    width_latent = NULL
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
      layout(yaxis = list(hoverformat = '0f', rangemode = "tozero")) %>%
      layout(shapes = c(circles_pred, circles_upper_90, circles_lower_90)) %>%
      layout(legend = list(orientation = 'h')) %>%
      config(edits = list(shapePosition = TRUE)) 
    
    if (input$plotscale == "logarithmic") {
      p <- layout(p, yaxis = list(type = "log"))
    }
    
    
    for (i in prediction_intervals()) {
      
      lower_quantile <- round((100 - i) / (2 * 100), 3)
      upper_quantile <- 1 - lower_quantile
      
      
      lower_bound <- c(rv$forecasts_week_1[round(quantile_grid, 3) == lower_quantile], 
                       rv$forecasts_week_2[round(quantile_grid, 3) == lower_quantile], 
                       rv$forecasts_week_3[round(quantile_grid, 3) == lower_quantile], 
                       rv$forecasts_week_4[round(quantile_grid, 3) == lower_quantile])
      
      
      upper_bound <- c(rv$forecasts_week_1[round(quantile_grid, 3) == upper_quantile], 
                       rv$forecasts_week_2[round(quantile_grid, 3) == upper_quantile], 
                       rv$forecasts_week_3[round(quantile_grid, 3) == upper_quantile], 
                       rv$forecasts_week_4[round(quantile_grid, 3) == upper_quantile])
      
      
      p <- p %>%
        add_ribbons(x = x_pred(), ymin = lower_bound, ymax = upper_bound,
                    name = paste0(i, "% prediction interval"),
                    line = list(color = "transparent"),
                    fillcolor = paste0("'rgba(26,150,65,", (1 - i/100 + 0.1), ")'"))
        
    }
    p
    
    
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
  
  # open Modal or close Modal once credentials have been submitted
  observeEvent(credentials()$user_auth, 
               if (credentials()$user_auth) {
                 removeModal()
               } else {
                 showModal(modalDialog(
                   loginUI(id = "login"),
                   br(), 
                   actionButton(inputId = "new_user", 
                                label = "Create New User"),
                   footer = NULL
                 ))}, 
               ignoreNULL = FALSE)
  
  observeEvent(input$new_user, 
               {
                 removeModal()
                 showModal(modalDialog(
                   size = "l",
                   title = "Terms and Instructions", 
                   HTML(instructions),
                   br(),
                   br(),
                   
                   fluidRow(column(3, actionButton(inputId = "consent", 
                                                   label = "I understand and consent")), 
                            column(3, actionButton(inputId = "backtologin", 
                                                   label = "Back to login"))),
                   footer = NULL,
                 ))
               })
  
  # open dialog to create new user
  observeEvent(input$consent, 
               {
                 removeModal()
                 showModal(modalDialog(
                   size = "l",
                   title = "Create New User", 
                   fluidRow(column(12, h3("Your Name"))),
                   fluidRow(column(12, textInput("name", label = NULL))),
                   fluidRow(column(12, "Please enter your name. (If you really do not wish to be identified, you can also enter an imaginary name or leave it blank.)")),
                   # br(),
                   fluidRow(column(12, h3("User Name and Performance Board"))),
                   fluidRow(column(6, textInput("username", label = "Your username")), 
                            column(6, tipify(radioButtons(inputId = "appearboard", label = "Appear on Performance Board?", 
                                                          choices = c("yes", "no", "anonymous"), selected = "anonymous", inline = TRUE), 
                                             title = "Do you want to appear on the Performance Board at all?"))), 
                   fluidRow(column(12, "Please provide a username needed to log in. If you select the appropriate option, this username will also appear on our performance board. If you select 'anonymous', an anonymous alias will appear instead")),
                   # br(), 
                   fluidRow(column(12, h3("Password"))),
                   fluidRow(column(6, passwordInput("password", "Choose a password")), 
                            column(6, passwordInput("password2", "Repeat password"))),
                   # br(),
                   fluidRow(column(12, h3("Email"))),
                   fluidRow(column(12, "Please submit your email, if you like. If you provide your email, we will send you weekly reminders to conduct the survey and may contact you in case of questions.")), 
                   fluidRow(column(12, textInput("email", label = "Email"))),
                   fluidRow(column(12, h3("Domain Expertise"))),
                   fluidRow(column(4, 
                                   checkboxInput(inputId = "expert", 
                                                        label = "Do you have domain expertise?")), 
                            column(4, textInput(inputId = "affiliation", label = "Affiliation")),
                            column(4, textInput(inputId = "affiliationsite", "Institution website"))),
                   fluidRow(column(12, "If you work in infectious disease modelling or have professional experience in any related field, please tick the appropriate box and state the website of the institution you are or were associated with")),
                   br(),
                   fluidRow(column(3, actionButton(inputId = "createnew2", 
                                                    label = HTML("<b>Create New User</b>"))), 
                            column(3, actionButton(inputId = "backtologin", 
                                                   label = "Back to login"))),
                   footer = NULL
                 ))
                 
               })
  
  observeEvent(input$tooltip,
               {
                 if (input$tooltip) {
                   addTooltip(session = session, 
                              id = "tooltip", 
                              title = "Toggle tooltips on and off", 
                              placement = "bottom", trigger = "hover",
                              options = NULL)
                   
                   addTooltip(session = session, 
                              id = "tooltip", 
                              title = "Toggle tooltips on and off", 
                              placement = "bottom", trigger = "hover",
                              options = NULL)
                   
                   
                   addTooltip(session = session, 
                              id = "selection", 
                              title = "Select location and data type", 
                              placement = "bottom", trigger = "hover",
                              options = NULL)
                   
                   addTooltip(session = session, 
                              id = "num_past_obs", 
                              title = "Change the number of past weeks to show on the plot", 
                              placement = "bottom", trigger = "hover",
                              options = NULL)
                   
                   addTooltip(session = session, 
                              id = "plotscale", 
                              title = "Show plot on a log or linear scale", 
                              placement = "bottom", trigger = "hover",
                              options = NULL)
                   
                   addTooltip(session = session, 
                              id = "reset", 
                              title = "Use this to reset all forecast to their previous default values", 
                              placement = "bottom", trigger = "hover",
                              options = NULL)
                   
                   addTooltip(session = session, 
                              id = "plotpanel", 
                              title = "Visualisation of the forecast/data. You can drag the points in the plot to alter predictions  forecasts. Toggle the tab to switch between forecast and data visualisation.", 
                              placement = "bottom", trigger = "hover",
                              options = NULL)
                   
                   addTooltip(session = session, 
                              id = "distribution", 
                              title = "Pick a distribution for your forecast. This allows you to specify the skew of your forecast flexibly. The behaviour of the width parameter will change according to the distribution you choose. Press update for changes to take effect", 
                              placement = "bottom", trigger = "hover",
                              options = NULL)
                   
                   addTooltip(session = session, 
                              id = "median_forecast_1", 
                              title = "Change the median forecast. This will work no matter which distribution you choose", 
                              placement = "bottom", trigger = "hover",
                              options = NULL)
                   
                   addTooltip(session = session, 
                              id = "width_1", 
                              title = "Change the width of your forecast. This will behave differently depending on the chosen distribution.", 
                              placement = "bottom", trigger = "hover",
                              options = NULL)
                   
                   addTooltip(session = session, 
                              id = "propagate_1", 
                              title = "Press to propagate changes forward to following weeks", 
                              placement = "bottom", trigger = "hover",
                              options = NULL)
                   
                   
                   addTooltip(session = session, 
                              id = "update_1", 
                              title = "Press for changes to take effect", 
                              placement = "bottom", trigger = "hover",
                              options = NULL)
                   
                   
                   addTooltip(session = session, 
                              id = "submit", 
                              title = "You can submit multiple times, but only the last submission will be counted.", 
                              placement = "bottom", trigger = "hover",
                              options = NULL)
                   
                   
                   
                 } else {
                   removeTooltip(session = session, id = "tooltip")
                   removeTooltip(session = session, id = "selection")
                   removeTooltip(session = session, id = "num_past_obs")
                   removeTooltip(session = session, id = "plotscale")
                   removeTooltip(session = session, id = "reset")
                   removeTooltip(session = session, id = "plotpanel")
                   removeTooltip(session = session, id = "distribution")
                   removeTooltip(session = session, id = "median_forecast_1")
                   removeTooltip(session = session, id = "width_1")
                   removeTooltip(session = session, id = "propagate_1")
                   removeTooltip(session = session, id = "update_1")
                   removeTooltip(session = session, id = "submit")
                 }
               })
  
  observeEvent(input$createnew2,
               {
                 if ((input$username != "") && (input$password != "")) {
                   if (input$password != input$password2) {
                     showNotification("Passwords don't match", type = "error")
                   } else {
                     showNotification("New user created", type = "message")
                     removeModal()
                     identification <- data.frame(forecaster = input$name, 
                                                  username = input$username,
                                                  password = sodium::password_store(input$password),
                                                  email = input$email,
                                                  expert = input$expert,
                                                  appearboard = input$appearboard,
                                                  affiliation = stringr::str_to_lower(input$affiliation),
                                                  website = stringr::str_to_lower(input$affiliationsite),
                                                  forecaster_id = round(runif(1) * 1000000))
                     
                     googlesheets4::sheet_append(data = identification, 
                                                 ss = identification_sheet, 
                                                 sheet = "ids")
                   }
                 } else {
                   showNotification("Username or password missing", type = "error")
                 }
               })
  
  
  observeEvent(input$backtologin,
               {
                 print("triggered")
                 # session$reload()
                 removeModal()
                 showModal(modalDialog(
                   loginUI(id = "login"),
                   br(), 
                   actionButton(inputId = "new_user", 
                                label = "Create new user"),
                   footer = NULL
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
                   rv$median_latent[row_index] <- y_coord

                   updateNumericInput(session,
                                      paste0("median_forecast_", row_index),
                                      value = round(y_coord, 0))

                   update_values()
                 } 
               })
  
  # set default values when changing a location
  observeEvent(c(input$selection, input$reset),
               {
                 if (zero_baseline) {
                   rv$median_latent <- rep(0, 4)
                   rv$width_latent <- rep(0, 4)
                 }
                 
                 else {
                   rv$median_latent <- rep(last_value(), 4)
                   rv$width_latent <- rep(baseline_sigma(), 4)
                 }
                
                 
                 update_values()
                 
                 for (i in 1:4) {
                   
                   updateNumericInput(session,
                                      paste0("median_forecast_", i),
                                      value = round(rv$median[i], 0))
                   updateNumericInput(session,
                                      paste0("width_", i),
                                      value = round(rv$width[i], 2))
                   
                 }
                 
               }, 
               priority = 2)

  
  # propagate values
  observeEvent(c(input$propagate_1), 
               {
                 for (i in 2:4) {
                   rv$median_latent[i] <- rv$median_latent[1]
                   rv$width_latent[i] <- rv$width_latent[1] + 0.01 * (i - 1)
                   updateNumericInput(session,
                                      paste0("median_forecast_", i),
                                      value = round(rv$median_latent[i], 0))
                   
                   updateNumericInput(session,
                                      paste0("width_", i),
                                      value = round(rv$width_latent[i], 2))
                 }
               })
  
  observeEvent(c(input$propagate_2), 
               {
                 for (i in 3:4) {
                   rv$median_latent[i] <- rv$median_latent[2]
                   rv$width_latent[i] <- rv$width_latent[2] + 0.01 * (i - 2)
                   updateNumericInput(session,
                                      paste0("median_forecast_", i),
                                      value = round(rv$median_latent[i], 0))
                   
                   updateNumericInput(session,
                                      paste0("width_", i),
                                      value = round(rv$width_latent[i], 2))
                 }
               })
  observeEvent(c(input$propagate_3), 
               {
                 for (i in 4:4) {
                   rv$median_latent[i] <- rv$median_latent[3]
                   rv$width_latent[i] <- rv$width_latent[3] + 0.01 * (i - 3)
                   updateNumericInput(session,
                                      paste0("median_forecast_", i),
                                      value = round(rv$median_latent[i], 0))
                   
                   updateNumericInput(session,
                                      paste0("width_", i),
                                      value = round(rv$width_latent[i], 2))
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
  
  
  observeEvent(input$width_1,
               {
                 rv$width_latent[1] <- input$width_1
                 # update_values()
               }, 
               priority = 99)
  observeEvent(input$width_2,
               {
                 rv$width_latent[2] <- input$width_2
                 # update_values()
               }, 
               priority = 99)
  observeEvent(input$width_3,
               {
                 rv$width_latent[3] <- input$width_3
                 # update_values()
               }, 
               priority = 99)
  observeEvent(input$width_4,
               {
                 rv$width_latent[4] <- input$width_4
                 # update_values()
               }, 
               priority = 99)
  
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