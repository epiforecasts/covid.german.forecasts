
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
    
    
  }
}




output$p_distr <- renderPlotly({
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
  
  
  
  p <- plot_ly() %>%
    add_trace(x = df()$target_end_date,
              y = df()$value, type = "scatter",
              name = 'observed data',mode = 'lines+markers') %>%     
    add_trace(x = x_pred(),
              y = rv$median, type = "scatter",
              name = 'median prediction',mode = 'lines+markers', color = I("dark green")) %>%
    layout(title = paste(input$selection, "- weekly"), list(
      xanchor = "left"
    )) %>%
    layout(xaxis = list(range = c(min(x()), max(x_pred()) + 5))) %>%
    layout(yaxis = list(hoverformat = '0f', rangemode = "tozero")) %>%
    layout(shapes = c(circles_pred)) %>%
    layout(legend = list(orientation = 'h')) %>%
    config(edits = list(shapePosition = TRUE)) 
  
  if (input$plotscale == "log") {
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


update_numeric_inputs <- function() {
  
  for (i in 1:4) {
    
    updateNumericInput(session,
                       paste0("median_forecast_", i),
                       value = round(rv$median[i], 0))
    updateNumericInput(session,
                       paste0("width_", i),
                       value = round(rv$width[i], 2))
    
  }
}

# 
# # set default values when changing a location or when resetting
# observeEvent(c(input$selection, input$reset),
#              {
#                if (zero_baseline) {
#                  rv$median_latent <- rep(0, 4)
#                  rv$width_latent <- rep(0, 4)
#                }
#                
#                else {
#                  rv$median_latent <- rep(last_value(), 4)
#                  rv$width_latent <- rep(baseline_sigma(), 4)
#                }
#                
#                
#                update_values()
#                
#                for (i in 1:4) {
#                  
#                  updateNumericInput(session,
#                                     paste0("median_forecast_", i),
#                                     value = round(rv$median[i], 0))
#                  updateNumericInput(session,
#                                     paste0("width_", i),
#                                     value = round(rv$width[i], 2))
#                  
#                }
#                
#              }, 
#              priority = 2)


# propagate values
observeEvent(c(input$propagate_1), 
             {
               for (i in 2:4) {
                 rv$median_latent[i] <- rv$median_latent[1]
                 rv$width_latent[i] <- rv$width_latent[1] #+ 0.01 * (i - 1)
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
                 rv$width_latent[i] <- rv$width_latent[2] #+ 0.01 * (i - 2)
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
                 rv$width_latent[i] <- rv$width_latent[3] #+ 0.01 * (i - 3)
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
             }, 
             priority = 99)
observeEvent(input$median_forecast_2,
             {
               rv$median_latent[2] <- input$median_forecast_2
             }, 
             priority = 99)
observeEvent(input$median_forecast_3,
             {
               rv$median_latent[3] <- input$median_forecast_3
             }, 
             priority = 99)
observeEvent(input$median_forecast_4,
             {
               rv$median_latent[4] <- input$median_forecast_4
             }, 
             priority = 99)


observeEvent(input$width_1,
             {
               rv$width_latent[1] <- input$width_1
             }, 
             priority = 99)
observeEvent(input$width_2,
             {
               rv$width_latent[2] <- input$width_2
             }, 
             priority = 99)
observeEvent(input$width_3,
             {
               rv$width_latent[3] <- input$width_3
             }, 
             priority = 99)
observeEvent(input$width_4,
             {
               rv$width_latent[4] <- input$width_4
             }, 
             priority = 99)



# Plot with daily cases
# this needs to go here as the output name needs to be different across the two
# conditions
output$plot_cases <- renderPlotly({
  
  plot <- plot_ly() %>%
    add_trace(x = tmp_cases()$date,
              y = tmp_cases()$value, type = "scatter", 
              name = 'observed data',mode = 'lines') %>%
    layout(xaxis = list(hoverformat = '0f')) %>%
    layout(yaxis = list(hoverformat = '0f', rangemode = "tozero")) %>%
    layout(title = list(text = paste("Daily cases in", location_input(), sep = " ")))
  
  if (input$plotscale == "log") {
    plot <- layout(plot, yaxis = list(type = "log"))
  }
  
  plot
  
})


# this needs to go here as the output name needs to be different across the two
# conditions
output$name_field <- renderUI({
  str1 <- paste0("<b>Name</b>: ", identification()$name)
  str11 <- paste0("<b>ID</b>: ", identification()$forecaster_id)
  str2 <- paste0("<b>Email</b>: ", identification()$email)
  str3 <- paste0("<b>Expert</b>: ", identification()$expert)
  str4 <- paste0("<b>Appear on Performance Board</b>: ", identification()$appearboard)
  str5 <- paste0("<b>Affiliation</b>: ", identification()$affiliation, ". ", identification()$website)
  HTML(paste(str1, str11, str2, str3, str4, str5, sep = '<br/>'))
})
