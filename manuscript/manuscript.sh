!#/bin/bash

Rscript -e 'trackdown::update_file(file = "manuscript/manuscript.Rmd", gfile = "Comparing human and model-based forecasts of COVID-19 in Germany and Poland", hide_code = TRUE)'


trackdown::download_file(file = "manuscript/manuscript.Rmd", gfile = "Comparing human and model-based forecasts of COVID-19 in Germany and Poland")
