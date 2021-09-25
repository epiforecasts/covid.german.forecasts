#!bin/bash

Rscript rt-forecast-retrospective/past-renewal-forecasts.R
Rscript rt-forecast-retrospective/past-convolution-forecasts.R
Rscript rt-forecast-retrospective/past-submissions.R

cd submissions
cd rt-forecasts-retrospective
find . -name '*.csv' -exec cp {} ../../data-raw/epiforecasts-EpiNow2-retrospective/ \;
cd ..

cd deaths-from-cases-retrospective
find . -name '*.csv' -exec cp {} ../../data-raw/epiforecasts-EpiNow2_secondary-retrospective/ \;
cd ../..

  
  