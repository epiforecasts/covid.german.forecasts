#!/bin/bash

#define date
ForecastDate=$(date +'%Y-%m-%d')

# Clone the hub repository if not already present
#git clone --depth 1 https://github.com/KITmetricslab/covid19-forecast-hub-de

# install GitHub CLI
# https://cli.github.com/

# Authenticate with GitHub
# gh auth login

# Update the hub repository
cd ../covid19-forecast-hub-de
git checkout master 
git pull 
# Switch to submission branch
git checkout -b submission3
git merge -Xtheirs master

# Move back into forecast repository
cd ../covid.german.forecasts

# Copy your forecast from local folder to submission folder
cp -R -f "./submissions/rt-forecasts/$ForecastDate/." \
      "../covid19-forecast-hub-de/data-processed/epiforecasts-EpiNow2/"
cp -R -f "./submissions/deaths-from-cases/$ForecastDate/." \
      "../covid19-forecast-hub-de/data-processed/epiforecasts-EpiNow2_secondary/"
cp -R -f "./submissions/crowd-rt-forecasts/$ForecastDate/." \
      "../covid19-forecast-hub-de/data-processed/epiforecasts-EpiExpert_Rt/"
cp -R -f "./submissions/crowd-forecasts/$ForecastDate/." \
      "../covid19-forecast-hub-de/data-processed/epiforecasts-EpiExpert/"

# Commit submission to branch
cd ../covid19-forecast-hub-de
git add --all
git commit -m "submission"

# Create PR
gh pr create --title "$ForecastDate - EpiForecast submission" --body "This is an automated submission."

# Remove local submission branch 
git checkout master
git branch -d submission3
cd ../covid.german.forecasts
