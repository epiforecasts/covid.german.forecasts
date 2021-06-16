---
title: Evaluating crowd sourced forecasts of Covid-19https://hackmd.io/tZ1I_ls6T2eF5ydV-w5Vmg?editagainst epidemiological model forecasts in Germany and Poland
output: pdf_document
bibliography: 
  - references.bib  
  - GermanPolishpaper.bib

---

# Evaluating crowd sourced forecasts of COVID-19 against epidemiological model forecasts in Germany and Poland

*Nikos Bosse, Sam Abbott, Anonymous Alpaca, and Sebastian Funk*

Target journal: elife

## Abstract


#### Background

>[name=Sam Abbott] Another sentence linking to the German forecasting hub + mention routinely submitted. X

Model based forecasts have played an important role in shaping public policy throughout the Covid-19 pandemic. Models, in turn, are usually adjusted by human judgement. Any model forecast is therefore a combination of the researcher's subjective opinion and model assumptions. To compare and combine different predictions and approaches, the German and Polish Forecast Hub in October 2020 started to elicit weekly forecasts from various research insitutions for case and death notifications of Covid-19 in Germany and Poland. 

#### Methods

To examine the added benefit from either human insight or model-based in model-based predictions, we evaluate three models we submitted to the German and Polish Forecast Hub between October 12 2020 and March 01 2021. One is a crowd sourced forecast that represents human judgement without any explicit theory-derived assumptions. The other two represent the simplest possible epidemiological baseline models and were left completely untuned. One of these model estimates the reproduction number $R_t$ and predicts future cases and deaths based on the assumption that $R_t$ will stay constant in the future, while the other model (submitted only for death forecasts), models deaths as a scaled convolution of past cases with a delay distribution. In addition, we compare these three models to the median ensemble of all other predictions submitted to the German and Polish Forecast Hub. Forecasts are evaluated using the weighted interval score (a proper scoring rule) and the empirical coverage of 50% and 90% prediction intervals. We look at predictions stratified by location and target as well as forecasts made in different phases of the epidemic. To assess the contribution our models made to the overall hub ensemble we compare the hub-ensemble with our models included against a retrospectively refit version of the hub ensemble without our models. 

>[name=Sam Abbott] Detail of evaluation approach (i.e proper scoring rules, data stratification etc). More detail on what the models are is needed here (convolution randomly appears in the results at the moment with no support). Missing leave on out from the ensemble. X


#### Results

> [name=Sam Abbott] Any statement should be supported with quantification (i.e performed worse on average is a conclusion not a result).  
> This sections would benefit from being a little more nuanced and detailed + less leaning on the average. Pull out more on models vs crowd for example. There lots of results you are not mentioning. The conclusions are for crafting your policy angle etc. 

Human forecasts outperformed the model forecasts as well as the Forecast Hub ensemble on case predictions over all time horizons considered (20%, 12%, 19%, and 30% relative improvement over the ensemble of Forecast Hub submissions excluding our contributions for 1 to 4 week forecast horizons). For death forecasts, crowd predictions performed less well (7%, 26%, 29%, and 17% difference to the Forecast Hub ensemble excluding our contributions). The model forecasts we submitted performed on average worse than other models for most targets, but the convolution model of cases was able to forecast deaths relatively well. Our contributions noticeably improved the German and Polish Forecast Hub ensemble on cases (20%, 10%, 7%, and 9% improvement through our contributions on one to four week ahead case forecasts) and had a neutral or even slightly negative impact on death forecasts (6%, -2%, -4%, and -5% change in performance due to our models).

#### Conclusions

> [name=Sam Abbott] Move some of the results interpretation here. Conclusions should build on the results. At the moment this is very we submitted to the hub and we added some value. There is a lot more to this paper than that - that is a side benefit tbh. 

Expert opinion can provide valuable insight and possibly outperforms models at forecasting future case numbers, as humans can make use of information, e.g. about potential future policy interventions, not directly available to models. Models, however, have an advantage when forecasting lagged quantities such as deaths, which are generally better predictable using mechanistic epidemiological relations like the delay between current case numbers and future deaths. Individual models can make positive contributions to an ensemble even if they individually perform worse than the pre-existing ensemble without them. 


## Introduction

> [name=Sam Abbott] Cite ECDC hub X

The COVID-19 pandemic has resulted in an increase of interest in infectious disease forecasting, and the evaluation of these forecasts. Single model forecasts [@fergusonReportImpactNonpharmaceutical2020; @IHMEpaper] were impactful on policy decisions early in the pandemic despite previous work having shown that relying on a single model can lead to less accurate forecasts than decisions based on multiple approaches [@yamanaSuperensembleForecastsDengue2016; @gneitingWeatherForecastingEnsemble2005]. Since then several collaborations have sought to improve Covid-19 forecasting by eliciting submissions from a large number of research teams and collecting them in forecast hubs in the United Kingdom [@funkShorttermForecastsInform2020], in the United States of America [@esteecramerCOVID19ForecastHub2020; @cramerEvaluationIndividualEnsemble2021], in Germany and Poland [@bracherShorttermForecastingCOVID192021], and in Europe [@EuroHub]. Whilst all of these efforts have successfully delivered more accurate forecasts to policy makers compared to individual forecasting efforts they have struggled to unpick what leads to good Covid-19 forecasts [@cramerEvaluationIndividualEnsemble2021; @bracherShorttermForecastingCOVID192021; @funkShorttermForecastsInform2020]. 

This has been partly driven by the complexity of the models used to produce the constituent forecasts but also because of the level of expert intervention in most forecasting methods over time, and in response to changes in the pandemic and in the available data. These issues can be decoupled by separating infectious disease forecasting into model derived forecasts, that are unadjusted during the forecast period, and human elicitation forecasts (from now on referred to as crowd forecasts). Model based forecasts have a rich history and have been growing in popularity over the last decade [@mcgowanCollaborativeEffortsForecast2019; @johanssonOpenChallengeAdvance2019; @viboudRAPIDDEbolaForecasting2018; @funkAssessingPerformanceRealtime2019]. However, such model based forecasts that are submitted by researchers usually change over time in response to percieved performance, changes in the underlying infectious disease processes or for other reasons. It is therefore unsusual for real-time forecasts (as opposed to retrospective forecasts) to be evaluated alongside these. A variety of human expert elicitation as well as crowd forecasting projects exist [@mcandrewAggregatingPredictionsExperts2021; @metaculusPreliminaryLookMetaculus2020; @tetlockForecastingTournamentsTools2014; @atanasovDistillingWisdomCrowds2016]. However, these crowd forecasts usually follow a different format than the ones provided by traditional forecasting models or take on different questions. Unlike other projects the crowd forecasts we develop here have been specifically designed to be comparable to model based forecasts. 

In this work, we evaluate two contrasting forecasting approaches that simplify and synthesise some of the previous work on evaluating model based forecasts as well as crowd forecasts. The first approach we analyse is a crowd forecast, where expert and non-expert predictions are combined into a single forecast of cases and deaths in target locations. This can be seen to represent modellers' interventions in forecasts but in a model agnostic format. In the second approach, we use two recently developed short term forecasting methods that make minimal epidemiological assumptions of how notifications are generated over time coupled with a robust observation model. These models were then not adjusted throughout the submission period in order to make a comparison to opinion derived forecasts possible. All of these forecasts were submitted to the German and Polish Forecast Hub over 21 weeks from the 12th October 2020 to March 1st 2021 and combined, along with other forecasts, into an ensemble used by policy makers as well as being independently evaluated by the research group running the German and Polish Forecast Hub.

## Methods

### Data sources

Data on test positive cases and deaths linked to Covid-19 were provided by the organisers of the German and Polish forecast hub [@bracherShorttermForecastingCOVID192021]. Until December 14th 2020 these data were sourced from the European Centre for Disease Control (ECDC) [@DownloadHistoricalData2020a]. After ECDC stopped publishing daily data, observations were sourced from the Robert Koch Institute (RKI) for the remainder of the submission period [@RKICoronavirusSARSCoV2a]. These data are subject to reporting artefacts (such as a retrospective case reporting in Poland on the 24th November [@RozbieznosciStatystykachKoronawirusa0100]), changes in reporting over time and variation in testing regimes (e.g. in Germany from the 11th of November on [@aerzteblattSARSCoV2DiagnostikRKIPasst2020]). 

Line list data used to inform the delay from symptom onset to test postive case report or death in the model based forecasts was sourced from (cite public linelist) with data available up to June (check exact date). Population data at the national and state level in Germany and Poland used in the model based forecasts was sourced from [@statistischesbundesamtBevoelkerungNachNationalitaet2020] and [@glownyurzadstatystycznyLudnoscStanStruktura2020]. 
 
> [name=Sam Abbott] Citations missing.

### Forecasts

#### Model based forecasts

We used two models from the `EpiNow2` R package (version 1.3.3) as our baseline model based forecasts [@epinow2]. These were chosen for their relative simplicity, attention to modelling the observation model of the forecast targets, and their grounding in simplistic epidemiological assumptions. The first of these models, which was used to forecast both test positive cases and deaths, used the renewal equation [@coriNewFrameworkSoftware2013a] and an approximate Gaussian process [@approxGP] to estimate the effective reproduction number over time for latent infections and then convolved these infections to the target observation using data based delay distributions [@epinow2; @doiCovid19TemporalVariation; @EvaluatingUseReproduction]. The second model, which was only used to forecast deaths, assumed that deaths could be modelled using a scaling parameter, a convolution of test positive cases with a distribution that described the delay from case report to death, and a negative binomial observation model with a day of the week effect [@epinow2]. Both models are described in detail in the supplementary information. 

Each forecast target was fit independently for each model using Markov-chain Monte Carlo (MCMC) in stan [@rstan]. A minimum of 4 chains were used with a warmup of 250 samples for the renewal equation based model and 1000 samples for the convolution model. 2000 samples total post warmup were used for the renewal equation model and 4000 samples for the convolution model. Different settings were chosen for each model to optimise compute time contigent on convergence. Convergence was assessed using the R hat diagnostic [@rstan]. For the convolution model forecast the case forecast from the renewal equation model was used in place of observed cases beyond the forecast horizon using 1000 posterior samples. 

> [name= Sam Abbott] It is a little odd having so little detail on the models and so much fitting info. 
> [name=Nikos] Can you add something to this please? 

#### Crowd forecast

Crowd forecasts were created by ensembling forecasts submitted by individual participants. To that end, we calculated 22 quantiles plus the median from every forecaster's predictive distribution for a given target and combined predictions by taking the quantile-wise mean. 

Participants were recruited mostly within the Centre of Mathematical Modeling of Infectious Diseases at the London School of Hygiene and Tropical Medicine, but participants were also invited personally or via social media to submit predictions. 

> [name=Sam Abbott] Expand on ensembling method.
> [name=Nikos] Also adding another point to the discussion on why we chose the mean is probably a good idea

##### Collection

Participants were asked to make forecasts of Covid-19 cases and deaths over a four week ahead horizon using a web application (https://cmmid-lshtm.shinyapps.io/crowd-forecast/). The application was built using the `shiny` and `golem` R packages [@shiny; @golem] and is available in the `crowdforecastr` R package [@crowdforecastr]. To make a forecast in the application participants could select a predictive distribution, with the default being log-normal, and adjust the median and the width of the uncertainty by either interacting with a figure showing their forecast or providing numerical values. The baseline shown was a repetition of the last known observation with constant uncertainty around it computed as the standard deviation of the last four observed log changes in forecasts. We required that participants submitted forecasts with uncertainty that increased over time. Our interface also allowed participants to view the observed data, and their forecasts, using a log scale and presented additional contextual COVID-19 data sourced from ourworldindata.org [@COVID19DataExplorer]. These data included notifications of both test positive COVID-19 cases and COVID-19 linked deaths, case fatality rates and the number of COVID-19 tests though the availability of the data evolved over the study period. 


##### Processing

Forecasts were stored in a Google Sheet and downloaded, cleaned and processed every week for submission. If a forecaster had submitted multiple predictions for a single target, only the latest submission was kept. Some personal information (like the exact time of the forecast) was removed. Information on the chosen distribution as well as the parameters for median and width were used to obtain a set of 22 quantiles plus the median from that distribution. Forecasts from all forecasters were then aggregated using an unweighted quantile-wise mean. Inclusion was decided based on the authors' ad-hoc assessment of the validity of the forecast submission. Almost all forecasts were kept if they weren't clearly a result of a user experimenting with the app. 


### Forecast submission

Both model based forecasts and crowd preditions were submitted every Tuesday 3pm. The model based forecasts used data up to the previous Sunday. Human forecasters were allowed to make forecasts until Tuesday 12am, but were asked to use only information up to Monday. All forecasts were submitted in a quantile-based format with 22 quantiles plus the median prediction for a one to four week ahead horizon. 

All forecasts were processed in a Docker [@merkel2014docker] container that ran automated cron jobs to ensure a reproducible environment. All code and tools necessary to generate the forecasts and make a forecast submission are available in the covid.german.forecasts R [@R] package. 

All forecasts are available here: https://github.com/epiforecasts/covid.german.forecasts

> [name=Sam Abbott] cite  docker, and R X

### Forecast Hub ensemble

> [name=Nikos] maybe move this section to data sources?

Our forecasts were compared against the ensemble of all other models submitted to the German and Polish Forecast Hub. For the purpose of this analysis and unless otherwise specified, 'ensemble' means the median ensemble of all predictions submitted to the forecast hub, excluding our models. The median ensemble was chosen as it is the default ensemble shown in the visualisations of the German and Polish Forecast Hub. The version of the ensemble that excluded our models was created retrospectively and kindly provided by the German and Polish Forecast Hub organisers. 

### Statistical analysis

Forecasts were analysed by visual inspection as well using the following scoring metrics: The weighted interval score (WIS) [@bracherEvaluatingEpidemicForecasts2021], absolute error, a separate bias metric, and empirical coverage of the 50% and 90% prediction intervals. The WIS is a proper scoring rule used to evaluate forecasts in a quantile format. For a growing set of equally spaced quantiles it converges the continuous ranked probability score (CRPS) [@Gneiting2007] that can be understood as a generalisation of the absolute error to probabilistic forecasts. The WIS can be decomposed into three separate penalties for (lack of) sharpness, overprediction and underprediction. To capture not only the absolute amount of overprediction and underprediction, we also employ a bias metric that is bound between -1 (complete underprediction, all quantiles of the predictive distribution are below the observed value) and 1 (complete overprediction, all quantiles of the predictive distribution are above the observed value) that represents a general tendency to over- or underpredict. <!--In addition to the WIS, we also calculated WIS relative to the baseline by dividing through the WIS achieved by the baseline model.--> If not otherwise specified, scores were computed per forecast date, target and country and aggregated using the mean. All scores were calculated using the `scoringutils` package [@scoringutils] in R. For case forecasts, all forecasts from October 12th 2020 until March 1st 2021 were taken into account. For deaths, we only scored forecasts made after the 14th December, as the convolution model was not available prior to this. 

For the main analysis we focused on one and two week ahead predictions, as predictions beyond this horizon are often unreliable due to rapidly changing condition, such as policy interventions which are not necessarily in scope for short term forecasts [@bracherShorttermForecastingCOVID192021]. Forecast scores for other horizons are given in the supplement. As an additional analysis, we stratified the time series into three different categories for every forecast date depending on whether numbers were monotonically rising or falling over the last two weeks prior to a given forecast date. The epidemic was categorised as either 'increasing', 'decreasing' or 'unclear' using this categorisation. Differences of less than 5% relative to the week before were treated as zero, meaning they were interpreted as consistent with either classification. 

To assess the impact of our contributions on the hub-ensemble, we performed a 'leave-one-out'-analysis, evaluating versions of the hub ensemble that include none of our models, only one of them, or all of our models. We also consider the 'official' hub ensemble, which is the version that includes the renewal model as well as the crowd forecast, as the convolution model never entered the hub ensemble due to concerns about the number of models submitted from a single team. 

> [name=Sam Abbott] Missing leave on out from the ensemble X
> [name=Nikos] Maybe need a citation (not sure what to cite. scoringutils?) or an even more detailed explanation of the bias metric?

## Results

### Forecast submission

From October 12 2020 until the December 7 2020, only the renewal model and the crowd forecasts were submitted. Starting with the 7th of December, the convolution model was also included. As the first submission suffered from a software bug, we excluded it from this analysis. March 1st was chosen as the last submission date, as we switched to submittign forecasts for Germany and Poland to the European Forecast Hub on the 8th of March. From January 11th 2021 on we also submitted model based forecasts on a regional level. These forecasts were not further analysed as we could not produce corresponding crowd forecasts due to the large number of locations, limited researcher time, and ability to reach out to enough potential forecasters. Model based forecasts used the same approach throughout the forecast period with no changes to the methodology or setting. Interventions that applied at different points throughout the study period were therefore not explicitly modelled either prospectively or retrospectively. Human forecasters were of course able to adapt their forecasts to current or likely future interventions. 

A total number of 31 participants submitted forecasts. The median number of forecasters was 6, the minimum 2 and the maximum 9 for a single forecast target. Participation rose steadily and peaked in February, before declining again towards the end of the study period. The mean number of submissions from an individual forecaster was 4.7, but the median number was only one - most participants dropped out after their first submission. Only two participants submitted a forecast every single week. To increase usability, the interfaces visual appearance was continuously tweaked and improved, and additional information, e.g. from ourworldindata.org was added. The core functionality, however, remained unchanged. 


### Performance overview
![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table_scores_2_ahead.png)\label{tab:scores-2}
![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table_scores_4_ahead.png)\label{tab:scores-4}

*Table 1: Scores for one and two week ahead forecasts (cut to three significant digits and rounded). WIS is the mean weighted interval score (lower values ar better), WIS - median and WIS - sd give the median and standard deviation of all scores achieved by a model. Sharpness, overprediction and underprediction together some up to the weighted interval score. Bias (between -1 and 1, 0 is ideal) represents the general average tendency of a model to over- or underpredict. 50% and 90%-coverage are the percentage of observed values that fell within the 50% and 90% prediction intervals of a model.*

We found that crowd forecast had a lower mean WIS than the untuned renewal model across all forecast targets, horizons and locations with a mean WIS for two week ahead predictions of XX vs. XX for cases and XX vs. XX for deaths (Figure S1, Table 1). The convolution model predicted deaths slightly better than the crowd forecast up to two weeks ahead (mean WIS of XX vs. XX), where deaths were largely informed by observed cases. It did poorly at greater forecast horizons, when death forecasts to a greater extent depended on predicted cases. The renewal model generally performed poorly at predicting deaths (mean WIS 524), indicating the benefit of including case data which was either implicitly or explicitly included in all other models. 

When considering the median WIS, relative performance changes slighty. The renewal model did comparably well on cases in terms of median WIS one and two weeks ahead and even outperformed all other models at a one week forecast horizon (median WIS 3550, Figure S1, Table1). It also performed best at one week ahead death forecasts (median WIS 128), but performance quickly deteriorated for both cases and deaths for greater forecast horizons. Judged by the median WIS, crowd forecasts also did relatively better on death forecasts (median WIS 164), performing en par or better than all other models. 

The crowd forecast also overall had a lower overall mean WIS as well as median WIS than the hub ensemble on cases (mean XX, median XX, Figure S1 and Table 1) across all horizons. For cases, crowd forecasts were also closest to the observed values in terms of their central tendency across all forecast horizons (absolute error of the median forecast 23300, Table 1 and Figure S1). On deaths, the hub ensemble outperformed all other models in terms of mean WIS (XX) and absolute error across all horizons, but not in terms of median WIS (XX), where crowd forecasts tended to be slightly better (and the renewal model at a one week horizon) (Figure S1, Table 1). 

SENTENCE FOR PERFORMANCE ACROSS LOCATIONS
- performance was similar
- scores higher in Germany

<!--
the renewal model on case predictions over all four time horizons (Figure S1), with a mean WIS of 7010, 16200, 27000 and 39200 for the crowd forecasts and 8740, 25600, 50600, 91700 for the renewal model (Tables 1 and S2). For both models, the median WIS (4540, 8330, 17200, 28200 for the crowd forecasts, 3550, 9020, 19700, 31500 for the renewal model) (Tables 1 and S2) was lower than the mean WIS implying skewed distributions where average performance is influenced by outliers (Figures 1 and 2A). 
-->

### Sharpness and calibration

- crowd generally sharpest
- 

Crowd forecasts generally tended to be the sharpest (sharpness of XX) and especialy for cases issued substantially narrower predictions than the renewal model (sharpness of XX), with uncertainty of the crowd forecasts increasing relatively slowly across horizons (Figure S1, Tables 1 and S2). The renewal model was comparably sharp for both cases and deaths at a one week horizon, but on average had rapidly increasing uncertainty across forecast horizons. The convolution model was about as sharp as the crowd forecast for one and two week ahead predictions of deaths, but had greater uncertainty for three and four weeks ahead predictions when it had to rely on projected instead of observed cases. 

On case forecasts, all models generally struggled with marginal calibration and mostly had lower empirical than nominal coverage of its 50% and 90% prediction intervals (Figure S1 and Table 1). This was especially true for the crowd forecasts. Due to its narrow forecast intervals especially for cases, it had the lowest empirical coverage of the 50% and 90% prediction intervals of all models for case forecasts more than one week into the future (36% and 55% two weeks ahead and only 5% and 38% 4 weeks ahead). Due to its rapidly increasing uncertainty, the renewal model showed a slightly better empirical coverage for cases (43% and 67% two weeks ahead and 31% and 48% 4 weeks ahead), even though the forecasts were farther away from the observed values (absolute errors of 12000, 34600, 68700, 125000).
On deaths, the renewal model had good 50% coverage (50%), but covered less than the nominal 90% of observed values with its 90% prediction intervals (XX%). The crowd and the convolution model had worse coverage of the 50% prediction intervals (XX% and XX%), but generally had comparable coverage for 90% prediction intervals across horizons (XX% and XX%). 


Crowd forecasts for cases, on average, were mostly unbiased with bias values of -0.01, -0.01, 0.02, and 0.07. The renewal model exhibited a general tendency to overpredict that slightly decreased with increasing forecast horizon with bias values of 0.18, 0.17, 0.13, and 0.09. Across all forecast horizons, all models incurred larger absolute penalties from over-prediction than from underprediction (Table 1 and SXX). This was the case regardless of a general tendency to either over- or underpredict (as captured by the bias metric), implying that overprediction, when it happened, was on average more costly (Table 1 and SXX). 


Forecasts from the ensemble were generally unbiased (bias values of -0.04, -0.03, -0.01, 0.01), even though again overprediction penalties were on average higher than underprediction penalties in absolute terms. The hub ensemble was less sharp than the crowd forecasts at all time horizons and also had faster growing uncertainty for increasing forecast horizons (sharpness of 3670, 6140, 9130, 12200 vs. 2680, 3660, 4750, 5970). It was also more uncertain than the renewal model at one and two week ahead predictions, but its uncertainty grew less quickly than that of the renewal model (sharpness values of 2190, 5420, 10800, 19500). 
The hub ensemble had better empirical coverage than the crowd forecasts and comparable or mostly even slightly better coverage than the renewal model. 

For death forecasts, there was no clear pattern that overpredictions were more costly in absolute terms than underprediction and instead the picture is varied. Crowd forecasts were upwards biased across all forecast horizons (bias values of 0.08, 0.14, 0.12 and 0.14) and also incurred higher penalties from overprediction (XX numbers). The renewal model was slightly downwards biased on average for most horizons (XX values), but incurred higher penalties from overprediction than from underprediction. The convolution model was on average strongly downwards biased for one and two week ahead predictions (-0.18 and -0.1), but had decreasing bias over time (-0.04 and 0.01 at three and four weeks ahead). 



At death forcasts, the hub ensemble outperformed all other models at all forecast horizons, with mean WIS values of XX. For all but one week ahead forecasts it was also most consistent , having the lowest standard deviation of the WIS (XX values). Ensemble forecasts were relatively unbiased (values of -0.04, 0.01, -0.03 and -0.06). Its empirical coverage was better than that of all other models, having almost perfect coverage at all forecast horizons (e.g. 62% and 96% at a two week ahead and 58% and 92% at a four week ahead horizon). Its predictions were less confident (i.e. less sharp) than the crowd forecasts, and also less confident than those of the convolution model at one to three weeks ahead, but sharper than the renewal model predictions for all but one week ahead forecasts. 



- Overview of performance at the target horizon
     - Mean/Median/SD of scaled WIS by model, target, and location
- Detail on each score
     - Short summary on interesting differences by model, target, and location
- Distribution
- Pandemic phase
- By horizon (differences to other sections that are interesting)
- Hub ensemble contribution
     - Overall
     - By model (edited) 


### Performance by horizon

- for cases, coverage decreased rapidly across horizons


### Case forecasts

<!--
> [name= Sam Abbott] You are not consistent with how you talk about forecasts despite defining definitions for each in the intro. Suggest a careful read to correct this. 
> [name=Nikos] You mean the naming of models? 
> [name=Sam Abbott] There should be links to figs and tbales in this text (i.e figure 1 and table 1).
> [nameSam Abbott] Suggest yet more use of numbers and linking to tables + figures. The flow is make a point, mention some data that shows it and link to the source where more data is. The tables and figs should be part of the flow. 
> [name=Sam Abbott] I would suggest recasting this in the form (maybe not now). Crowd forecast performance vs model for each thing and then crowd forecast vs ensemble and ensemble vs model (+ baseline). That way you get to keep the thrust of the paper clear. With that in mind I would generally edit this to get rid of detail that isn't reallyon target for the paper (the bias in the baseline model for example seems not very important to flag).
> [name=Sam Abbott] report order of calibration. X
> [name=Sam Abbott] Link to tables and figures in the supplement at other forecast horizons. 
> [name=Sam Abbott] I would also suggest pulling in the score over time plots from the SI here and using them in the discussion. 
> [name=Sam Abbott] Pull out by target differences in SI and report here. 

> [name=Sam Abbott] Just a general note we are looking for a summary initially of interesting performancce behaviour difference that we can then dive into further. We also want everything focussed on the interplay between opinion and model structure (so concluding likely that both have a place and that forecasts when evaluated for consistency and in the prescence of a rapidly changing NPI landscape do better when they have both).
-->


### Distribution




#### Comparison of crowd forecasts and renewal model 

Crowd forecasts on average outperformed the renewal model on case predictions over all four time horizons (Figure S1), with a mean WIS of 7010, 16200, 27000 and 39200 for the crowd forecasts and 8740, 25600, 50600, 91700 for the renewal model (Tables 1 and S2). For both models, the median WIS (4540, 8330, 17200, 28200 for the crowd forecasts, 3550, 9020, 19700, 31500 for the renewal model) (Tables 1 and S2) was lower than the mean WIS implying skewed distributions where average performance is influenced by outliers (Figures 1 and 2A). 
This was especially prononuced for the renewal model, which had more outliers (Figure A), as well as a more varied performance in general, with a higher standard deviation of the WIS across all horizons (11800, 33800, 70000, and 135000) than the crowd forecasts (7480, 16600, 26200, and 38600 for the crowd forecasts) (Tables 1 and Figure S1). 
<!-- Outliers for the renewal model were more frequent in Germany, where the trend of the epidemic changed more often (Figure 1). Notable outliers were the forecasts made on November 2 2020 (target date of November 14 2020 in Figure 1) and several forecasts made in late December 2020 and early January 2021 (target dates in January 2021 in Figure 1). In November, the renewal model continued the trend in rising cases that was observed in October (Figure S3) and severely overpredicted, before adapting to the changing trend. On January 11 2021 it interpreted a new rise in cases as signal, rather than noise and predicted a new rise in cases.  
-->
Judged by median performance, the renewal model even outperformed the crowd forecasts (and all other models) at a one week ahead horizon (median WIS of 3550 vs. 4540). 
For greater forecast horizons, average as well as median performance of the renewal model quickly detoriated compared to other models (Table SXX, Figure 3XX). <!-- any statement about how the assumption breaks down would be discussion? --> 

Crowd forecasts were on average closest to the observed values, with an absolute error of the median forecast of 10400, 23300, 39000, 54800. However, they were also mostly the narrowest (with sharpness values of 2680, 3660, 4750, 5970), and therefore struggled with marginal calibration, having the lowest empirical coverage of its 50% and 90% prediction intervals of all models for forecasts more than one week into the future (36% and 55% two weeks ahead and only 5% and 38% 4 weeks ahead). The renewal model had an uncertainty that quickly increased with increasing forecast horizon (sharpness values of 2190, 5420, 10800, 19500), and therefore had better empirical coverage (43% and 67% two weeks ahead and 31% and 48% 4 weeks ahead), even though the forecasts were farther away from the observed values (absolute errors of 12000, 34600, 68700, 125000). 

Crowd forecasts for cases, on average, were mostly unbiased with bias values of -0.01, -0.01, 0.02, and 0.07. The renewal model exhibited a general tendency to overpredict that slightly decreased with increasing forecast horizon with bias values of 0.18, 0.17, 0.13, and 0.09. Across all forecast horizons, all models incurred larger absolute penalties from over-prediction than from underprediction (Table 1 and SXX). This was the case regardless of a general tendency to either over- or underpredict (as captured by the bias metric), implying that overprediction, when it happened, was on average more costly (Table 1 and SXX). 

MISSING: INTERPRETATION ABOUT MODELS IN DIFFERENT PHASES

#### Comparison of our models against the hub ensemble forecasts

Crowd forecasts on average outperformed the Forecast Hub ensemble (excluding our own models) on case predictions over all time horizons (WIS of 7010, 16200, 27000, 39200 vs. 8740, 18300, 50600, 55900), and outperformed it in terms of median WIS at all time horizons except for four week ahead predictions (WIS of 4540, 8330, 17200, 28200 vs. 5240, 9940, 17800, 26400). The renewal model performed en par with the hub ensemble at a one week ahead forecast horizon (WIS of 8740 vs. 8770), but on average performed worse than the ensemble for other time horizons. In terms of median performance it outperformed the ensemble at one and two week ahead predictions (3550, 9020, 19700, 31500, vs. 5240, 9940, 17800, 26400). 

Variation of the performance of the hub ensemble on cases was in between the renewal model and the crowd forecasts, as judged by a visual inspection of the distribution (Figure 2) as well as standard deviation of the WIS (11700, 21900, 40700, 73700 for the ensemble vs. 11800, 33800, 70000, and 135000 for the renewal model and 7480, 16600, 26200, 38600 for the crowd forecasts). 

Forecasts from the ensemble were generally unbiased (bias values of -0.04, -0.03, -0.01, 0.01), even though again overprediction penalties were on average higher than underprediction penalties in absolute terms. The hub ensemble was less sharp than the crowd forecasts at all time horizons and also had faster growing uncertainty for increasing forecast horizons (sharpness of 3670, 6140, 9130, 12200 vs. 2680, 3660, 4750, 5970). It was also more uncertain than the renewal model at one and two week ahead predictions, but its uncertainty grew less quickly than that of the renewal model (sharpness values of 2190, 5420, 10800, 19500). 
The hub ensemble had better empirical coverage than the crowd forecasts and comparable or mostly even slightly better coverage than the renewal model. 

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/figure-forecasts-2.png)\label{fig:forecasts-2}

*Figure 1. A, C: Visualisation of 2 week ahead forecasts against the true observed values. The shape indicates whether there has been a monotonic increase or decrease over the last two weeks leading up to a given data point, or an unclear trend. Forecasts that aren't scored (because there was no complete set of death forecasts available) are greyed out. 
B, D: Visualisation of corresponding WIS relative to the baseline that can be thought of as ‘improvement over the baseline model’. The shape indicates whether the trend was rising, falling or unclear at the date when the corresponding forecast was made (i.e. two weeks earlier, which leads to a shift of two weeks when compared to panels A and C)*

MISSING: INTERPRETATION ABOUT MODELS IN DIFFERENT PHASES

### Death forecasts

#### Comparison of crowd forecasts vs. renewal model and convolution model 

On deaths, the convolution model on average outperformed the renewal model across all forecast horizons (mean WIS of 255, 357, 541, 763, vs. 298, 524, 724, 959) (Table 1, Figure X). It performed on average slightly better than the crowd forecasts at a one and two week ahead horizon (mean WIS of the crowd forecast of 265 and 368), but performed worse than the crowd forecast at greater forecast horizons (mean WIS of 414 and 498 three and four weeks ahead). In terms of median performance, the crowd forecasts beat both the renewal model and the convolution model across all horizons, while the convolution model and renewal model showed comparable median performance (XX vs. XX). Again, for all models, median performance was lower than mean performance, implying skewed distributions. 
In terms of variability of performance, the convolution model, due to two outlier predictions (Figure XX, *find and discuss*), ranked in between the renewal model and the crowd forecasts in terms of standard deviaton of the weighted interval score (XX values). For all three models, empirical coverage was closer to the desired nominal coverage for death forecasts than for case forecasts (with all coverage levels above 33% and 71% for two week ahead predictions and above 38% and 75% for four week ahead predictions). 
Across all horizons, the renewal model forecasts were the least sharp (sharpness values). At one and two week ahead predictions, the convolution model was about as sharp as the crowd forecasts, but had quickly growing uncertainty for three and four week ahead predictions (leading to constant or even improved coverage in spite of worse absolute errors), and became almost as uncertain as the renewal model. 

For death forecasts, there was no clear pattern that overpredictions were more costly in absolute terms than underprediction and instead the picture is varied. Crowd forecasts were upwards biased across all forecast horizons (bias values of 0.08, 0.14, 0.12 and 0.14) and also incurred higher penalties from overprediction (XX numbers). The renewal model was slightly downwards biased on average for most horizons (XX values), but incurred higher penalties from overprediction than from underprediction. The convolution model was on average strongly downwards biased for one and two week ahead predictions (-0.18 and -0.1), but had decreasing bias over time (-0.04 and 0.01 at three and four weeks ahead). 


#### Comparison of our models against the hub ensemble

At death forcasts, the hub ensemble outperformed all other models at all forecast horizons, with mean WIS values of XX. For all but one week ahead forecasts it was also most consistent , having the lowest standard deviation of the WIS (XX values). Ensemble forecasts were relatively unbiased (values of -0.04, 0.01, -0.03 and -0.06). Its empirical coverage was better than that of all other models, having almost perfect coverage at all forecast horizons (e.g. 62% and 96% at a two week ahead and 58% and 92% at a four week ahead horizon). Its predictions were less confident (i.e. less sharp) than the crowd forecasts, and also less confident than those of the convolution model at one to three weeks ahead, but sharper than the renewal model predictions for all but one week ahead forecasts. <!-- suggest remove the last sentence?--> 

<!--
 
### Score distribution

> [name=Sam Abbott] Suggestion: We found a wide variation in forecasts scores accross targets, locations, forecast time horizons, and forecast dates.
> [name=Sam Abbott] Suggest drop: "(The distribution of WIS relative to the baseline is shown in Figure XX in the supplementary information)"
> [name=Sam Abbott] Same note on flow. It should be point and then link to thing and not summary of thing locations followed by some info disconnected from it. 
> [name=Sam Abbott] Could do with a more technical handling: "The hub ensemble, baseline and convolution were usually in between, with performance of the convolution model being almost as varying as the performance of the renewal model for deaths."
Figure 2A shows the distribution of WIS scores for a two week ahead horizon achieved by each model (The distribution of WIS relative to the baseline is shown in Figure XX in the supplementary information). The distribution of WIS scores for different forecast horizons can be seen in Figure XX in the SI, a summary can be seen in Table XX in the Appendix. 
> [name=Sam Abbott] I think there is a lot more nuance to get out from these plots and they probably contain the core of the interesting findings so more interpretation would be good.
> [name=Sam Abbott] Some models have outliers. When were these, do we know what they were, and what happens to overall performance measures if you take them out?
> [name=Sam Abbott] I'd suggest discussing overall by cases and deaths and then by target.
> [name=Sam Abbott] Vis using a log scale.  


The crowd forecasts tended to have the lowest variance in scores (standard deviation of 7600 and 16800 for cases one and two week ahead, 322 and 450 for deaths), while scores for the renewal equation are most dispersed (11900 and 34200 for cases, 407 and 681 for deaths). The hub ensemble, baseline and convolution were usually in between, with performance of the convolution model being almost as varying as the performance of the renewal model for deaths. Notably, the baseline model had the lowest variability in scores (and also the lowest mean and median score) for cases at a four week ahead horizon. 
The WIS distribution was skewed for all models, with the median being higher than the mean. This was most extreme for the renewal model, and usually least extreme for the crowd forecasts. Whether or not a model was 'better than another model' therefore depends on whether one cares about mean performance or median performance. For one and two weeks ahead, for example, the median forecast from the renewal model beat the baseline, while the mean forecast did not. 
<!-- not sure this is true
For the renewal and the convolution model, performance relative to the baseline varied across countries, where the median forecast of the two models beat the baseline in one country, but not the other, as can be seen in Figure 2B. Interestingly, the convolution model performed well on deaths in Germany, even though the renewal model performed poorly. Conversely, the convolution model performed poorly on deaths in Poland even though the renewal had performed relatively well. 


Figure 2C shows the distribution of scores in different phases of the epidemic and Table 3 shows accompanying summarised scores. Across different targets, countries and phases the WIS for the renewal model had the strongest tendency towards a bimodal distribution, meaning that performance was often either very good or very bad. 

<!--
- Renewal and Crowd forecast good when cases are rising (maybe: renewal model is good at modelling exponential growth and humans are good at adapting to turning points)
- hard to identify a clear pattern
-->

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/distribution_scores_wis-2.png)
*Figure 2. A: Estimated density distribution of weighted interval scores (smaller is better) for two week ahead forecasts of the different models and forecast targets. Points indicate single data points. B: Distribution of WIS separate by country. C: Distribution of WIS in different phases of the epidemic. 
Phases are classified according to whether the two weeks prior to the date when a forecast was made show a consistent trend.*

--- 

### Contribution to the Forecast Hub

> [name=Sam Abbott] Isn't this interesting: "This positive contribution from a model often even occured when the ensemble without that model was better than the model itself" -> lets think about that a bit more. 
> [name=Sam Abbott] these need to be in place before sending this elsewhere.
>[name=Sam Abbott] Again flow. Comment, number, link to further info.
> [name=Sam Abbott] Condsider a variant of the distribution plot above to look at what the drivers of this are (i.e showing each variant of the ensemble and the ensemble without us).
> [name=Sam Abbott] I would probably report the median and mean at the same time for WIS and use that as the point of interest.

The crowd forecasts and the renewal model generally improved the performance of the median hub ensemble mostly when considering all forecast dates together. This was particularly true for case forecasts and it was also true both individually and together. This positive contribution from a model often even occured when the ensemble without that model was better than the model itself. Scores from the ensembles with and without the two models included can be seen in Table 3 for one and two week ahead forecasts and in the Table XX in the SI for three and four week ahead forecasts. A pot with the number of ensemble member models over time can be seen in Figure XX in the SI. The median number of models included in the ensemble was 7, with an increase over time. 

For case forecasts, including both models improved the average WIS of the forecast hub median ensemble for one week ahead predictions by 20% from 8770 to 7000. Each of the models alone achieved a reduction of around 10%. For two weak ahead case forecasts, the average WIS was reduced from 18300 to 17500 by the including the renewal model alone, to 16900 by including the crowd forecasts alone and to 16500 with both models included. Note that the renewal model performed, on average, worse than the hub ensemble without it for two week ahead case forecasts with a WIS of 25600). For three and four weeks ahead, inclusion of the renewal model slightly deteriorated ensemble predictions on average, while the crowd forecasts made a positive contribution at all forecast horizons. 
For death forecasts, including both models improved average WIS from 248 to 235 for one week ahead forecasts. For two week ahead forecasts, both models deteriorated performance, albeit only slightly, from an average WIS of 292 to 296 with both models included. At three and four weeks ahead, crowd forecasts made a neutral (three weeks ahead) or positive contribution (four weeks ahead), while the renewal model made the overall performance of the ensemble slightly worse. 

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table_median-ensemble_scores_2_ahead.png)
*Table 3. Summarised scores for the one and two week ahead predictions of the forecast hub median ensemble with and without the crowd forecasts and the renewal model included*

<!--

### Decomposition of the weighted interval score
*- This could be more concise - need to think more about in which direction this should be going and what we're getting out of it. Comparison to the Figure in the SI that plots a distribution of bias values should be interesting to contrast absolute contributions with an overall tendency to over- or underpredict -*

> [name=Sam Abbott] If staying in feels like it needs to come before hub constribution section.
> [name=Sam abbott] Same flow comments as elsewhere.

In general, a large share of penalties from over- and underprediction, as opposed to sharpness, tends to be associated with poor overall performance, because this often occurs when a forecast is far away from the true observed value, regardless of the sharpness of the forecast. While Figure 3 shows the absolute penalties from over- und underprediction, Figure XX in the SI shows the distribution of bias values for the models, which is limited between -1 and 1 and therefore gives a better understanding of the general tendency to over- or underpredict. 

The relative WIS composition varied greatly between models and changed noticeably depending on the phase of the epidemic. When cases and deaths had been falling over the previous two weeks, the baseline model tended to overpredict future cases and deaths, implying that numbers usually continued to fall when they had been falling before. 

In decreasing phases both the renewal model and the hub ensemble tended to underpredict case numbers, forecasting cases to fall lower than they actually did). 

For death forecasts in decreasing phases, sharpness (i.e. forecast uncertainty) played a larger relaive role in overall WIS scores. In increasing phases (especially for cases), underprediction dominated the overall WIS score for the baseline model, implying that usually numbers tended to rise further in these situations. All models, (with the exception of the convolution model and to a certain extent case forecasts from the crowd), overpredicted both future cases and deaths when numbers had been rising before. In unclear phases, over- and underprediction penalties were about equal for the case forecasts from all models. For deaths, however, all models severely underpredicted future deaths in situations where there was no clear trend previously, implying that deaths often rose in these situations. 

-->

## Discussion

### Summary

In this study we evaluated crowd forecasts, simple untuned model based forecasts, and a multi-model ensemble of expert opinion supported models in a robust real-time setting. We found that across a range of forecast observations locations, and evaluation metrics that crowd forecasts performed comparably or better than a large multi-model ensemble made up of expert-informed model based forecasts. The performance of the untuned model forecasts was more nuanced when compared to the ensemble with a large variation in performance but in general we found that the simple models evaluated here improved the overall ensemble they were included in for most scenarios and evaluation targets of interet. The ensemble crowd forecast was rarely the best performing forecast approach at short time scales but delivered consistently good performance without the large outliers seen in untuned model forecasts. In addition at longer time-scales the crowd forecast outperformed other methods for most target types and locations. Stratifying by observation type we found that crowd derived forecasts performed less well and that there was some evidence that simple models could better capture the relationship between COVID-19 cases and deaths though this was hard to fully quantify. This dynamic was highlighted when stratifying by recent trend where crowd forecasts appeared to struggle to forecast deaths during periods of increase (though this inference is based on a low sample size). Across all targets the untuned models we evaluated often performed well at short timescales but this outperformance was marred by several extremely poor forecasts, especially for the renewal model forecasting deaths without the benefit of case data. It is difficult to assess fully whether this behaviour was desirable, or if different optimisation approaches are warranted. At longer time horizons the simple models assumption of no change in transmission from the forecast date resulted in poor performance when forecasting cases and to a less extent deaths when using cases as a predictor.  

- Detail on score: 
    - Crowd forecasts performed well in terms of absolute error suggesting that...
    - In comparison model based forecast which suggests....
    - However crowd based forecasts performed less well in terms of calibration indicating that trend forecasts were relatively correct but forecasters struggled to estimate uncertainty without the aid of a models ability to infer it from data. This is in line with previous research into crowd forecasts [@recchiaHowWellDid2021] and is an area of further research.
    - Our scoring methods were biased towards penalising overprediction during periods of increasing cases. This may have favoured methods with a linear error rather than an exponential error. As both our untuned models used an exponential model of case growth this may have led to some bias against them in our findings.
    - To a certain extent, underpredicting may be interpretable as 'hedging against' or incorporating the fact that a sudden downturn may be possible. Given that underpredictions made up a large part of penalties incurred during increasing phases this implies that either humans were not well prepared to forecast exponential growth in cases or systematically overestimated the probably of a sudden downturn. For deaths it was even more striking that all models consistently overpredicted deaths, maybe missing a change in the observed case fatality rate due to changes in testing. It is interesting to see that the pattern of the relative share of the WIS components for human forecasters most closely resembles the pattern of the baseline model. 


- Changes in trend model comparison (just cases here)
    - Potentially the crowd forecat predicted a slowdown in cases. Was this pricing in an intervention and if so is this a good thing.
    - Model based forecasts were in general good/bad at capturing changes in trend. 
    - The multi-model ensemble was relatively poor at detecting changes in trend though equally it did not predict spurious changes in trend. 

- Detail on comparison between cases and deaths

Future cases often depend on a range of factors that are difficult to quantify such as future policy interventions, adherence to these interventions, testing policy, and the evolution of new disease variants. It appears that these factors may be better captured by explicit crowd forecasts rather than other forms of forecast models, even supported by expert opinion, though it is an open question whether this is desirable in all circumstances. For deaths, there exists a more direct relationship to previously observed cases which can potentially be captured using epidemiological insight and mechanistic modelling. Other studies have found that this makes deaths easier to forecast [@cramerEvaluationIndividualEnsemble2021; @bracherShorttermForecastingCOVID192021], which our results support as even the simplest interpretation of this relationship, deaths as a discrete convolution of cases, performed well in most scenarios. We found some evidence that crowd based forecasts struggled to fully capture this relationship though this was difficult to separate from crowd forecasts ability to incorporate future complex changes which led to outperformance in general across targets. Interestly we found that for some target locations and time periods this relationship between cases and deaths did not hold and in these circumstances a simple model that forecast deaths using only previously observed deaths out performed but this was mitigated by periods of underperformance for this model where knowledge of variation in cases led to improved forecasts. This may indicate that a hybrid approach should perform well but in practice specifying the correct mixture of these approaches may be difficult. For example the hub ensemble is a version of this hybrid approach and also struggled in periods where the relationship between cases and deaths became less clear. 
- More on horizon
    - Optimising a forecast to a specific time horizon relies on understanding the use case of those consuming the forecasts.
    - At longer time horizons modelling potential future interventions becomes more important in the context of forecasting COVID-19 due to the large burdens on the health system meaning that interventions were often required. Whilst building this into forecasts as an assumption may lead to better performing forecasts at these longer time horizons there is a question whether this is a useful thing to do for forecasts used by policy makers. This is difficult to explore more fully without knowing the full context in which forecasts are interpreted and used. 
    
- Interpretation of models contribution to overall forecasts
    - All models improved the ensemble in general
    - Which models improved it the most? 
    - How good were our models as an ensemble (i.e did anyone apart from us add anything - cheeky but interesting). 
    - At longer time horizons our simple models may have worsen the scored performance of forecasts though as mentioned there is a tension here between influencing and incorporating policy changes.
    
<!-- - 

To a certain extent, underpredicting may be interpretable as 'hedging against' or incorporating the fact that a sudden downturn may be possible. Given that underpredictions made up a large part of penalties incurred during increasing phases this implies that either humans were not well prepared to forecast exponential growth in cases or systematically overestimated the probably of a sudden downturn. For deaths it was even more striking that all models consistently overpredicted deaths, maybe missing a change in the observed case fatality rate due to changes in testing. It is interesting to see that the pattern of the relative share of the WIS components for human forecasters most closely resembles the pattern of the baseline model. 


--> 

- Discussion of the mean ensemble

The rationale for taking the mean (rather than the median) was that it would make better use of the available information when the number of forecasters was small, sacrifing the robustness a median ensemble would offer. At the time the ensemble used by the German and Polish Forecast Hub was a mean ensemble. 

- Discussion of the recruiting process
Motivating forecasters to contribute regularly proved challenging, especially given that the majority of our participants were from the UK and had no real connection to either Germany or Poland.


### Strengths and Weaknesses

<!-- *When writing this layer strengths and limitations together. Start with a strength and then for every limitation counter with a strength* -->

> [name=Sam Abbott] Mention: We published everything to a public repo with a timestamp. 
> [name=Sam Abbott] Again if keeping the stated aim of the paper would reflow to mention s and w in the internal structure of the paper and mention the hb stuff second. I would have a section on our general approach in reference to the aim, the crowd forecast, the models, and then the hub. 



Our work has robustly assessed the performance of crowd-sourced human predictions and model based forecasts in a realistic real-time setting. Forecasts reflect unbiased predictive performance at the time and could not be tuned in response to reporting artifacts after submission as they were registered with an independent research organisation. Our evaluation followed a methodology pre-registered by the German and Polish Forecast Hub [@bracherComparisonCombinationRealtime2020] which makes sure our results can be fairly compared against official forecast hub evaluations. 

While the methodology did not change for the Renewal model, the Convolution model and the Baseline model, this continuity is not given for the crowd forecasts and the hub ensemble model. Comparability of crowd forecasts at different time points is hampered by the low number of participants we were able to recruit initially and the fact that participants kept joining or dropping out. Similarly, the composition of the Hub ensemble changed over time as did many of the individual models contributing forecasts to the Forecast Hub. To mitigate this, a wide range of potential confounding factors, like different time periods, were considered to ensure the robustness of the obtained results. 

We showed that even a small number of expert forecasters, who were in general not domain experts in the target countries, can make Covid-19 forecasts that perform well when compared to forecasts from other sources. Unfortunately, due to the low number of submissions per forecast target and date we were not able to evaluate the role of expert knowledge in this study, the impact of the interface exposed to forecasters, or to explore weighting forecasters by prior performance. In particular, our crowd forecasting application was relatively technical which may have precluded less technical, but interested parties, from submitting forecasts. However, our approach did allow us to produce user specific crowd forecasts, and and crowd ensemble forecasts, with a full predictive distribution. This allowed us to directly evaluate crowd forecasts compared to model based forecasts and to submit our crowd forecasts to an ensembling and evaluation platform expressly designed to evaluate quantitive forecasts and improve forecasts available to public health policy makers. Due to the limitations listed above we feel that our findings represent a lower rather than an upper bound for the performance of crowd forecasts of this type. Lastly, we provide our crowd forecasting tooling as an open source R package, meaning that it is available for others to use, and to further develop, in their context. 

**Strengths and weaknesses in the context of the literature**

Forecasts are rarely evaluated based on real-time performance as done in this study with retrospective analysis being more common outside of large scale collaborative projects. This approach has allowed us to capture realised performance characteristics rather than performance in idealised settings. When forecasts are evaluated basesd on real-time performance studies often have to treat the models as effectively "black boxes"  as little is known about the individual models and the interaction between the models and those submitting them. Noteworthy examples of robust forecast ensembling and evaluation projects in the context of COVID-19 are: evaluation of UK SPI-M forecasts (cite seb), the US COVID-19 forecasting hub [@cramerEvaluationIndividualEnsemble2021], the related Germany/Poland forecasting hub @bracherShorttermForecastingCOVID192021, and the more recent ECDC forecasting hub. All of these projects have provided policy makers with forecasts that are more robust than otherwise available and have allowed individual forecasters to be ranked. These projects also have key advantages when compared to our study in that they often have a larger sample size of both submitted models and forecast targets (both in terms of location and observation type) and that those evaluating the forecasts are independent from those submitting forecasts. However, to our knowledge, outside of our submissions to these efforts, none of the submitted forecasts represent either a non-model based crowd forecast or an untuned model based forecast. Another key advantage of our study in comparison to others evaluating  real-time performance was that due to our focus on a limited subset of known models and forecast targets we could explore performance in much greater detail, and with greater clarity than large scale studies such as [@bracherShorttermForecastingCOVID192021; @cramerEvaluationIndividualEnsemble2021; @seb]. A potential limitation of our study in comparison to @bracherShorttermForecastingCOVID192021 was that we did not evaluate the role of interventions on forecast performance. However, we instead explored performance under different categorisations of recent trends in the target observations. This had the advantage of mitigating potentials bias caused by having to define an intervention but may slightly obscure the evaluation of forecasts in the context of the benefit to policy makers. 

Forecasts based on expert and non-expert opinion have been widely used previously both in the context of infectious diseases [@mcandrewAggregatingPredictionsExperts2021; @metaculusPreliminaryLookMetaculus2020; @metaculusPreliminaryLookMetaculus2020]and more widely [@citationsneeded]. Generally, it has been found that crowd forecasts perform well when the target is clearly defined and those submitting opinions are motivated to forecast as well as possible [@citation + fact checking]. However, to our knowledge, crowd infectious disease forecasts have not previously been evaluated against both expert tuned and untuned model based forecasts in real-time previously. However, prior crowd forecasting efforts have benefitted from significantly larger sample sizes and a larger diversity of forecasters. For example in our study many of the forecasts submitted came from researchers working on this study or connected directly to our research group which may have resulted in some biases or reduction in forecasting performance. Another potential limitation is that our application was relatively difficult to use when compared to other crowd forecasting projects such as @recchiaHowWellDid2021. However, this may in fact have benefitted the overall performance of the crowd forecast by raising the technical and motivation levels required to submit. Ultimately however, the impact of this potential bias is difficult to evaluate without further study.


**Future work**

Whilst this study robustly explored the role of crowd forecasts compared to model only forecasts and forecasts using both models and expert opinion there are a large number of avenues for further study. These include exploring individual crowd forecasters contribution to the ensemble in greater detail and in particular understanding what role having an ensemble of forecasters of whatever type (i.e either model or opinion derived) plays versus the potential benefits or costs to a forecast from a single model or individual. A related avenue for further work, which relates to both model based and crowd forecasts is how to optimally ensemble forecasts. In addition to this, different ensembling techniques may work differently when used on forecasts produced from models versus forecasts derived from opinion or forecasts that are a combination of both opinion and models. Another area of further study is understanding why crowd forecasts behave the way they do and if this behaviour is useful for public health policy makers. For example it is liklely that crowd forecasts explicitly account for potential future interventions which may cause issues if forecasts are then used by public health policy makers to decide if these interventions should be implemented. Finally, an area of further work that we are currently pursuing is more fully exploring the interaction between crowd derived forecasts and forecasts from models. It may be the case that combining these two approachs explicitly in a robust framework, borrowing the strengths of each, may lead to improved forecasts overall. Ideally this would over come the noted downsides of crowd forecasts such as the difficulty in scaling them and their relatively poor performance forecasting secondary observations such as COVID-19 deaths whilst not obfuscating the role of human insight. 

**Conclusions**

> [name=Sam Abbott] As mentioned if this is the conclusion the aim of the paper needs to be recast.

Crowd (or expert) forecasts can perform en par or even better than a large ensemble of epidemiological models and is a viable approach for a manageable set of forecasting targets. Human forecasters are good at predicting general trends, even if they tend to be overly confident in their predictions. Our research suggests that purely theory-derived forecasts are not optimal and that models may benefit from human intervention and fine-tuning. Epidemiological models are most at an advantage when there are a large number of targets to predict or when forecasting lagged quantities such as deaths, as these models can more easily cope with large amounts of data and quantify known relations between parameters. Models can make a positive contribution to an existing ensemble even in situation where the model performs worse than the existing ensemble. Future work should investigate how forecasts can be improved, for example by means of weighted ensembles, and by looking into forecasting methods that combine expert opinion and mechanistic modelling. 







--- 

## Supplementary information

### Forecast models

#### Effective Reproduction number model

The model was initialised prior to the first observed data point by assuming constant exponential growth for the mean of assumed delays from infection to case report. 

\begin{align}
  I_{t} &= I_0 \exp  \left(r t \right)  \\
  I_0 &\sim \mathcal{LN}(\log I_{obs}, 0.2) \\
  r &\sim \mathcal{LN}(r_{obs}, 0.2) \\
\end{align}

Where $I_{obs}$ and $r_{obs}
- 12 weeks of data
- Prior log-normal with a mean of 1.1 and a standard deviation of 0.2
- Days with missing data or 0 notifications adjusted to the 7 day moving average if the 7 day moving average of notifications was greater than 50 per day. 
- Population adjustment (cite epidemia)
- Assumed static normally distributed reporting fraction with a mean of 0.25 and a standard deviation of 0.05 for test positive cases and a mean of 0.005 with a standard deviation of 0.0025 for COVID-19 linked deaths.
- Rt fixed from the forecast horizon.
- 4 chains, 250 warmup samples per chain, and 2000 samples overall post warmup.

We estimated the instantaneous reproduction number ($R_t$) using the `EpiNow2` R package (version 1.2.1) [@epinow2] on the last 12 weeks of available data 

The instantaneous reproduction number represents the number of secondary cases arising from an individual showing symptoms at a particular time, assuming that conditions remain identical after that time, and is therefore a measure of the instantaneous transmissibility (in contrast to the case reproduction number - see Fraser (2007) [@Fraser:2007hf] for a full discussion). `EpiNow2` implements a Bayesian latent variable approach using the probabilistic programming language Stan [@rstan], which works as follows. The initial number of infections were estimated as a free parameter with a prior based on the initial number of cases, or deaths, respectively. The initial, unobserved, growth rate was estimated from the first 7 days of reported data. This was used as a prior (normal with standard deviation 0.2) to estimate latent infections prior to the first reported case using a log linear model. For each subsequent time step, previous imputed infections ($I_{t-1}$) were summed, weighted by an uncertain generation time probability mass function ($w$), and combined with an estimate of $R_t$ to give the incidence at time $t$ ($I_t$) [@epinow2; @cori2013; @THOMPSON2019100356]. We used a log normal prior for the reproduction number ($R_0$) with mean 1 and standard deviation 0.2 reflecting our current belief that $R_t$ is likely to be centred around 1 in most of the world, with public health interventions and individual behaviour combining to prevent it from growing significantly larger for sustained periods. 

The infection trajectories were then mapped to mean reported case counts ($D_t$) by convolving over an uncertain incubation period and report delay distribution (convolved into $\xi$). Observed reported case counts ($C_t$) were then assumed to be generated from a negative binomial observation model with overdispersion $\phi$ (using 1 over the square root of a half normal prior with mean 1) and mean $D_t$, multiplied by a day of the week effect with an independent parameter for each day of the week ($\omega_{(t \mod 7)}$). Temporal variation was controlled using an approximate Gaussian process [@approxGP] with a squared exponential kernel ($GP$). In mathematical notation,


This package implements a Bayesian latent variable approach using the probabilistic programming language Stan (27). To initialise the model, infections were imputed prior to the first observed case using a log linear model with priors based on the first week of observed cases. This means that the initial observations both inform the initial parameters and are then also fit, which makes the initial Rt estimates less reliable than later estimates. This was a pragmatic choice to allow the model to be identifiable when only estimating part of the observed epidemic. We explored other parameterisations, but these suffered from poor model identification. For each subsequent time step with observed cases, new infections were imputed using the sum of previous modelled infections weighted by the generation time probability mass function, and combined with an estimate of Rt, to give the prevalence at time t (12). The generation time was assumed to follow a gamma distribution that was fixed over time but varied between samples, with priors drawn from the literature for the mean and standard deviation (28).

\begin{align}
  I_{t_{unobserved}} &= I_0 \exp  \left(r t_{unobserved}\right)  \\
  I_0 &\sim \mathcal{LN}(\log I_{observed}, 0.2) \\
  r &\sim \mathcal{LN}(r_{observed}, 0.2) \\
\end{align}


\begin{align}
  \log R_{t} &= \log R_{t-1} + \mathrm{GP}_t \\
  I_t &= R_t \sum_\tau^{15} w(\tau | \mu_{w}, \sigma_{w}) I_{t - \tau} \\
  O_t &= \sum_\tau^{15} \xi_{O}(\tau | \mu_{\xi_{O}}, \sigma_{\xi_{O}}) I_{t-\tau} \\
  D_t &= \alpha \sum_\tau^{15} \xi_{D}(\tau | \mu_{\xi_{D}}, \sigma_{\xi_{D}}) O_{t-\tau} \\ 
  C_t &\sim \mathrm{NB}\left(\omega_{(t \mod 7)}D_t, \phi\right)
\end{align}


Where,
\begin{align}
     R_0 &\sim \mathcal{LN}(0.079, 0.18) \\
     w &\sim \mathcal{G}(\mu_{w}, \sigma_{w}) \\
    \xi_{O} &\sim \mathcal{LN}(\mu_{\xi_{O}}, \sigma_{\xi_{O}}) \\
    \xi_{D} &\sim \mathcal{LN}(\mu_{\xi_{D}}, \sigma_{\xi_{D}}) \\
\end{align}

with the following priors, 

\begin{align}
    \mu_w &\sim \mathcal{N}(3.6, 0.7) \\
    \sigma_w &\sim \mathcal{N}(3.1, 0.8) \\
    \mu_{\xi_{O}} &\sim \mathcal{N}(1.62, 0.064) \\
    \sigma_{\xi_{O}} &\sim \mathcal{N}(0.418, 0.069) \\
    \mu_{\xi_{D}} &\sim \mathcal{N}(0.614, 0.066) \\
    \sigma_{\xi_{D}} &\sim \mathcal{N}(1.51, 0.048) \\
    \alpha &\sim \mathcal{N}(0.25, 0.05) \\
    \frac{\omega}{7} &\sim \mathrm{Dirichlet}(1, 1, 1, 1, 1, 1, 1) \\
    \phi &\sim \frac{1}{\sqrt{\mathcal{N}(0, 1)}}
\end{align}

When forecasting deaths the following alternative priors were used,

\begin{align}
    \mu_{\xi_{D}} &\sim \mathcal{N}(2.29, 0.076) \\
    \sigma_{\xi_{D}} &\sim \mathcal{N}(0.76, 0.055) \\
    \alpha &\sim \mathcal{N}(0.005, 0.0025) \\
\end{align}

$\alpha$, $\mu$, $\sigma$, and $\phi$ were truncated to be greater than 0 and with $\xi$, and $w$ normalised to sum to 1. $GP_t$ is an approximate Hilbert space gaussian process as defined in [@approxGP] using a Matern 3/2 kernel using a boundary factor of 1.5 and 17 basis functions (20% of the number of days used in fitting). The lengthscale of the Gaussian process was given a log-normal prior with a mean of 21 days, and a standard deviation of 7 days truncated to be greater than 3 days and less than 60 days. The magnitude of the Gaussian process was assumed be normally distributed centred at 0 with a standard deviation of 0.1. The prior for the generation time was sourced from [@generationinterval] but refit using a log-normal incubation period with a mean of 5.2 days (SD 1.1) and SD of 1.52 days (SD 1.1) with this incubation period also being used as a prior [@incubationperiod] for $\xi_{O}$. This resulted in a gamma distributed generation time with mean 3.6 days (standard deviation (SD) 0.7), and SD of 3.1 days (SD 0.8) for all estimates. We estimated the delay between symyptom onset and case report or death required to convolve latent infections to observations by fitting an integer adjusted log-normal distribution to 10 subsampled bootstraps of a public linelist for cases in Germany from April 2020 to June 2020 with each bootstrap using 1% or 1769 samples of the available data  [@kraemer2020epidemiological; @covidregionaldata] and combining the posteriors for the mean and standard deviation of the log-normal distribution [@epinow2; @doiCovid19TemporalVariation; @EvaluatingUseReproduction; @rstan]. This resulted in a delay distribution from symptom onset to case report with a mean of XX and a standard deviation of XX and a delay distribution from sypmtom onset to death with a mean of XX and a standard deviation of XX.


From the forecast time horizon ($T$) and onwards the last value of the Gaussian process was used (hence $R_t$ was assumed to be fixed) and latent infections were adjusted to account for the proportion of the population that was susceptible to infection as follows, 
 
\begin{equation}
    I_t = (N - I^c_{t-1}) \left(1 - \exp \left(\frac{-I'_t}{N - I^c_{T}}\right)\right),
\end{equation}

where $I^c_t = \sum_{s< t} I_s$ are cumulative infections by $t-1$ and $I'_t$ are the unadjusted infections defined above. This adjustment is based on that implemented in the `epidemia` R package (cite epidemia, cite @bhatt202).


Each forecast target was fit independently using using Markov-chain Monte Carlo (MCMC) in stan [@rstan]. A minimum of 4 chains were used with a warmup of 250 each and 2000 samples total post warmup. Convergence was assessed using the R hat diagnostic [@rstan].

We used an estimate of the generation time sourced from . 


### Convolution model



- Summarise key choices
- data used
- 
\begin{equation} 
    D_{t} \sim \mathrm{NB}\left(\omega_{(t \mod 7)} \alpha \sum_{\tau = 0}^{30} \xi(\tau | \mu, \sigma) C_{t-\tau},  \phi \right)
\end{equation}

Where,
\begin{align}
    \frac{\omega}{7} &\sim \mathrm{Dirichlet}(1, 1, 1, 1, 1, 1, 1) \\
    \alpha &\sim \mathcal{N}(0.01, 0.02) \\
    \xi &\sim \mathcal{LN}(\mu, \sigma) \\
    \mu &\sim \mathcal{N}(2.5, 0.5) \\
\sigma &\sim \mathcal{N}(0.47, 0.2) \\
\phi &\sim \frac{1}{\sqrt{\mathcal{N}(0, 1)}}
\end{align}


with $\alpha$, $\mu$, $\sigma$, and $\phi$ truncated to be greater than 0 and with $\xi$ normalised such that $\sum_{\tau = 0}^{30} \xi_(\tau | \mu, \sigma) = 1$. Only the last 3 weeks of data were included in the likelihood though all 12 weeks of data was used during fitting.

4 chains with 1000 warmup samples and 4000 posterior samples. 1000 posterior samples of the case forecast were then randomly matched with the posterior samples from the convolution model with the model being rerun for each sample to provide a forecast of future deaths. 


### Additional figures and tables

#### Aggregate performance metrics for all models
![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/aggregate-performance-all.png)

*Figure S1. Visualisation of aggregate metrics across forecast horizons. A: mean weighted interval score (WIS) across horizons. B: median WIS. C: Absolute error of the median forecast. D: Standard deviation of the WIS. E: Sharpness (higher values mean greater dispersion of the forecast). F: Bias, i.e. general tendency to over- or underpredict. Values are between -1 (complete underprediction) and 1 (complete overprediction) and 0 ideally. G: Empirical coverage of the 50% prediction intervals. F: Empirical coverage of the 90% prediction intervals.*


![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/wis-components.png)
*Figure S2. Relative contributions of sharpness, over- and underprediction to the overall weighted interval score achieved by a model in different phases of the epidemic. Note that the uncertainty of the baseline model depends on the variation of observed differences in the past and is therefore naturally hihger in an unclear phase.*


#### Daily forecasts
![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/daily_truth.png)
*Visualisation of daily report data. Issue with this is that it isn't data as of then, but as of now.*


#### Forecast scores 3-4 weeks ahead

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table_scores_4_ahead.png)

*Table XX: Scores for three and four weeks ahead forecasts (cut to three significant digits and rounded). WIS is the mean weighted interval score (lower values ar better), WIS - median and WIS - sd give the median and standard deviation of all scores achieved by a model. WIS - rel. is the average WIS relative to the average WIS achieved by the baseline model. Sharpness, overprediction and underprediction together some up to the weighted interval score. Bias (between -1 and 1, 0 is ideal) represents the general average tendency of a model to over- or underpredict. 50% and 90%-coverage are the percentage of observed values that fell within the 50% and 90% prediction intervals of a model.*

#### Visualisation of scores and forecasts 1, 3, 4 weeks ahead

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/figure-forecasts-1.png) 

*Figure XX. A, C: Visualisation of one week ahead forecasts against the true observed values. The shape indicates whether there has been a monotonic increase or decrease over the last two weeks leading up to a given data point, or an unclear trend. Forecasts that aren't scored (because there was no complete set of death forecasts available) are greyed out. 
B, D: Visualisation of corresponding scaled relative skill scores for the forecasts shown on the left. Scaled relative skill scores can be thought of as ‘improvement over the baseline model’ (see Methods for details). The shape indicates whether the trend was rising, falling or unclear at the date when the corresponding forecast was made (i.e. two weeks earlier)*

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/figure-forecasts-3.png) 

*Figure XX. A, C: Visualisation of three week ahead forecasts against the true observed values. The shape indicates whether there has been a monotonic increase or decrease over the last two weeks leading up to a given data point, or an unclear trend. Forecasts that aren't scored (because there was no complete set of death forecasts available) are greyed out. 
B, D: Visualisation of corresponding scaled relative skill scores for the forecasts shown on the left. Scaled relative skill scores can be thought of as ‘improvement over the baseline model’ (see Methods for details). The shape indicates whether the trend was rising, falling or unclear at the date when the corresponding forecast was made (i.e. two weeks earlier)*

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/figure-forecasts-4.png) 

*Figure XX. A, C: Visualisation of four week ahead forecasts against the true observed values. The shape indicates whether there has been a monotonic increase or decrease over the last two weeks leading up to a given data point, or an unclear trend. Forecasts that aren't scored (because there was no complete set of death forecasts available) are greyed out. 
B, D: Visualisation of corresponding scaled relative skill scores for the forecasts shown on the left. Scaled relative skill scores can be thought of as ‘improvement over the baseline model’ (see Methods for details). The shape indicates whether the trend was rising, falling or unclear at the date when the corresponding forecast was made (i.e. two weeks earlier)*

#### Distribution of scores 1, 3, 4 week

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/distribution_scores_wis-1.png)

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/distribution_scores_wis-2.png)

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/distribution_scores_wis-3.png)

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/distribution_scores_wis-4.png)

*Figure 2. A: Estimated density distribution of weighted interval scores (smaller is better) for two week ahead forecasts of the different models and forecast targets. Points indicate single data points. B: Distribution of WIS separate by country. C: Distribution of WIS in different phases of the epidemic. 
Phases are classified according to whether the two weeks prior to the date when a forecast was made show a consistent trend.*

#### Distribution of scores at different forecast horizons

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/scores_horizons.png)

*Figure 3. Distribution of weighted interval scores achieved by the models at different horizons. Mean performance (black circles) was generally worse than median performance (black squares), implying that the distribution is skewed and suffers from outliers where models make predictions far away from the true observed values.*
**Maybe make an 'overall' panel as well**


#### Contribution to the hub ensemble

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table_median-ensemble_scores_4_ahead.png)
*Table XX. Summarised scores for the three and four week ahead predictions of the forecast hub median ensemble with and without the crowd forecasts and the renewal model included*

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/ensemble-members.png)
*Figure XX. Number of models that were included in the hub ensemble, including our own models. December 21th and December 28th 2020 were not included in the offical forecast hub evaluation period and therefore not all groups continued to submit models for those dates. The EpiNow2 model was not included on the 28th of December due to technical reasons.*


![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/ensemble-with-and-without-crowd.png)
*Figure XX. Median predictions of the crowd forecast, the median ensemble without the crowd forecast and the median ensemble with the crowd forecast included, but not the renewal model*


![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/ensemble-with-and-without-renewal.png)
*Figure XX. Median predictions of the renewal model, the median ensemble without the renewal model and the median ensemble with the renewal model included, but not the crowd forecasts*

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/ensemble-with-and-without-both.png)
*Figure XX. Median predictions of the renewal model the crwod forecasts, the median ensemble without the two models and the median ensemble with both the crowd forecast and the renewal model*



#### Over- and underprediction


![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/distribution_bias_phases.png)
*Figure XX. Distribution of bias values for all models in different phases of the epidemic.*



## References
