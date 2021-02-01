# Comparing Crowd Sourced and Model Derived Forecasts of Covid-19 for Germany and Poland

*Nikos Bosse\*, Sam Abbott\*, EpiForecasts, and Sebastian Funk*

*\* contributed equally*

## Introduction 

Forecasting approaches for infectious disease are generally a combination of a statistical or mechanistic modelling framework and expert opinion. The expert opinion  is usually that of the modeller responsible for developing the approach, provided via their choices in model tuning and selection. Here, we aim to disentangle the contributions of these factors by comparing a forecast estimated using a minimally tuned semi-mechanistic approach, `EpiNow2`, an ensemble of crowd sourced opinion (both expert and non-expert) `EpiExpert`, and a combined ensemble of both approaches. These forecasts are submitted each week to the [German/Poland forecasting Covid-19 hub](https://kitmetricslab.github.io/forecasthub/forecast) where they are combined with other models to inform policy makers and independently evaluated in the context of other modelling teams submissions.

This project is under development with forecasts being submitted each week and evaluation under development.

## Methods

### Data 

Data on test positive Covid-19 cases and deaths linked to Covid-19 were downloaded from the [ECDC](https://www.ecdc.europa.eu/en/covid-19/data) data repository each Monday during the forecast submission period (12th of October to 19th December). This submission period coincides with the first half of the Forecast Hub submission period pre-registered [here](https://osf.io/zkdvb/). The data is subject to reporting artifacts (such as a retrospective case reporting in Poland on the 24th November), and changes in reporting and testing regimes. 
 
### Models

[`EpiNow2`](https://epiforecasts.io/EpiNow2/) is an exponential growth model that uses a time-varying Rt trajectory to predict latent infections, and then convolves these infections with estimated delays to observations, via a negative binomial model coupled with a day of the week effect. It makes limited assumptions and is not tuned to the specifities of Covid in Germany and Poland beyond epidemioligical details such as literature estimates of the generation time, incubation period and the populatin of each area. The method and underlying theory are under active development with more details available [here](https://epiforecasts.io/covid/methods).

[`EpiExpert`](https://cmmid-lshtm.shinyapps.io/crowd-forecast/) is an ensemble of crowd opinion. Participants were asked to make forecasts using a shiny application (https://cmmid-lshtm.shinyapps.io/crowd-forecast/). In the application they could select a predictive distribution (the default was log-normal) and adjust the median and the width of the uncertainty. Predictions were elicited for Covid-19 case and death numbers in Germany and Poland for a horizon of one to four weeks ahead. Predictions could be made at any time, but participants were encouraged to submit between Saturday (when weekly data was updated) and Tuesday noon (when forecasts were due for submission). The baseline model shown to participants was a model thatnrepeated the last known observation and added some constant uncertainty based on changes observed in the data in the previous four weeks. Users were able to predict on a logarithmic or linear scale and could use the application to access some information like the test positivity rate, case fatality rate and the number of tests performed in each country. 

### Submission format

Forecasts were submitted every Tuesday (using data up until Monday) for a one to four week ahead horizon. Forecasts were in a quantile-based formats with 22 quantiles plus the median prediction. 

### Model aggregation

Forecasts were ensembled, among others, using [`quantgen`](https://github.com/ryantibs/quantgen). 

### [Evaluation](https://github.com/epiforecasts/GM-PL-forecast-evaluation)

Individual forecasts as well as ensembles were scored using [`scoringutils`](https://github.com/epiforecasts/scoringutils). To assess forecast performance we used the weighted interval score, a proper scoring rule suitable for quantile forecasts, as well as measures to assess calibration independently. We particularly looked at forecast bias and empirical coverage of predictive quantiles and prediction intervals. 

To compare models fairly we used a pairwise-comparison approach.

## Results

Planned results themes: 
- When does expert opinion perform well, when does EpiNow2 do well? (look at different phases (decrease, increase, change point))
- How do both models compare to forecast hub ensembles that exclude EpiExpert and EpiNow2. This allows to explore the impact of mixing expert opinion and the use of a model as it is assumed that other forecasters tuned there model through the study period as a result of performance evaluations, data changes etc.
- Is there any benefit to ensembling expert opinion with simple models vs expert opinion alone. 

## Discussion

- Summary
- Strengths and weaknesses
- In literature context
- Further work
- Conclusions
