#!bin/bash

# Update the input data
Rscript update-scripts/update-data-script.R

# Update cases forecast
Rscript rt-forecast/update-case.R

# Update deaths forecast
Rscript rt-forecast/update-death.R

## Update deaths from cases forecast
Rscript rt-forecast/update-death-from-cases.R

# Update submissions
Rscript rt-forecast/update-submission.R
