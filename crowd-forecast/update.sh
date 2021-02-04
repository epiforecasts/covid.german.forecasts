#!bin/bash

# create crowd forecast app submission data
Rscript crowd-forecast/update-submissions.R

# Redeploy forecast app (to update submission date to next week)
Rscript crowd-forecast/redeploy.R