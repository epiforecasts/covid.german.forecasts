# Forecasts for Germany and Poland

## Aim

## Folder structure

Every model has its own folder. There is a shared folder for data, submissions, update-scripts and utility functions. Need to add a folder for evaluation. 

## Models

### Human forecast app

This app is designed to elicit forecasts in order to submit them to the [German Forecast Hub](https://github.com/KITmetricslab/covid19-forecast-hub-de/).

### Regression model

### Rt based forecasts

Runs an Rt based forecast model using [`{EpiNow2}`](https://epiforecasts.io/EpiNow2/). To update the forecast: 

```bash
bash rt-forecast/update.sh
```

Runtime on a 4 core computer should be approximately 30 minutes but may take up to 2 hours for edge cases.

## Updating models

