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