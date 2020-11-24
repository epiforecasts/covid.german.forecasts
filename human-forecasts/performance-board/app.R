library(shiny)
library(magrittr)
library(ggplot2)
library(scoringutils)
library(readr)
library(dplyr)

# if server
forecast_files <- list.files("processed-forecast-data/")
file_paths <- paste0("processed-forecast-data/", forecast_files)

# if local
# forecast_files <- list.files("human-forecasts/processed-forecast-data/")
# file_paths <- paste0("human-forecasts/processed-forecast-data/", forecast_files)

forecasts <- lapply(file_paths, readr::read_csv) %>%
    dplyr::bind_rows() %>%
    dplyr::filter(type == "quantile") %>%
    dplyr::rename(prediction = value) %>%
    dplyr::mutate(target_end_date = as.Date(target_end_date),
                  forecast_date = as.Date(target_end_date), 
                  type = ifelse(grepl("case", target), "cases", "deaths")) 



deaths_inc <- data.table::fread(here::here("data", "weekly-incident-deaths.csv")) %>%
    dplyr::mutate(inc = "incident", 
                  type = "deaths")

cases_inc <- data.table::fread(here::here("data", "weekly-incident-cases.csv")) %>%
    dplyr::mutate(inc = "incident", 
                  type = "cases")

obs <- dplyr::bind_rows(deaths_inc, cases_inc) %>%
    dplyr::rename(true_value = value) %>%
    dplyr::mutate(target_end_date = as.Date(target_end_date)) %>%
    dplyr::filter(epiweek >= lubridate::epiweek(Sys.Date()) - 10)

combined <- dplyr::inner_join(obs, forecasts, 
                              by = c("location", "location_name", 
                                     "target_end_date", "type"))


scores <- scoringutils::eval_forecasts(combined, 
                                       summarise_by = "board_name") %>%
    dplyr::select(-quantile_coverage, -coverage)


scores_coverage <- scoringutils::eval_forecasts(combined, 
                                                summarise_by = c("board_name", 
                                                                 "range", 
                                                                 "quantile"))

forecasters <- c("all", 
                 unique(forecasts$board_name))




ui <- fluidPage(

    # Application title
    titlePanel("Performance Board"),
    
    fluidRow(column(2, 
                    selectInput("forecaster_selection", 
                                "Select a forecaster", 
                                choices = forecasters)),
             column(10, 
                    fluidRow(column(12, 
                                    h2("Overall performance"),
                                    h5("Note that this comparison is not fair as it comapres many different time points and favours new forecasters. This will be changed in the future"),
                                    tableOutput("table"))),
                    
                    h3("Score overview"), 
                    plotOutput("scoretable"), 
                    
                    fluidRow(h3("Predictions vs. observed values")),
                    fluidRow(column(6, 
                                    h3("Germany"), 
                                    plotOutput("predictions_germany")), 
                             column(6,
                                    h3("Poland"), 
                                    plotOutput("predictions_poland"))),
                    
                    fluidRow(column(6, 
                                    h3("Interval coverage"), 
                                    plotOutput("interval_coverage")), 
                             column(6, 
                                    h3("Quantile coverage"), 
                                    plotOutput("quantile_coverage")))
                    
                    )
             )
)



# Define server logic required to draw a histogram
server <- function(input, output) {
    
    output$table <- renderTable({
        scores %>%
            dplyr::arrange(interval_score)
    })

    output$scoretable <- renderPlot({
        scoringutils::score_table(scores)
    })
    
    output$interval_coverage <- renderPlot({
        scoringutils::interval_coverage(scores_coverage, 
                                        colour = "board_name")
    })
    
    output$quantile_coverage <- renderPlot({
        scoringutils::quantile_coverage(scores_coverage, 
                                        colour = "board_name")
    })
    
    output$predictions_germany <- renderPlot({
        if(input$forecaster_selection == "all") {
            library(ggplot2)
            ggplot() + 
                annotate("text", x = 4, y = 25, size=8, 
                         label = "Please select a forecaster") + 
                theme_void()
        } else {
            combined %>%
                dplyr::filter(board_name == input$forecaster_selection, 
                              location_name == "Germany") %>%
                scoringutils::plot_predictions(x = "target_end_date", 
                                               facet_formula = type ~ horizon, 
                                               add_truth_data = obs %>%
                                                   dplyr::filter(location_name == "Germany"))
        }
        
    })
    
    output$predictions_poland <- renderPlot({
        if(input$forecaster_selection == "all") {
            library(ggplot2)
            ggplot() + 
                annotate("text", x = 4, y = 25, size=8, 
                         label = "Please select a forecaster") + 
                theme_void()
        } else {
            combined %>%
                dplyr::filter(board_name == input$forecaster_selection, 
                              location_name == "Poland") %>%
                scoringutils::plot_predictions(x = "target_end_date", 
                                               facet_formula = type ~ horizon, 
                                               add_truth_data = obs %>%
                                                   dplyr::filter(location_name == "Germany"))
        }
    })
}

# Run the application 
shinyApp(ui = ui, server = server)