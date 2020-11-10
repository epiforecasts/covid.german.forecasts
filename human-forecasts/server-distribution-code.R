
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


# set default values when changing a location or when resetting
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



