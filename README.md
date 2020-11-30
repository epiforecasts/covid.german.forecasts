# Comparing Crowd Sourced and Model Derived Forecasts of Covid-19 for Germany and Poland

*Nikos Bosse\*, Sam Abbott\*, EpiForecasts, and Sebastian Funk*

*\* contributed equally*

## Introduction 

Forecasting approaches for infectious disease are generally a combination of a statistical or mechanistic modelling framework and expert opinion. The expert opinion  is usually that of the modeller responsible for developing the approach, provided via their choices in model tuning and selection. Here, we aim to disentangle the contributions of these factors by comparing a forecast estimated using a minimally tuned sem-mechanistic approach, `EpiNow2`, an ensemble of crowd sourced opinion (both expert and non-expert) `EpiExpert`, and a combined ensemble of both approaches. These forecasts are submitted each week to the [German/Poland forecasting Covid-19 hub](https://kitmetricslab.github.io/forecasthub/forecast) where they are combined with other models to inform policy makers and independently evaluated in the context of other modelling teams submissions.

This project is under development with forecasts being submitted each week and evaluation under development.

## Methods

### Data 

Data on test positive Covid-19 cases and deaths linked to Covid-19 were downloaded from the [ECDC](https://www.ecdc.europa.eu/en/covid-19/data) data repository each Monday during the forecast submission period (12th of October to ). 

### Models

[`EpiNow2`](https://epiforecasts.io/EpiNow2/) is an exponential growth model that uses a time-varying Rt trajectory to predict latent infections, and then convolves these infections using known delays to observations, via a negative binomial model coupled with a day of the week effect. It makes limited assumptions and is not tuned to the specifities of Covid in Germany and Poland beyond epidemioligical details such as literature estimates of the generation time, incubation period and the populatin of each area. The method and underlying theory are under active development with more details available [here](https://epiforecasts.io/covid/methods).

[`EpiExpert`](https://cmmid-lshtm.shinyapps.io/crowd-forecast/) is an ensemble of crowd opinion, both expert and non-expert.

### [Evaluation](https://github.com/epiforecasts/GM-PL-forecast-evaluation)

Forecasts will be scored using proper scoring rules from [`scoringutils`](https://github.com/epiforecasts/scoringutils) and ensembled using [`quantgen`](https://github.com/ryantibs/quantgen) with the resulting ensembles also evaluated using using the same evaluation metrics. 


