#!bin/bash

# Update cases forecast
Rscript rt-forecast/update-case.R

# Update deaths forecast
Rscript rt-forecast/update-death.R

# Update submissions
Rscript rt-forecast/update-submission.R
