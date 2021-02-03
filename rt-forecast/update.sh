#!bin/bash

# Update the input data
Rscript data-raw/update.R

# Update cases forecast
Rscript rt-forecast/case.R

# Update deaths forecast
Rscript rt-forecast/death.R

## Update deaths from cases forecast
Rscript rt-forecast/death-from-cases.R

# Update submissions
Rscript rt-forecast/submission.R
