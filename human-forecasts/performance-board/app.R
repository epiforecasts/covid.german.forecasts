library(shiny)
library(magrittr)
library(ggplot2)
library(scoringutils)


forecast_files <- list.files("processed-forecast-data/")
file_paths <- paste0("processed-forecast-data/", forecast_files)

forecasts <- lapply(file_paths, readr::read_csv) %>%
    dplyr::bind_rows() %>%
    dplyr::filter(inc == "incident", 
                  type == "quantile") %>%
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

combined <- dplyr::inner_join(obs, forecasts)

combined_full <- dplyr::left_join(obs, forecasts)



scores <- scoringutils::eval_forecasts(combined, 
                                       summarise_by = "forecaster_id") %>%
    dplyr::mutate(forecaster_id = as.character(forecaster_id))


scores_coverage <- scoringutils::eval_forecasts(combined, 
                                                summarise_by = c("forecaster_id", 
                                                                 "range", 
                                                                 "quantile")) %>%
    dplyr::mutate(forecaster_id = as.factor(forecaster_id))

forecasters <- c("all", 
                 unique(forecasts$forecaster_id))


# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Performance Board"),
    
    fluidRow(column(2, 
                    selectInput("forecaster_selection", 
                                "Select a forecaster", 
                                choices = forecasters)),
             column(10, 
                    fluidRow(column(12, 
                                    h2("All applaud the glorious leader"),
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
    
    ids <- data.frame(forecaster_id = as.character(c("332193", "991083", "424666", 
                                                  "188218", "492860", "419395")), 
                      name = c("Sophie", "Joel", "Seb", "Nikos", "Sam", "Kath"))
    
    output$table <- renderTable({
        dplyr::inner_join(ids, scores) %>%
            dplyr::select(forecaster_id, interval_score, name) %>%
            dplyr::arrange(interval_score)
    })

    output$scoretable <- renderPlot({
        scoringutils::score_table(scores)
    })
    
    output$interval_coverage <- renderPlot({
        
        scoringutils::interval_coverage(scores_coverage, 
                                        colour = "forecaster_id")
    })
    
    output$quantile_coverage <- renderPlot({
        scoringutils::quantile_coverage(scores_coverage, 
                                        colour = "forecaster_id")
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
                dplyr::filter(forecaster_id == input$forecaster_selection, 
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
                dplyr::filter(forecaster_id == input$forecaster_selection, 
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

# 
# 
# if (input$forecaster_selection == "all") {
#     scoringutils::score_table(scores)
# } else {
#     scoringutils::score_table(scores %>%
#                                   dplyr::filter(forecaster_id == input$forecaster_selection))
# }