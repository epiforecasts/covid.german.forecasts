output$p_quant <- renderPlotly({
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
  
  
  
  plot <- plot_ly() %>%
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
    layout(title = paste(input$selection, "- weekly"), list(
      xanchor = "left"
    )) %>%
    layout(xaxis = list(range = c(min(x()), max(x_pred()) + 5))) %>%
    layout(shapes = c(circles_pred, circles_upper_90, circles_lower_90)) %>%
    layout(legend = list(orientation = 'h', yanchor = "top")) %>%
    config(edits = list(shapePosition = TRUE))
  
  if (input$plotscale == "log") {
    plot <- layout(plot, yaxis = list(type = "log"))
  }
  plot
  
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
                 
                 # updateNumericInput(session, 
                 #                    paste0("median_forecast_", row_index, "_q"), 
                 #                    value = round(y_coord, 2))
                 
               } else if (row_index %in% 5:8) {
                 # upper quantile was moved
                 rv$upper_90_latent[row_index - 4] <- y_coord
                 # updateNumericInput(session, 
                 #                    paste0("upper_90_forecast_", (row_index - 4), "_q"), 
                 #                    value = round(y_coord, 2))
                 
               } else if (row_index %in% 9:12) {
                 # upper quantile was moved
                 rv$lower_90_latent[row_index - 8] <- y_coord
                 # updateNumericInput(session, 
                 #                    paste0("lower_90_forecast_", (row_index - 8)), "_q", 
                 #                    value = round(y_coord, 2))
               } 
               
               update_values()
               update_numeric_inputs()
               
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
  
  if (input$plotscale == "log") {
    plot <- layout(plot, yaxis = list(type = "log"))
  }
  
  plot
  
})


output$name_field_q <- renderUI({
  str1 <- paste0("<b>Name</b>: ", identification()$name)
  str11 <- paste0("<b>ID</b>: ", identification()$forecaster_id)
  str2 <- paste0("<b>Email</b>: ", identification()$email)
  str3 <- paste0("<b>Expert</b>: ", identification()$expert)
  str4 <- paste0("<b>Appear on Performance Board</b>: ", identification()$appearboard)
  str5 <- paste0("<b>Affiliation</b>: ", identification()$affiliation, ". ", identification()$website)
  HTML(paste(str1, str11, str2, str3, str4, str5, sep = '<br/>'))
})


update_values <- function(horizon = NULL) {
  
  if (is.null(horizon)) {
    steps <- 1:4
  } else {
    steps <- horizon
  }
  
  rv$median <- rv$median_latent
  rv$upper_90 <- rv$upper_90_latent
  rv$lower_90 <- rv$lower_90_latent
  
  for (i in steps) {
    
  }
}


update_numeric_inputs <- function() {
  for (i in 1:4) {
    
    updateNumericInput(session,
                       paste0("median_forecast_", i, "_q"),
                       value = round(rv$median_latent[i], 0))
    updateNumericInput(session,
                       paste0("upper_90_forecast_", i, "_q"),
                       value = round(rv$upper_90_latent[i], 0))
    updateNumericInput(session,
                       paste0("lower_90_forecast_", i, "_q"),
                       value = round(rv$lower_90_latent[i], 0))
    
  }
}



# propagate values
observeEvent(c(input$propagate_1_q), 
             {
               for (i in 2:4) {
                 rv$median_latent[i] <- rv$median_latent[1]
                 rv$lower_90_latent[i] <- rv$lower_90_latent[1]
                 rv$upper_90_latent[i] <- rv$upper_90_latent[1]
               }
               update_numeric_inputs()
             })

observeEvent(c(input$propagate_2_q), 
             {
               for (i in 3:4) {
                 rv$median_latent[i] <- rv$median_latent[2]
                 rv$lower_90_latent[i] <- rv$lower_90_latent[2]
                 rv$upper_90_latent[i] <- rv$upper_90_latent[2]
               }
               update_numeric_inputs()
             })


observeEvent(c(input$propagate_3_q), 
             {
               for (i in 3:4) {
                 rv$median_latent[i] <- rv$median_latent[3]
                 rv$lower_90_latent[i] <- rv$lower_90_latent[3]
                 rv$upper_90_latent[i] <- rv$upper_90_latent[3]
               }
               update_numeric_inputs()
             })


# -------------------------------------------------
# change values by numeric input
observeEvent(input$median_forecast_1_q,
             {
               rv$median_latent[1] <- input$median_forecast_1_q
               # update_values()
             }, 
             priority = 99)
observeEvent(input$median_forecast_2_q,
             {
               rv$median_latent[2] <- input$median_forecast_2_q
               # update_values()
             }, 
             priority = 99)
observeEvent(input$median_forecast_3_q,
             {
               rv$median_latent[3] <- input$median_forecast_3_q
               # update_values()
             }, 
             priority = 99)
observeEvent(input$median_forecast_4_q,
             {
               rv$median_latent[4] <- input$median_forecast_4_q
               # update_values()
             }, 
             priority = 99)


observeEvent(input$upper_90_forecast_1_q,
             {
               rv$upper_90_latent[1] <- input$upper_90_forecast_1_q
               # update_values()
             }, 
             priority = 99)
observeEvent(input$upper_90_forecast_2_q,
             {
               rv$upper_90_latent[2] <- input$upper_90_forecast_2_q
               # update_values()
             }, 
             priority = 99)
observeEvent(input$upper_90_forecast_3_q,
             {
               rv$upper_90_latent[3] <- input$upper_90_forecast_3_q
               # update_values()
             }, 
             priority = 99)

observeEvent(input$upper_90_forecast_4_q,
             {
               rv$upper_90_latent[4] <- input$upper_90_forecast_4_q
               # update_values()
             }, 
             priority = 99)

observeEvent(input$lower_90_forecast_1_q,
             {
               rv$lower_90_latent[1] <- input$lower_90_forecast_1_q
               # update_values()
             }, 
             priority = 99)
observeEvent(input$lower_90_forecast_2_q,
             {
               rv$lower_90_latent[2] <- input$lower_90_forecast_2_q
               # update_values()
             }, 
             priority = 99)
observeEvent(input$lower_90_forecast_3_q,
             {
               rv$lower_90_latent[3] <- input$lower_90_forecast_3_q
               # update_values()
             }, 
             priority = 99)

observeEvent(input$upper_90_forecast_4_q,
             {
               rv$lower_90_latent[4] <- input$lower_90_forecast_4_q
               # update_values()
             }, 
             priority = 99)


# update
observeEvent(c(input$update_q), 
             {
               update_values()
             })



observeEvent(input$tooltip,
             {
               if (input$tooltip == "yes") {
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
                            id = "plotpanel_q", 
                            title = "Visualisation of the forecast/data. You can drag the points in the plot to alter predictions  forecasts. Toggle the tab to switch between forecast and data visualisation.", 
                            placement = "bottom", trigger = "hover",
                            options = NULL)
                 
                 addTooltip(session = session, 
                            id = "median_forecast_1_q", 
                            title = "Change the median forecast.", 
                            placement = "bottom", trigger = "hover",
                            options = NULL)
                 addTooltip(session = session, 
                            id = "lower_90_forecast_1_q", 
                            title = "Change the lower bound of the 90% prediction interval.", 
                            placement = "bottom", trigger = "hover",
                            options = NULL)
                 addTooltip(session = session, 
                            id = "upper_90_forecast_1_q", 
                            title = "Change the upper bound of the 90% prediction interval.", 
                            placement = "bottom", trigger = "hover",
                            options = NULL)
                 addTooltip(session = session, 
                            id = "propagate_1_q", 
                            title = "Press to propagate changes forward to following weeks", 
                            placement = "bottom", trigger = "hover",
                            options = NULL)
                 addTooltip(session = session, 
                            id = "update_q", 
                            title = "Press for changes to take effect", 
                            placement = "bottom", trigger = "hover",
                            options = NULL)
                 addTooltip(session = session, 
                            id = "submit_q", 
                            title = "You can submit multiple times, but only the last submission will be counted.", 
                            placement = "bottom", trigger = "hover",
                            options = NULL)
                 
                 addTooltip(session = session, 
                            id = "baseline_model", 
                            title = "Select a baseline model. This will reset all your forecasts.", 
                            placement = "bottom", trigger = "hover",
                            options = NULL)
                 
               } else {
                 removeTooltip(session = session, id = "tooltip")
                 removeTooltip(session = session, id = "selection")
                 removeTooltip(session = session, id = "num_past_obs")
                 removeTooltip(session = session, id = "plotscale")
                 removeTooltip(session = session, id = "reset")
                 removeTooltip(session = session, id = "plotpanel1")
                 removeTooltip(session = session, id = "distribution")
                 removeTooltip(session = session, id = "median_forecast_1")
                 removeTooltip(session = session, id = "width_1")
                 removeTooltip(session = session, id = "propagate_1")
                 removeTooltip(session = session, id = "update_1")
                 removeTooltip(session = session, id = "submit")
                 removeTooltip(session = session, id = "baseline_model")
               }
             })



