# Comparing human and model-based forecasts of COVID-19 in Germany and Poland

This repository was used to create submissions from the epiforecasts team at the London School of Hygiene & Tropical Medicine to the [German and Polish Forecast Hub](https://kitmetricslab.github.io/forecasthub/forecast). It also holds the data and analysis scripts used for the paper "Comparing human and model-based forecasts of COVID-19 in Germany and Poland". 

This project is under development with forecasts being submitted each week and evaluation under development.

## Abstract

Model-based forecasts, which have played an important role in shaping public policy throughout the COVID-19 pandemic, represent an implicit combination of model assumptions and the researcher’s subjective opinion. This work analyses and compares human opinion against model-derived insights to discern relative strengths and weaknesses of both approaches. We compared purely opinion-derived forecasts of cases and deaths from COVID-19 in Germany and Poland, elicited from researchers and volunteers, against predictions from two semi-mechanistic epidemiological models. We also compared these forecasts against an ensemble of model-based, but expert-tuned, forecasts, submitted to the German and Polish Forecast Hub by other research institutions. In addition, we examined the effects of our contributions to the performance of the Hub ensemble. We found aggregated crowd forecasts to outperform all other methods when predicting cases (Weighted Interval Score relative to the Hub ensemble: 0.89), but not when predicting deaths (rel. WIS 1.26). Crowd forecasts were noticeably more overconfident (55% and 75% coverage of the 90% prediction intervals for cases and deaths, respectively) than model-based predictions. Performance of the semi-mechanistic models was good short-term, but deteriorated quickly over time when assumptions were no longer met. 


## Relevant files

- full manuscript: `manuscript/manuscript.pdf`
- analysis script to generate figures for the manuscript: `analysis/analysis.Rmd`

All data used for the paper are included as data objects in the `covid.german.forecasts` R package. 
- The data for the paper were loaded and compiled using the script `data-raw/paper.R`
- package data are stored in `data/`
- you can list all package data by running `data(package = "covid.german.forecasts")` and load individual data files by running e.g. `covid.german.forecasts::



