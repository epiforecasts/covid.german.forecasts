---
title: Evaluating crowd sourced forecasts of Covid-19 against epidemiological model forecasts in Germany and Poland
output: pdf_document
bibliography: 
  - references.bib  
  - GermanPolishpaper.bib

---

# Evaluating crowd sourced forecasts of COVID-19 against epidemiological model forecasts in Germany and Poland

*Nikos Bosse, Sam Abbott, Anonymous Alpaca, and Sebastian Funk*

Target journal: elife


Alternative title: 
Comparing human predictions against epidemiological model forecasts of Covid-19 in Germany and Poland


## Abstract


#### Background

Forecasts have played an important role in shaping public policy throughout the Covid-19 pandemic. Model-based forecasts are usually an implicit combination of the researcher's subjective opinion and model assumptions. In this work we explore the contribution of opinion versus model derived insights by comparing two simple model-based forecasts based on epidemiological insights with purely opinion derived forecasts.

#### Methods

We submitted three different forecasts to the German and Polish Forecast Hub between October 12th 2020 and March 1st 2021. The first of these was an ensemble of crowdsourced opinion. We compared this approach with two open-source real-time methods which we did not alter throughout the study period. The first of these, the "renewal model", estimated the target observation by reconstructing infections using an autoregressive approach with the weighting based on the generation time between infections and then using a discrete convolution to estimate reported observations. The second approach, the "convolution model", assumed that a target observation, such as deaths, was a convolution of cases multiplied by a scaling factor. Forecasts were evaluated using the weighted interval score (WIS), the WIS relative to the ensemble of all other hub models (rel. WIS), and the empirical coverage of 50% and 90% prediction intervals. Forecasts at the two-week prediction horizon were treated as the main outcome with performance at other horizons compared to this. We also explored performance by location, target, and epidemic phase. Models policy-relevant contribution were assessed by recalculating the hub ensemble with and without each of our forecasts. 


#### Results

Human forecasters were able to predict case numbers well on average with a lower WIS than both our model forecasts and the hub ensemble (mean rel. WIS of 89%). Crowd forecasts produced the narrowest forecasts with the lowest empirical coverage(50%: 36%; 90%: 55%). Human forecasters performed less well when forecasting deaths where the convolution model outperformed (mean rel. WIS: 122% vs. 126%). The renewal model had only slightly higher mean WIS on cases short-term, but performance deteriorated with increasing horizon (rel. WIS 100% one week ahead, 140% two weeks ahead). In general, the renewal model performed less well than other approaches when forecasting deaths. All forecasts for cases had lower empirical coverage than aimed for. Coverage levels on average were higher for death forecasts. Distributions of WIS for all forecasts were right-skewed, with average performance often dominated by outlier predictions. This was more pronounced for the models with high variance in their performance but was less the case for the ensembles. We found that removing our forecasts from the hub ensemble reduced performance in nearly all scenarios.

#### Conclusions

An ensemble of human insight performed as well, or better, on average than an ensemble of models. However, when evaluated in more detail, performance was mixed with the human insight ensemble rarely providing the best forecast. Models performed better when forecasting deaths than cases with human insight performing comparably less well, indicating that an explicit hybrid strategy may be beneficial. At longer time horizons human insight outperformed all other approaches though this may be partially driven by contributors implicitly accounting for further interventions. This highlights the importance of defining the role of forecasts made to inform policy as to whether or not interventions should be accounted for is a question for those consuming forecasts. The dominance of outliers on our results suggests that further work is needed to understand the importance of reliable surveillance data and the role this plays in producing good forecasts. Overall, we found that all the forecasts we submitted improved ensemble performance even in instances where the individual forecasts scored poorly.


## Introduction

The COVID-19 pandemic has resulted in an increase of interest in infectious disease forecasting, and the evaluation of these forecasts. Single model forecasts [@fergusonReportImpactNonpharmaceutical2020; @IHMEpaper] were impactful on policy decisions early in the pandemic despite previous work having shown that relying on a single model can lead to less accurate forecasts than decisions based on multiple approaches [@yamanaSuperensembleForecastsDengue2016; @gneitingWeatherForecastingEnsemble2005]. Since then several collaborations have sought to improve Covid-19 forecasting by eliciting submissions from a large number of research teams and collecting them in forecast hubs in the United Kingdom [@funkShorttermForecastsInform2020], in the United States of America [@esteecramerCOVID19ForecastHub2020; @cramerEvaluationIndividualEnsemble2021], in Germany and Poland [@bracherShorttermForecastingCOVID192021], and in Europe [@EuroHub]. Whilst all of these efforts have successfully delivered more accurate forecasts to policy makers compared to individual forecasting efforts they have struggled to unpick what leads to good Covid-19 forecasts [@cramerEvaluationIndividualEnsemble2021; @bracherShorttermForecastingCOVID192021; @funkShorttermForecastsInform2020]. 

This has been partly driven by the complexity of the models used to produce the constituent forecasts but also because of the level of expert intervention in most forecasting methods over time due to changes in the pandemic, and the available data. These issues can be decoupled by separating infectious disease forecasting into model derived forecasts, that are unadjusted during the forecast period, and human elicitation forecasts (from now on referred to as crowd forecasts). Model based forecasts have a rich history and have been growing in popularity over the last decade [@mcgowanCollaborativeEffortsForecast2019; @johanssonOpenChallengeAdvance2019; @viboudRAPIDDEbolaForecasting2018; @funkAssessingPerformanceRealtime2019]. A variety of human expert elicitation as well as crowd forecasting projects exist [@mcandrewAggregatingPredictionsExperts2021; @metaculusPreliminaryLookMetaculus2020; @tetlockForecastingTournamentsTools2014; @atanasovDistillingWisdomCrowds2016]. However, these crowd forecasts were not designed to be compared against model derived forecasts and usually follow a different (often binary) format or focus on more nuanced questions. 

In this work, we aim to explore the role of human insight by explicitly comparing an ensemble of human insight with forecasts derived from two epidemiological motivated models that we did not alter throughout the forecast period and an ensemble of models from other researchers which is likely to have been modified based on opinion. All forecasts were produced and submitted in real-time to the German and Polish Forecast Hub over 21 weeks from the 12th October 2020 to March 1st 2021 and combined, along with other forecasts, into an ensemble used by policy makers as well as being independently evaluated by the research group running the German and Polish Forecast Hub.

## Methods

### Data sources

Data on test positive cases and deaths linked to Covid-19 were provided by the organisers of the German and Polish forecast hub [@bracherShorttermForecastingCOVID192021]. Until December 14th 2020 these data were sourced from the European Centre for Disease Control (ECDC) [@DownloadHistoricalData2020a]. After ECDC stopped publishing daily data, observations were sourced from the Robert Koch Institute (RKI) for the remainder of the submission period [@RKICoronavirusSARSCoV2a]. These data are subject to reporting artefacts (such as a retrospective case reporting in Poland on the 24th November [@RozbieznosciStatystykachKoronawirusa0100]), changes in reporting over time and variation in testing regimes (e.g. in Germany from the 11th of November on [@aerzteblattSARSCoV2DiagnostikRKIPasst2020]). 

Line list data used to inform the delay from symptom onset to test postive case report or death in the model based forecasts was sourced from [@kraemer2020epidemiological] with data available up to the 1st of August. Population data at the national and state level in Germany and Poland used in the model based forecasts was sourced from [@statistischesbundesamtBevoelkerungNachNationalitaet2020] and [@glownyurzadstatystycznyLudnoscStanStruktura2020]. 

### Forecasts

#### Model based forecasts

We used two models from the `EpiNow2` R package (version 1.3.3) as our model forecasts [@epinow2]. The first of these models, which was used to forecast both test positive cases and deaths, used the renewal equation [@coriNewFrameworkSoftware2013a] and an approximate Gaussian process [@approxGP] to estimate the effective reproduction number over time for latent infections and then convolved these infections to the target observation using data based delay distributions [@epinow2; @doiCovid19TemporalVariation; @EvaluatingUseReproduction]. The second model, which was only used to forecast deaths, assumed that deaths could be modelled using a scaling parameter, a convolution of test positive cases with a distribution that described the delay from case report to death. Both models assumed a negative binomial observation model and a multiplicative day of the week effect [@epinow2]. All model fitting was done using Markov-chain Monte Carlo (MCMC) in stan [@rstan] with each location and forecast target being fit seperately. More details are available in the supplementary information. 

#### Crowd forecast

Participants were recruited mostly within the Centre of Mathematical Modeling of Infectious Diseases at the London School of Hygiene and Tropical Medicine, but participants were also invited personally or via social media to submit predictions. 


Participants were asked to make forecasts of Covid-19 cases and deaths over a four week ahead horizon using a web application (https://cmmid-lshtm.shinyapps.io/crowd-forecast/). The application was built using the `shiny` and `golem` R packages [@shiny; @golem] and is available in the `crowdforecastr` R package [@crowdforecastr]. To make a forecast in the application participants could select a predictive distribution, with the default being log-normal, and adjust the median and the width of the uncertainty by either interacting with a figure showing their forecast or providing numerical values. The baseline shown was a repetition of the last known observation with constant uncertainty around it computed as the standard deviation of the last four observed log changes in forecasts. We required that participants submitted forecasts with uncertainty that increased over time. Our interface also allowed participants to view the observed data, and their forecasts, using a log scale and presented additional contextual COVID-19 data sourced from [@COVID19DataExplorer]. These data included notifications of both test positive COVID-19 cases and COVID-19 linked deaths, case fatality rates and the number of COVID-19 tests though the availability of the data evolved over the study period. 

Forecasts were stored in a Google Sheet and downloaded, cleaned and processed every week for submission. If a forecaster had submitted multiple predictions for a single target, only the latest submission was kept. Some personal information (like the exact time of the forecast) was removed. Information on the chosen distribution as well as the parameters for median and width were used to obtain a set of 22 quantiles plus the median from that distribution. Forecasts from all forecasters were then aggregated using an unweighted quantile-wise mean. Inclusion was decided based on the authors' ad-hoc assessment of the validity of the forecast submission.


### Forecast submission

Both model based forecasts and crowd preditions were submitted every Tuesday 3pm for Germany and Poland up to a 4 week time horizon. Region level model based forecasts were also made but these are not considered further in this analysis. The model based forecasts used data up to the previous Sunday. Human forecasters were allowed to make forecasts until Tuesday 12am, but were asked to use only information up to Monday. All forecasts were submitted in a quantile-based format with 22 quantiles plus the median prediction for a one to four week ahead horizon. 

All forecasts were processed in a Docker [@merkel2014docker] container that ran automated cron jobs to ensure a reproducible environment. All code and tools necessary to generate the forecasts and make a forecast submission are available in the `covid.german.forecasts` R package [@covidgermanforecasts]. This repository also contains all submitted forecasts.


### Statistical analysis

Forecasts were analysed by visual inspection as well using the following scoring metrics: The weighted interval score (WIS) [@bracherEvaluatingEpidemicForecasts2021], absolute error, bias, and empirical coverage of the 50% and 90% prediction intervals. The WIS is a proper scoring rule used to evaluate forecasts in a quantile format. For a growing set of equally spaced quantiles it converges the continuous ranked probability score (CRPS) [@Gneiting2007] that can be understood as a generalisation of the absolute error to probabilistic forecasts. The WIS can be decomposed into three separate penalties for (lack of) sharpness, overprediction and underprediction. To capture not only the absolute amount of overprediction and underprediction, we also employ a bias metric that is bound between -1 (complete underprediction, all quantiles of the predictive distribution are below the observed value) and 1 (complete overprediction, all quantiles of the predictive distribution are above the observed value) that represents a general tendency to over- or underpredict. In addition to the WIS, we also calculated WIS relative to the baseline by dividing through the WIS achieved by the baseline model. Scores were computed per forecast date, target and country and aggregated using the mean, median and standard deviation. Aggregate Scores were then quantitatively compared and and the distribution of scores was visually inspected. All scores were calculated using the `scoringutils` R package [@scoringutils]. 

For the main analysis we focused on two week ahead predictions, as predictions beyond this horizon are often unreliable due to rapidly changing condition [@bracherShorttermForecastingCOVID192021]. Forecast scores for other horizons were then compared to this baseline performance. As an additional analysis, we stratified the time series into three different categories for every forecast date depending on whether numbers were monotonically rising or falling over the last two weeks prior to a given forecast date. The epidemic was categorised as either 'increasing', 'decreasing' or 'unclear' using this categorisation. Differences of less than 5% relative to the week before were treated as zero, meaning they were interpreted as consistent with either classification. 

At all stages of the evaluation our forecasts were compared to the median ensemble of all other models submitted to the German and Polish Forecast Hub (hub-ensemble). In addition to this we assessed the impact of our forecasts on the realised performance of the forecasting hub by recalculating the hub-ensemble after including each of our forecasts in turn. Finally, we considered performance in comparison to the 'offical' hub ensemble which includes all of our forecasts except for the convolution model. 

## Results

### Forecast submission

From October 12th 2020 until December 7th, only the renewal model and the crowd forecasts were submitted with the convolution model also being submitted from this point. March 1st was chosen as the last submission date, as we switched to submitting forecasts for Germany and Poland to the European Forecast Hub on the 8th of March. From January 11th on we also submitted model based forecasts on a regional level. These forecasts were not further analysed as we could not produce corresponding crowd forecasts due to the large number of locations, limited researcher time, and ability to reach out to enough potential forecasters. Model based forecasts used the same approach throughout the forecast period with no changes to the methodology or setting. Interventions that applied at different points throughout the study period were therefore not explicitly modelled either prospectively or retrospectively. Human forecasters were able to adapt their forecasts to current or likely future interventions. 

A total number of 31 participants submitted forecasts. The median number of forecasters was 6, the minimum 2 and the maximum 9 for a single forecast target. Participation rose steadily and peaked in February, before declining towards the end of the study period. The mean number of submissions from an individual forecaster was 4.7 but the median number was only one - most participants dropped out after their first submission. Only two participants submitted a forecast every single week both of whom are authors on this study. To increase usability, the interfaces visual appearance was continuously tweaked and improved with additional information being added over time.


### Performance overview

We found that crowd forecast had a lower mean WIS than the renewal model across all forecast targets, horizons and locations with a mean WIS for two week ahead predictions relative to the hub ensemble of 89% and 140% for cases and 126% vs. 179% for deaths (Figure 1A, Table 1). The convolution model forecast deaths better on average than the crowd forecast up to two weeks ahead (rel. WIS of 122% vs 126%), where deaths were largely informed by observed cases. It did less well on average at greater forecast horizons (rel. WIS of 180% four weeks ahead vs. 117%). The renewal model generally performed poorly on average at predicting deaths. 

In comparison, using the median WIS, we found that the renewal model outperformed all other forecasts at the one week horizon across all targets and locations (Figure 1B, Table 1). However, as for the mean WIS this performance degraded rapidly as the horizon increased. Performance in comparison to other forecasts was relatively unchanged for the convolution model. The crowd forecast performed comparably or better than the hub-ensemble using the median WIS across all locations, targets and horizons.

Only the crowd forecast consisently out-performed the hub-ensemble when assessed by both median and mean WIS and forecasting cases. The hub ensemble performed better than all our forecasting approaches for forecasting deaths at longer time horizons when assessed using the mean WIS but performance was comparable using the crown ensemble when the median WIS was used. Our model based forecasts performed comparably to the hub-ensemble at short-time horizons but as noted performance rapidly degraded as the horizon increased.  

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/aggregate-performance-all.png)

*Figure 1. Visualisation of aggregate performance metrics across forecast horizons. A: mean weighted interval score (WIS) across horizons. B: median WIS. C: Absolute error of the median forecast. D: Standard deviation of the WIS. E: Sharpness (higher values mean greater dispersion of the forecast). F: Bias, i.e. general tendency to over- or underpredict. Values are between -1 (complete underprediction) and 1 (complete overprediction) and 0 ideally. G: Empirical coverage of the 50% prediction intervals. F: Empirical coverage of the 90% prediction intervals.*


![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table_scores_2_ahead.png) <!-- \label{tab:scores-2} -->

*Table 1: Scores for one and two week ahead forecasts (cut to three significant digits and rounded). Numbers in brackets show the metrics relative to the hub ensemble. WIS is the mean weighted interval score (lower values ar better), WIS - median and WIS - sd give the median and standard deviation of all scores achieved by a model. Sharpness, overprediction and underprediction together some up to the weighted interval score. Bias (between -1 and 1, 0 is ideal) represents the general average tendency of a model to over- or underpredict. 50% and 90%-coverage are the percentage of observed values that fell within the 50% and 90% prediction intervals of a model.*

Generally, trends in overall performance were similar across locations (Figure S1). Notably,the convolution model performed better, when assessed by both median and mean WIS, in Germany than Poland indicating a stronger connection between observed cases and deaths. Due to the differing population sizes and numbers of notifications in Germany and Poland absolute scores were not comparable (Figure S1). 

<!--
I think S1 needs to be relative or its a bit pointless/impossible to compare. 

This stuff not supported I thinnk: The difference in performance across locations was largest for the renewal model, which on average performed poorly in Germany, but comparably to other forecasts in Poland. It was small for the crowd forecast, indicating that forecasters had a greater relative advantage in Germany than in Poland when compared to both the untuned models and the hub ensemble 
--> 

### Calibration, sharpness, and bias

All models were generally relatively well calibrated at short horizons and for death forecast but for case forecasts all approaches had lower than empirical coverage at longer horizons (Figure 1, Table 1). This was a particular issue for the crowd forecast with our model based forecasts having comparable coverage to the hub-ensemble. For deaths forecasts only the renewal model had coverage that matched empiral coverage for the 50% prediction interval with the hub-ensemble being the only forecast that had higher than the empirical coverage. 

At short horizons the renewal model was the sharpest on average for cases but sharpness increased rapidly and non-linearly as the horizon increased (Figure 1E, Tables 1 and S2). The convolution model displayed a similar rapid increase in sharpness as horizon increased whereas both the hub and crowd ensemble did not. This observation is in line with the underlying observation model for both our model based forecasts which is exponential and suggests a linear observation model for the ensembles. Crowd forecasts tended to be the sharpest and especialy for cases issued substantially narrower predictions than all other forecasts. The convolution model was comparably as sharp as the crowd ensemble up to two weeks ahead, but had greater uncertainty for longer horizons. The hub-ensemble varied in sharpness across horizons relative to our model based forecasts (initially being less sharp and then more sharp) but was always less sharp than the crowd ensemble. 

On average both ensembles were generally unbiased when forecasting cases whilst the renewal model displayed a tendency to overpredict though this decreased with horizon (Figure 1 and Table 1). For deaths forecasts the hub-ensemble was again relatively unbiased but the crowd ensemble over-predicted on average. In contrast, the convolution model under-predicted though this reduced as the forecast horizon increased. Interestingly, the renewal model had approximately the same degree of bias and relative change in bias over time as the hub-ensemble when forecasting deaths. 

Overall, for cases forecasts incurred larger absolute penalties from over-prediction than from underprediction and this pattern was reversed for case forecasts (Table 1). This was the case regardless of a forecasts bias for cases, implying that overprediction, when it happened, was on average more costly for case forecasts (Table 1). For deaths there was no clear pattern that overpredictions were more costly in absolute terms than underprediction. Crowd forecasts were upwards biased across all forecast horizons and also on average incurred higher penalties from overprediction (Table 1). The renewal model was slightly downwards biased on average for most horizons, but incurred higher penalties from overprediction than from underprediction. 

All model-based predictions, but not the crowd forecasts were noticeably sharper in Poland than in Germany (Figure S1), in line with their smaller overall WIS values. Crowd forecasts for cases (but not for deaths) were approximately equally sharp in Poland and in Germany. For both cases and deaths, forecasts tended to be lower relative to observed values in Poland than in Germany, with bias values lower for all forecasts in Poland than in Germany (except crowd forecasts of cases, Figure S1F). 
<!-- would be interesting to think more about why this is the case 

I think this needs to be a relative comparison between locations in order to assess forecast difficulty

- Relative difference
- Does this people crowd uncertainty is unrelated to case numbers?  or just a driven by it being linear-->


### Distribution of forecast scores

Across all models, locations, targets and horizons, mean WIS was higher than median WIS, implying right skewed distributions of WIS values (Figure 2 and 3). Overall, low variance in forecast performance was closely linked with good mean performance (Figures 1A and 1D), suggesting that the ability to avoid large errors was an important factor in determining overall performance. The impact of outlier values was especially prononuced for the renewal model, which had more outliers (Figure 2), as well as the highest WIS standard deviation WIS (rel. sd of the WIS 154% for cases and 174% for deaths) of all models across all horizons and targets (Figure S1). Crowd and hub ensembles were more stable and had a lower standard deviation of the WIS than our model forecasts for both cases and deaths. Performance of the convolution model was severly impacted by two large outliers (Figure 3). 


The distribution of WIS differed between case and death forecasts for all models that forecast both targets. In general, the distribution of scores was wider for cases than it was for deaths with this being most apparent for the hub-ensemble which had a much tighter distribution for deaths than for cases. Notably, this difference was not as large for the crowd ensemble and was not evident for the renewal equation potentially highlighting the impact of considering test positive cases when forecasting deaths. The renewal equation, and to a lesser extent the convolution model appeared to either generally out-perform the ensembles or do significantly worse. 

Outliers for the renewal model were more frequent in Germany (and so was variance in WIS values, Figure 1D), where the trend of the epidemic changed more often (Figure 2). Notable outliers were the forecasts made on November 2nd 2020 (target date of November 14th 2020 in Figure 2) and several forecasts made in late December 2020 and early January 2021 (target dates in January 2021 in Figure 2). In October, the renewal model did very well in predicting the exponential growth of cases in Germany until November 2nd 2020 (Figure 2B), but did not immediately adjust to the following slowdown and therefore severly overpredicted. All other forecasts severely under-predicted the rise in cases through October and hence may have been penalised less when interventions were introduced. Human forecasters, possibly aware of the semi-lockdown announced on November 2nd 2020 [@semi-lockdown] and the change in the testing regime (with stricter test criteria) on November 3rd 2020 [@test-regime], were able capture the change in regime faster than all other approaches though the renewal model did capture this change faster than the hub-ensemble. In December, cases rose again in Germany, with all models under-predicting this growth to varying extents. The renewal model again captured the growth in cases better than other approaches and was again penalised for overprediction when reported case numbers fell over Christmas. Predictions from the renewal model in January show a very high variance, with severe underprediction followed by severe overprediction (possibly explained by reporting artefacts over the christmas period, Figure S3). Similar trends in performance were evident in Poland for cases though there were fewer large outlier forecasts and in particular the renewal model performaned more in line with other forecasts. All models tended to better capture the growth and decay rate of the pandemcic. 

Deaths forecasts were again more consistent for Poland with the hub-ensemble performing well and in particular being the only forecast to capture the turnover in early December. The failure of the renewal model to adjust in line with the other forecasts to this turnover likely explains the majority of its poor performance at forecasting deaths. The lack of calibration of the convolution model at early forecast horizons is also evident in Poland (Figure 2B). In Germany all models did poorly in early January with the convolution model doing particularly badly and the ensembles doing relatively well indicating that reporting artefacts over the christmas period may have also been an issue. Under-prediction from all models, excluding the renewal model, was again evident during the period of exponential growth in November and December. 




![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/figure-forecasts-2.png) <!--\label{fig:forecasts-2} -->

*Figure 2. A, C: Visualisation of two week ahead forecasts against the true observed values. The shape indicates whether there has been a monotonic increase or decrease over the last two weeks leading up to a given data point, or an unclear trend. Forecasts that aren't scored (because there was no complete set of death forecasts available) are greyed out. 
B, D: Visualisation of corresponding WIS. The shape indicates whether the trend was rising, falling or unclear at the date when the corresponding forecast was made (i.e. two weeks earlier, which leads to a shift of two weeks when compared to panels A and C).*

<!--
Legend is missing the convolution model
--> 

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/distribution_scores_wis-2.png)
*Figure 3. A: Distribution of weighted interval scores (smaller is better) for two week ahead forecasts of the different models and forecast targets. B: Distribution of WIS separate by country. C: Distribution of WIS in different phases of the epidemic. 
Phases are classified according to whether the two weeks prior to the date when a forecast was made showed a consistent trend.*


### Performance in different phases of the pandemic



- hard to interpret, because different data sources are used. Human forecasters use weekly data, renewal and convoution? use daily data. Hub ensemble unclear. We expect reporting irregularities, especially around Christmas, to affect forecasts (find some examples)
- Humans generally trend following. There was no instance, where humans really predicted a change before it happened, but maybe quicker than models to adapt to new trends (-> need to look for evidence for this)
- In increasing phase for cases, all models had their largest outliers and all were from overprediction --> missing the peak is very costly (--> discussion about hedging)
- Renewal model for deaths in increasing phase --> what's happening there? 
- Convolution model for deaths in unclear phase --> what's happening there? 
- Renewal model had probelems especially when cases and deaths were not moving in the same direction (find evidence)

<!--
Stl decomposition of the daily data?
--> 

<!--
Cases - Decreasing Phase
- overall: phase with the lowest mean and median score
- Renewal model: 4 outliers, often very good
    - one very large outlier in Germany -> continuing trend, maybe day of the week?
        - Forecast date 2021-01-04 Target end date 2021-01-16, underprediction
    - three outliers in Poland. 
        - Target end date 2020-12-07, Forecast date 2020-12-19, underprediction
        - Target end date 2020-12-28, Forecast date 2021-01-09, underprediction
        - Target end date 2021-01-11, Forecast date 2021-01-23, overprediction
    - -> Some kind of daily reporting artifact issue? 
- Crowd forecast: 2 small outliers, often very good
    - both in Poland
        - Forecast date 2020-11-30, Target end date 2020-12-12, overprediction before a sudden drop that humans didn't recognise beforehand (but models did? Maybe that was just the good Polish models)
        - Forecast date 2021-01-11, Target end date 2021-01-23, overprediction
- Hub-ensemble: no outliers, good, but not exceptional overall

Cases - Unclear Phase
- Phase with the fewest observation (for cases)
- Renewal model: 2 very large outliers, otherwise very very good performance
    - both in Germany
        - Forecast date 2020-12-28, Target end date 2021-01-09, underprediction
        - Forecast date 2021-01-11, Target end date 2021-01-23, overprediction
- Crowd forecast: mediocre performance, but no real outliers
- Hub ensemble: mediocre performance, but no real outliers

Models performed well in unclear phase, but had outliers -> humans are good at understanding edge cases like holidays etc. 

Cases - Increasing Phase
- Phase where all models had their largest outliers
- Renewal model: six outliers
    - Germany
        - Forecast date 2020-10-26, Target end date 2020-11-07, overprediction
        - Forecast date 2020-11-02, Target end date 2020-11-14, overprediction
        - Forecast date 2020-12-14, Target end date 2020-12-26, overprediction
        - Forecast date 2020-12-21, Target end date 2021-01-02, overprediction
    - Poland
        - Forecast date 2020-11-02, Target end date 2020-11-14, overprediction
        - Forecast date 2020-11-09, Target end date 2020-11-21, overprediction
- Crowd forecast: one outlier, more mediocre forecasts
    - Germany
        - Forecast date 2020-12-21, Target end date 2021-01-02, overprediction
- Hub ensemble: 5 outliers
    - Germany
        - Forecast date 2020-11-02, Target end date 2020-11-14, overprediction
        - Forecast date 2020-11-09, Target end date 2020-11-21, overprediction
        - Forecast date 2020-12-21, Target end date 2021-01-02, overprediction
    - Poland
        - Forecast date 2020-11-02, Target end date 2020-11-14, overprediction
        - Forecast date 2020-11-09, Target end date 2020-11-21, overprediction

Deaths - Decreasing Phase (threshold 350)
- Phase with the lowest scores for deaths
- Renewal model: one large outlier, two smaller ones
    - Germany
        - Forecast date 2021-01-25, Target end date 2021-02-06, overprediction
    - Poland 
        - Forecast date 2020-12-28, Target end date 2021-01-09, very large underprediction, very very sharp forecast -> data issue? 
        - Forecast date 2021-01-11, Target end date 2021-01-23, overprediction
- Crowd forecast: 2 outliers
    - Germany
        - Forecast date 2021-02-08, Target end date 2021-02-20, overprediction
    - Poland
        - Forecast date 2021-01-04, Target end date 2021-01-16, underprediction
- Hub ensemble: 2 outliers
    - Germany
        - Forecast date 2021-01-25, Target end date 2021-02-06, excessive sharpness
    - Poland
        - Forecast date 2021-01-04, Target end date 2021-01-16, underprediction
- Convolution model: overall quite good performance
    - Germany
        - Forecast date 2021-03-01, Target end date 2021-03-13, overprediction


Deaths - Unclear Phase (threshold 500)
- Renewal: 3 outliers
    - Germany
        - Forecast date 2020-12-28, Target end date 2021-01-09, underprediction
        - Forecast date 2021-01-04, Target end date 2021-01-16, underprediction
    - Poland
        - Forecast date 2021-01-18, Target end date 2021-01-30, overprediction
- Crowd forecast: 2 outliers (identical outliers to Renewal in Germany)
    - Germany
        - Forecast date 2020-12-28, Target end date 2021-01-09, underprediction
        - Forecast date 2021-01-04, Target end date 2021-01-16, underprediction
- Hub ensemble: 1 outlier
    - Germany
        - Forecast date 2021-01-04, Target end date 2021-01-16, underprediction
- Convolution: outliers (identical outliers to Renewal in Germany)
    - Germany
        - Forecast date 2020-12-28, Target end date 2021-01-09, underprediction
        - Forecast date 2021-01-04, Target end date 2021-01-16, underprediction

Deaths - Increasing Phase: Threshold 500
- Renewal: 3 outliers 
    - Germany
        - Forecast date 2022-12-21, Target end date 2021-01-02, overprediction
        - Forecast date 2021-01-11, Target end date 2021-01-23, overprediction
        - Forecast date 2021-01-18, Target end date 2021-01-30, overprediction
- Crowd forecast: 3 outliers (same as Renewal)
    - Germany
        - Forecast date 2022-12-21, Target end date 2021-01-02, overprediction
        - Forecast date 2021-01-11, Target end date 2021-01-23, overprediction
        - Forecast date 2021-01-18, Target end date 2021-01-30, overprediction
- Hub ensemble: only one of the 3 outliers
    - Germany
        - Forecast date 2022-12-21, Target end date 2021-01-02, overprediction
- Convolution: only one of the 3, but a different from Hub ensemble, and also in a different direction
    - Germany
        - Forecast date 2021-01-11, Target end date 2021-01-23, underprediction
        
- maybe discuss the way the renewal model generates its uncertainty -> difference between rising and falling case numbers
- maybe somethin about weekly and daily data here? Or in the discussion

-->

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

### Contribution to the Forecast Hub

Our forecasts in general improved the overall performance of the hub-ensemble for short-term forecasts when considering both the mean and the median WIS over all locations and targets (Figure 4). At the two week horizon our forecasts reduced the peformance of the hub-ensemble in terms of the mean WIS for case forecasts but were otherwise beneficial. At longer horizons the renewal model reduced the performance of the hub-ensemble for all targets using the mean WIS and had little impact on the median WIS. The crowd forecast greatly improved the hub-ensemble at longer horizons when considering the mean WIS but interestly decreased performance as assessed using the median WIS. However, including the crowd ensemble improved the overall hub-ensemble when the renewal model was also included, suggesting a synergy between these forecasting methods. 

In terms of absolute error our submissions increased performance when forecasting cases (except at the 3/4 week horizon for the renewal model) but substantially reduced it when forecasting deaths at all but the one week horizon. This was combined with a general reduction in uncertainty due to our submissions with this being particularly the case for death forecasts at longer time horizons. Our forecasts had little impact on the overall bias and coverage of the hub-ensembles. 


![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/aggregate-performance-rel-ensemble.png)
*Figure 4. Visualisation of aggregate performance metrics across forecast horizons for the different versions of the hub ensemble. "Hub-ensemble" exludes all our models, Hub-ensemble-all includes all of our models, "Hub-ensemble-real" is the real hub ensemble with the renewal model and the crowd forecasts included. Except for empirical coverage, all values are calculated as observed difference to the hub ensemble excluding our contributions. A: mean weighted interval score (WIS) across horizons. B: median WIS. C: Absolute error of the median forecast. D: Standard deviation of the WIS. E: Sharpness (higher values mean greater dispersion of the forecast). F: Bias, i.e. general tendency to over- or underpredict. Values are between -1 (complete underprediction) and 1 (complete overprediction) and 0 ideally. G: Empirical coverage of the 50% prediction intervals. F: Empirical coverage of the 90% prediction intervals.*

## Discussion

### Summary

In this study we evaluated a crowd ensemble, unadjusted epidemiologically motivated model based forecasts, and a multi-model ensemble of expert opinion adjusted models in a robust real-time setting. We found that in general our submissions improved the overall ensemble of models performance, though there was a trade-off with worse performance at longer horizons for death forecasts. Our ensemble of crowd opinion had similar performance characteristics to the overall hub-ensemble but consistently performed better using a range of metrics. Our unadjusted model based forecasts had more varied performance and in particular performed well at short forecast horizons but poorly at longer horizons and when reporting artefacts were present in the data. However, they did capture exponential growth better than other approaches, including our crowd ensemble, and more rapidly adjusted to the changes in trend once they appeared in the target data stream than other methods considered. There was some evidence that model based approaches based on observed cases could outperform methods that did not explicitly include this information when forecasting deaths, especially at shorter forecast horizons. In general, both ensemble approaches had little between forecast variation in performance and were rarely the worst, or the best forecast. Our model based forecasts often performed as well or better than the ensembles, especially at short forecast horizons, but this was largely mitigated by larger outliers where performance was poor. All forecasts showed better calibration for deaths than for cases, suggesting that deaths may be easier to forecast than cases due to the presence of leading indicators such as case notifications or hospitalisations.

<!--
 Sam: I am not sure this is actually true based on the evidence? 
 
 My hesitation is because its only the mean absolute error that is available to be looked at. Looking at the actual forecast vs values its often hard to say the crowd got the trend right. 
 
. Of all models, the crowd ensemble made the narrowest predictions and had the lowest empirical coverage values. This is especially true for case forecasts, where humans did well at predicting overall stable trends and had low absolute forecast errors, but struggled with quantifying their uncertainty, resulting in overconfident predictions and low empirical coverage (in line with previous research into crowd forecasts [@recchiaHowWellDid2021; @TomMcAndrew]). Our untuned models, on the other hand, did better in terms of calibration even though they were on average further away from the observed values.

-->


### Strengths and Weaknesses


<!--#### Aims -->
In this paper we have attempted to disentangle the role of human insight and epidemiological modelling in real-time Covid-19 forecasting. Our work has robustly assessed the performance of crowd-sourced human predictions and model based forecasts in a realistic real-time setting. Forecasts reflect unbiased predictive performance at the time and could not be tuned in response to reporting artifacts after submission as they were registered with an independent research organisation, timestamped and published to a public repository. Our evaluation followed a methodology pre-registered by the German and Polish Forecast Hub [@bracherComparisonCombinationRealtime2020] which makes sure our results can be fairly compared against official forecast hub evaluations. Submitting human crowd forecasts to a forecast hub expressly designed to evaluate and aggregate quantitative forecasts is a novelty and created a unique opportunity to directly and fairly compare human predictions against model-based forecasts as well as contribute to the forecasts available to public health policy makers. Our findings shed light on potential structural patterns that distinguish human crowd forecasts, untuned model-based predictions and forecast models that are continuously improved by human intervention. They are, however, not directly generalisable for a few reasons. 

<!-- #### Generalisability -->
First, our untuned models cannot represent all model-based forecasts. While we aimed to create to models that capture the simplest possible epidemiological baseline assumption about how an epidemic involves, these are still two particular models with particular strengths and weaknesses. Second, findings are confounded by the fact that we compared models and ensembles of models. Many of the features we observed, for example the ability or inability to avoid large outlier predictions, may be more a feature of ensembles, or the type of ensembles used here, than sign of any human intervention. However, omitting the complexity of comparing all individual forecasters as well as forecast hub models allowed us to discern patterns and trends in a way that would otherwise have been hard to accomplish. Third, we were not able to directly observe the role of human insight in the models that were submitted to the German and Polish Forecast Hub. Based on conversations with different contributors we know that all models have been tuned by human intervention to variying degrees, but are not able to quantify this conclusively, nor estimate the effect of human interventions on hub models. We unfortunately did not test a scenario where users were tasked to directly adjust predictions from the renewal model and the convolution model (and also did not have the statistical power to do so). This would have been a possible way to quantify the effect of researchers tuning their models more directly. Fourth, while the methodology did not change for the renewal model and the convolution model, this continuity is not given for the crowd forecasts and the hub ensemble. Comparability of crowd forecasts at different time points is hampered by the low number of participants we were able to recruit initially and the fact that participants kept joining or dropping out. Similarly, the composition of the Hub ensemble changed over time as did many of the individual models contributing forecasts to the Forecast Hub. Fifth, given the low number of participants, it is difficult to generalise conclusions about crowd predictions to other settings. In particular, our crowd forecasting application was relatively technical which may have precluded less technical, but interested parties, from submitting forecasts. This relatively high bar to participate (compared to a simple online study like e.g. [@reccia] conducted) may have impacted on performance. It is both conceivable that a greater number of participants would have improved forecasts, but also that excluding a larger audience may have increased average quality of predictions. Given that the majority of our forecasters was based in the UK and therefore had limited connection to Germany or Poland, perfomance might be better in a setting with a greater number of participants who have detailed local expertise. The low number of forecasers may also be problematic in that most of those regularly submitting were involved in producing or designing our model based forecasts. 

<!-- #### Forecaster recruitment -->
Motivating forecasters to contribute regularly proved challenging, especially given that the majority of our participants were from the UK and little connection to either Germany or Poland. In addition, lack of capacity to do proper outreach played an important role as well as a lack of time and resources to design the interface in a way that is appealing enough to attract large audiences outside of academia. Having to ask forecasters for a full predictive distribution (instead of a simple point prediction) increased complexity for participants, but allowed us submit the forecasts to the German and Polish Forecast Hub as well as analyse probabilistic aspects of human forecasts. Using an R shiny app as an interface arguably created some limits to user experience and performance, influencing the number of participants. On the other hand, it faciliated quick development and allows us to provide our crowd forecasting tooling as an open source R package, meaning that it is available for others to use, and to further develop, in their context. 

Due to the low number of submissions per forecast target and date we were not able to evaluate some important factors, namely the role of expert knowledge in this study, the impact of the interface exposed to forecasters and the baseline model shown, or to explore weighting forecasters by prior performance. Notwithstanding these limitations, we showed that even a small number of human forecasters, who were in general not domain experts in the target countries, can make Covid-19 forecasts that perform well when compared to forecasts from other sources. We hypothesise that our findings represent a lower rather than an upper bound for the performance achieveable with crowd forecasts of this type. 


**Strengths and weaknesses in the context of the literature**

Forecasts are rarely evaluated based on real-time performance as done in this study with retrospective analysis being more common outside of large scale collaborative projects. This approach has allowed us to capture realised performance characteristics rather than performance in idealised settings. When forecasts are evaluated basesd on real-time performance studies often have to treat the models as effectively "black boxes"  as little is known about the individual models and the interaction between the models and those submitting them. Noteworthy examples of robust forecast ensembling and evaluation projects in the context of COVID-19 are: evaluation of UK SPI-M forecasts (cite seb), the US COVID-19 forecasting hub [@cramerEvaluationIndividualEnsemble2021], the related Germany/Poland forecasting hub @bracherShorttermForecastingCOVID192021, and the more recent ECDC forecasting hub. All of these projects have provided policy makers with forecasts that are more robust than otherwise available and have allowed individual forecasters to be ranked. These projects also have key advantages when compared to our study in that they often have a larger sample size of both submitted models and forecast targets (both in terms of location and observation type) and that those evaluating the forecasts are independent from those submitting forecasts. However, to our knowledge, outside of our submissions to these efforts, none of the submitted forecasts represent either a non-model based crowd forecast or an untuned model based forecast. Another key advantage of our study in comparison to others evaluating  real-time performance was that due to our focus on a limited subset of known models and forecast targets we could explore performance in much greater detail, and with greater clarity than large scale studies such as [@bracherShorttermForecastingCOVID192021; @cramerEvaluationIndividualEnsemble2021; @seb]. A potential limitation of our study in comparison to @bracherShorttermForecastingCOVID192021 was that we did not evaluate the role of interventions on forecast performance. However, we instead explored performance under different categorisations of recent trends in the target observations. This had the advantage of mitigating potential biases caused by having to define an intervention but may slightly obscure the evaluation of forecasts in the context of the benefit to policy makers. 

Forecasts based on expert and non-expert opinion have been widely used previously both in the context of infectious diseases [@mcandrewAggregatingPredictionsExperts2021; @metaculusPreliminaryLookMetaculus2020; @metaculusPreliminaryLookMetaculus2020]and more widely [@citationsneeded]. Generally, it has been found that crowd forecasts perform well when the target is clearly defined and those submitting opinions are motivated to forecast as well as possible [@citation + fact checking]. However, to our knowledge, crowd infectious disease forecasts have not previously been evaluated against both expert adjusted and unadjusted model based forecasts in real-time previously. However, prior crowd forecasting efforts have benefitted from significantly larger sample sizes and a larger diversity of forecasters. For example in our study many of the forecasts submitted came from researchers working on this study or connected directly to our research group which may have resulted in some biases or reduction in forecasting performance. Another potential limitation is that our application was relatively difficult to use when compared to other crowd forecasting projects such as @recchiaHowWellDid2021. However, this may in fact have benefitted the overall performance of the crowd forecast by raising the technical and motivation levels required to submit. Ultimately however, the impact of this potential bias is difficult to evaluate without further study.


### Differences in predicting cases and deaths

<!--
I've left this in and I like it but it 1 is maybe a conclusion and two maybe just needs to be cut because this paper is really long.. 

Also the case for the next section. All is sort of conclusios/dicussiion/chat and could really go anyhwere. 

If possible cram into 1 to 2 paragraphs I think with the conlusions. 
---> 

Future cases often depend on a range of factors that are difficult to quantify such as policy interventions, adherence to interventions, testing policy, and the evolution of new disease variant. For deaths, there exists a more direct relationship to previously observed cases which can potentially be captured using epidemiological insight and mechanistic modelling. Other studies have found that this makes deaths easier to forecast [@cramerEvaluationIndividualEnsemble2021; @bracherShorttermForecastingCOVID192021], which our results support as even a simple interpretation of this relationship, deaths as a discrete convolution of cases, performed well in most scenarios. Death forecasts also had better coverage values than case forecasts, indicating that models were better able to adjust their uncertainty over time. We found some evidence that the crowd ensemble struggled to fully capture this relationship. Interestly we found that for some target locations and time periods this relationship between cases and deaths did not hold and in these circumstances a model that forecast deaths using only previously observed deaths outperformed but this was mitigated by periods of underperformance for this model where knowledge of variation in cases led to improved forecasts. This may indicate that a hybrid approach should perform well but in practice specifying the correct mixture of these approaches may be difficult. The hub ensemble could be considered a version of this hybrid approach but also struggled in periods where the relationship between cases and deaths became less clear. 


<!--
### Human underprediction
> [name=Nikos] Need to think more about this


optimal strategy is constant underprediction, because overpredicting the peak is really really costly. -> maybe not what you would want

To a certain extent, underpredicting may be interpretable as 'hedging against' or incorporating the fact that a sudden downturn may be possible. Given that underpredictions made up a large part of penalties incurred during increasing phases this implies that either humans were not well prepared to forecast exponential growth in cases or systematically overestimated the probably of a sudden downturn. For deaths it was even more striking that all models consistently overpredicted deaths, maybe missing a change in the observed case fatality rate due to changes in testing. 



### Linear or exponential error
> [name=Nikos] @Sam can you elaborate on this one?

- Our scoring methods were biased towards penalising overprediction during periods of increasing cases. This may have favoured methods with a linear error rather than an exponential error. As both our untuned models used an exponential model of case growth this may have led to some bias against them in our findings.



### Capturing changes in trends

- Changes in trend model comparison (just cases here)
    - Potentially the crowd forecat predicted a slowdown in cases. Was this pricing in an intervention and if so is this a good thing.
    - Model based forecasts were in general good/bad at capturing changes in trend. 
    - The multi-model ensemble was relatively poor at detecting changes in trend though equally it did not predict spurious changes in trend. 



### Contribution to the forecast hub ensemble
- Interpretation of models contribution to overall forecasts
    - All models improved the ensemble in general
    - Which models improved it the most? 
    - How good were our models as an ensemble (i.e did anyone apart from us add anything - cheeky but interesting). 
    - At longer time horizons our simple models may have worsen the scored performance of forecasts though as mentioned there is a tension here between influencing and incorporating policy changes.
    
    
-->

### Contrasting forecasting goals and the trade-offs involved

Deciding on how to evaluate a forecast, and concluding whether it is 'good' or 'poor' to a certain extent depends on what that forecast is meant to achieve. Some policy-makers, for example, may view underprediction more problematic than overprediction in a way that is not captured by our main evaluation metric, the weighted interval score. Similarly, optimising a forecast to a specific time horizon relies on understanding how the forecast is used by those that consume it. This is potentially somewhat difficult in the context of a forecast hub, where very different groups (academics, policy makers, the general public) see and use the forecasts. Modelling that is meant to inform policy makers may be different from forecasts meant to inform general public about possible scenarios, and yet again different from a situation where research teams submit predictions with the goal of advancing open research and in order to allow public scrutiny and discussion about the merits of different approaches. 

<!--
This is really nice but there is an assumption here that the crowd was actually good at capturing interventions. This may be the case but they also basically always underpredicted so perhaps some measure of the long run performance is just that combined with the way we score. 
--->
We feel this is a point worth reflecting on in the context of our research. Judging by the weighted interval score, we found that the crowd ensemble outperformed the model based forecasts at longer forecast horizons. To a certain extent this is to be expected as humans are able to foresee future changes in conditions (e.g. future policy interventions, adherence to these interventions, testing policy, and the evolution of new disease variants) while our models made forecasts based on fixed assumptions. This distinction is important especially if we think of 'future changes in conditions' mostly in terms of things that depend on decisions and changes in behaviour, as not only do these change forecasts, but also forecasts may influence future interventions and behaviour. The apparent advantage of the crowd ensembles may therefore even be a drawback, depending on who is using the forecasts for what purpose. If the aim of a forecast is to inform policy and decision making, than precluding the very interventions one is meant to inform may be problematic (and conversely, arguing for or against interventions based on predictions may be difficult depending on what the forecast assumes about future interventions). In that sense, crowd forecasts can be understood as actual forecasts, whereas our models may be better understood as scenario modelling that shows what would happen based on epidemiological assumptions if everything stayed as it is. Adapting to changing conditions, however, again needs some kind of human intervention that incorporates knowledge or assumptions about the new conditions into the model. 


<!-- 
Suggest cut. Are we really sure that this isn't just driven by how we choose to score? As in I can see this being a good idea and it certianly has been at points but does our evidence support it as being a good forecast? 

In order to not dilute the model based predictions with human opinion, we refrained from applying any tweaks to the models. One possible very simple adjustment that would seem promising in terms of pure predictive performance would be to have $R_t$ revert to one over time for the renewal model. 

-->
<!--
- More on horizon
    - Optimising a forecast to a specific time horizon relies on understanding the use case of those consuming the forecasts.
    - At longer time horizons modelling potential future interventions becomes more important in the context of forecasting COVID-19 due to the large burdens on the health system meaning that interventions were often required. Whilst building this into forecasts as an assumption may lead to better performing forecasts at these longer time horizons there is a question whether this is a useful thing to do for forecasts used by policy makers. This is difficult to explore more fully without knowing the full context in which forecasts are interpreted and used. 
-->
**Future work**

Whilst this study robustly explored the role of crowd ensemble forecasts compared to model forecasts and forecasts using both models and expert adjustment there are a large number of avenues for further study. These include exploring individual crowd forecasters' contributions to the ensemble in greater detail and in particular understanding what role having an ensemble of forecasters of whatever type (i.e either model or opinion derived) plays versus the potential benefits or costs to a forecast from a single model or individual. A related avenue for further work, which relates to both model based and crowd forecasts is how to optimally ensemble forecasts. In addition to this, different ensembling techniques may work differently when used on forecasts produced from models versus forecasts derived from opinion or forecasts that are a combination of both opinion and models. Another area of further study is understanding why crowd forecasts behave the way they do and if this behaviour is useful for public health policy makers. For example it is likely that crowd forecasts explicitly account for potential future interventions which may cause issues if forecasts are then used by public health policy makers to decide if these interventions should be implemented. Finally, an area of further work that we are currently pursuing is more fully exploring the interaction between crowd derived forecasts and forecasts from models. It may be the case that combining these two approachs explicitly in a robust framework, borrowing the strengths of each, may lead to improved forecasts overall. Ideally this would overcome the noted downsides of crowd forecasts such as the difficulty in scaling them and their relatively poor performance forecasting secondary observations such as COVID-19 deaths whilst not obfuscating the role of human insight. 

**Conclusions**

Epidemiological forecasting is usually a mix between human insight and model-based assumptions and both of these have their merits and relative advantages. Humans, though often overconfident and potentially poor and detected nascent signals, are well equipped to anticipate general trends and their insight is especially valuable for targets that are intrinsically hard to model due to unmeasured influencing factors. For cases, model-based predictions could therefore potentially gain from manual human intervention. Models, on the other hand, are better suited to forecast targets over short periods of time or that require understanding and quantification of epidemiological relationships such as the delays between cases and deaths. Our research suggests that model-based forecasts may benefit from guidance and assumptions informed by human insight to perform well at longer time horizons, when conditions evolve over time, and in the presence of reporting artefacts in surveillance data. Whether or not assumptions about future changes in behaviour or policy should be incorporated into predictions depends on the use case of those who consume the forecasts. Our results support the continuing use of ensembles to produce forecasts intended to be consumed by non-experts as even models that appeared to perform poorly on average improved the over all average performance of the ensemble without the resulting forecast being susceptible to occassional very poor performance. 



--- 

## Supplementary information

### Forecast models

#### Renewal equation model

The model was initialised prior to the first observed data point by assuming constant exponential growth for the mean of assumed delays from infection to case report. 

\begin{align}
  I_{t} &= I_0 \exp  \left(r t \right)  \\
  I_0 &\sim \mathcal{LN}(\log I_{obs}, 0.2) \\
  r &\sim \mathcal{LN}(r_{obs}, 0.2) \\
\end{align}

Where $I_{obs}$ and $r_{obs}$ are estimated form the first week of observed data. For the time window of the observed data infections were then modelled by weighting previous infections by the generation time and scaling by the instantaneous reproduction number. These infections were then convolved to cases by date ($O_t$) and cases by date of report ($D_t$) using log-normal delay distributions. This model can be defined mathematically as follows,


\begin{align}
  \log R_{t} &= \log R_{t-1} + \mathrm{GP}_t \\
  I_t &= R_t \sum_{\tau = 1}^{15} w(\tau | \mu_{w}, \sigma_{w}) I_{t - \tau} \\
  O_t &= \sum_{\tau = 0}^{15} \xi_{O}(\tau | \mu_{\xi_{O}}, \sigma_{\xi_{O}}) I_{t-\tau} \\
  D_t &= \alpha \sum_{\tau = 0}^{15} \xi_{D}(\tau | \mu_{\xi_{D}}, \sigma_{\xi_{D}}) O_{t-\tau} \\ 
  C_t &\sim \mathrm{NB}\left(\omega_{(t \mod 7)}D_t, \phi\right)
\end{align}


Where,
\begin{align}
     w &\sim \mathcal{G}(\mu_{w}, \sigma_{w}) \\
    \xi_{O} &\sim \mathcal{LN}(\mu_{\xi_{O}}, \sigma_{\xi_{O}}) \\
    \xi_{D} &\sim \mathcal{LN}(\mu_{\xi_{D}}, \sigma_{\xi_{D}}) \\
\end{align}


This model used the following priors for cases,

\begin{align}
     R_0 &\sim \mathcal{LN}(0.079, 0.18) \\
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

and updated the reporting process as follows when forecasting deaths,

\begin{align}
    \mu_{\xi_{D}} &\sim \mathcal{N}(2.29, 0.076) \\
    \sigma_{\xi_{D}} &\sim \mathcal{N}(0.76, 0.055) \\
    \alpha &\sim \mathcal{N}(0.005, 0.0025) \\
\end{align}

$\alpha$, $\mu$, $\sigma$, and $\phi$ were truncated to be greater than 0 and with $\xi$, and $w$ normalised to sum to 1. 

The prior for the generation time was sourced from [@generationinterval] but refit using a log-normal incubation period with a mean of 5.2 days (SD 1.1) and SD of 1.52 days (SD 1.1) with this incubation period also being used as a prior [@incubationperiod] for $\xi_{O}$. This resulted in a gamma distributed generation time with mean 3.6 days (standard deviation (SD) 0.7), and SD of 3.1 days (SD 0.8) for all estimates. We estimated the delay between symyptom onset and case report or death required to convolve latent infections to observations by fitting an integer adjusted log-normal distribution to 10 subsampled bootstraps of a public linelist for cases in Germany from April 2020 to June 2020 with each bootstrap using 1% or 1769 samples of the available data  [@kraemer2020epidemiological; @covidregionaldata] and combining the posteriors for the mean and standard deviation of the log-normal distribution [@epinow2; @doiCovid19TemporalVariation; @EvaluatingUseReproduction; @rstan]. 

$GP_t$ is an approximate Hilbert space gaussian process as defined in [@approxGP] using a Matern 3/2 kernel using a boundary factor of 1.5 and 17 basis functions (20% of the number of days used in fitting). The lengthscale of the Gaussian process was given a log-normal prior with a mean of 21 days, and a standard deviation of 7 days truncated to be greater than 3 days and less than 60 days. The magnitude of the Gaussian process was assumed be normally distributed centred at 0 with a standard deviation of 0.1.

From the forecast time horizon ($T$) and onwards the last value of the Gaussian process was used (hence $R_t$ was assumed to be fixed) and latent infections were adjusted to account for the proportion of the population that was susceptible to infection as follows, 
 
\begin{equation}
    I_t = (N - I^c_{t-1}) \left(1 - \exp \left(\frac{-I'_t}{N - I^c_{T}}\right)\right),
\end{equation}

where $I^c_t = \sum_{s< t} I_s$ are cumulative infections by $t-1$ and $I'_t$ are the unadjusted infections defined above. This adjustment is based on that implemented in the `epidemia` R package (cite epidemia, cite @bhatt202).


#### Convolution model

The convolution model shares the same observation model as the renewal model but rather than assuming that an observation is predicted by itself instead assumes that it is predicted entirely by another observation after some parametric delay. It can be defined mathematically as follow,

\begin{equation} 
    D_{t} \sim \mathrm{NB}\left(\omega_{(t \mod 7)} \alpha \sum_{\tau = 0}^{30} \xi(\tau | \mu, \sigma) C_{t-\tau},  \phi \right)
\end{equation}

with the following priors,

\begin{align}
    \frac{\omega}{7} &\sim \mathrm{Dirichlet}(1, 1, 1, 1, 1, 1, 1) \\
    \alpha &\sim \mathcal{N}(0.01, 0.02) \\
    \xi &\sim \mathcal{LN}(\mu, \sigma) \\
    \mu &\sim \mathcal{N}(2.5, 0.5) \\
\sigma &\sim \mathcal{N}(0.47, 0.2) \\
\phi &\sim \frac{1}{\sqrt{\mathcal{N}(0, 1)}}
\end{align}


with $\alpha$, $\mu$, $\sigma$, and $\phi$ truncated to be greater than 0 and with $\xi$ normalised such that $\sum_{\tau = 0}^{30} \xi(\tau | \mu, \sigma) = 1$. 

### Model fitting

Both models were implemented using the `EpiNow2` R package (version 1.3.3) [@epinow2]. Each forecast target was fit independently for each model using Markov-chain Monte Carlo (MCMC) in stan [@rstan]. A minimum of 4 chains were used with a warmup of 250 samples for the renewal equation based model and 1000 samples for the convolution model. 2000 samples total post warmup were used for the renewal equation model and 4000 samples for the convolution model. Different settings were chosen for each model to optimise compute time contigent on convergence. Convergence was assessed using the R hat diagnostic [@rstan]. For the convolution model forecast the case forecast from the renewal equation model was used in place of observed cases beyond the forecast horizon using 1000 posterior samples. 12 weeks of data was used for both models though only 3 weeks of data were included in the likelihood for the convolution model.


### Additional figures and tables

#### Aggregate forecasts by location

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/aggregate-performance-2-weeks-locations-all.png)
*Figure S1. Visualisation of aggregate performance metrics across locations. A: mean weighted interval score (WIS) across horizons. B: median WIS. C: Absolute error of the median forecast. D: Standard deviation of the WIS. E: Sharpness (higher values mean greater dispersion of the forecast). F: Bias, i.e. general tendency to over- or underpredict. Values are between -1 (complete underprediction) and 1 (complete overprediction) and 0 ideally. G: Empirical coverage of the 50% prediction intervals. F: Empirical coverage of the 90% prediction intervals.*

#### Daily forecasts
![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/daily_truth.png)
*Figure S2. Visualisation of daily report data. Issue with this is that it isn't data as of then, but as of now.*

#### Table with scores 3-4 weeks ahead

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table_scores_4_ahead.png)

*Table S3: Scores for three and four week ahead forecasts (cut to three significant digits and rounded). Numbers in brackets show the metrics relative to the hub ensemble. WIS is the mean weighted interval score (lower values ar better), WIS - median and WIS - sd give the median and standard deviation of all scores achieved by a model. Sharpness, overprediction and underprediction together some up to the weighted interval score. Bias (between -1 and 1, 0 is ideal) represents the general average tendency of a model to over- or underpredict. 50% and 90%-coverage are the percentage of observed values that fell within the 50% and 90% prediction intervals of a model.*

#### Visualisation of scores and forecasts 1, 3, 4 weeks ahead

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/figure-forecasts-1.png) 

*Figure S4. A, C: Visualisation of one week ahead forecasts against the true observed values. The shape indicates whether there has been a monotonic increase or decrease over the last two weeks leading up to a given data point, or an unclear trend. Forecasts that aren't scored (because there was no complete set of death forecasts available) are greyed out. 
B, D: Visualisation of corresponding WIS. The shape indicates whether the trend was rising, falling or unclear at the date when the corresponding forecast was made (i.e. two weeks earlier, which leads to a shift of two weeks when compared to panels A and C).*

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/figure-forecasts-3.png) 

*Figure S5. A, C:Visualisation of three week ahead forecasts against the true observed values. The shape indicates whether there has been a monotonic increase or decrease over the last two weeks leading up to a given data point, or an unclear trend. Forecasts that aren't scored (because there was no complete set of death forecasts available) are greyed out. 
B, D: Visualisation of corresponding WIS. The shape indicates whether the trend was rising, falling or unclear at the date when the corresponding forecast was made (i.e. two weeks earlier, which leads to a shift of two weeks when compared to panels A and C).*

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/figure-forecasts-4.png) 

*Figure S6. A, C: Visualisation of four week ahead forecasts against the true observed values. The shape indicates whether there has been a monotonic increase or decrease over the last two weeks leading up to a given data point, or an unclear trend. Forecasts that aren't scored (because there was no complete set of death forecasts available) are greyed out. 
B, D: Visualisation of corresponding WIS. The shape indicates whether the trend was rising, falling or unclear at the date when the corresponding forecast was made (i.e. two weeks earlier, which leads to a shift of two weeks when compared to panels A and C).*


#### Distribution of scores 1, 3, 4 week

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/distribution_scores_wis-1.png)
*Figure S7. A: Distribution of weighted interval scores (smaller is better) for one week ahead forecasts of the different models and forecast targets. B: Distribution of WIS separate by country. C: Distribution of WIS in different phases of the epidemic. 
Phases are classified according to whether the two weeks prior to the date when a forecast was made showed a consistent trend.*

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/distribution_scores_wis-3.png)
*Figure S8. A: Distribution of weighted interval scores (smaller is better) for three week ahead forecasts of the different models and forecast targets. B: Distribution of WIS separate by country. C: Distribution of WIS in different phases of the epidemic. 
Phases are classified according to whether the two weeks prior to the date when a forecast was made showed a consistent trend.*


![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/distribution_scores_wis-4.png)
*Figure S9. A: Distribution of weighted interval scores (smaller is better) for four week ahead forecasts of the different models and forecast targets. B: Distribution of WIS separate by country. C: Distribution of WIS in different phases of the epidemic. 
Phases are classified according to whether the two weeks prior to the date when a forecast was made showed a consistent trend.*


<!--
#### Distribution of scores at different forecast horizons

MAYBE DELETE THAT FIGURE ALTOGETHER?

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/scores_horizons.png)

*Figure S10. Distribution of weighted interval scores achieved by the models at different horizons. Mean performance (black circles) was generally worse than median performance (black squares), implying that the distribution is skewed and suffers from outliers where models make predictions far away from the true observed values.*
**Maybe make an 'overall' panel as well**
--> 


![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/distribution_bias_phases.png)
*Figure S11. Distribution of bias values for all models in different phases of the epidemic.*

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/wis-components.png)
*Figure S12. Relative contributions of sharpness, over- and underprediction to the overall weighted interval score achieved by a model in different phases of the epidemic. Note that the uncertainty of the baseline model depends on the variation of observed differences in the past and is therefore naturally hihger in an unclear phase.*



#### Contributions to the hub ensemble
![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table_median-ensemble_scores_2_ahead.png)
*Table S13. Summarised scores for one and two week ahead predictions of the forecast hub median ensemble with and without the crowd forecasts and the renewal model included*


![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table_median-ensemble_scores_4_ahead.png)
*Table S14. Summarised scores for three and four week ahead predictions of the forecast hub median ensemble with and without the crowd forecasts and the renewal model included*

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/ensemble-members.png)
*Figure S15. Number of models that were included in the hub ensemble, including our own models. December 21th and December 28th 2020 were not included in the offical forecast hub evaluation period and therefore not all groups continued to submit models for those dates. The renewal model was not included on the 28th of December 2020 due to technical reasons that resulted in a belated submission.*


![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/ensemble-with-and-without-crowd.png)
*Figure S16. Median predictions of the crowd forecast, the median ensemble without the crowd forecast and the median ensemble with the crowd forecast included, but not the renewal model*


![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/ensemble-with-and-without-renewal.png)
*Figure S17. Median predictions of the renewal model, the median ensemble without the renewal model and the median ensemble with the renewal model included, but not the crowd forecasts*

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/ensemble-with-and-without-both.png)
*Figure Figure S18. Median predictions of the renewal model the crwod forecasts, the median ensemble without the two models and the median ensemble with both the crowd forecast and the renewal model*





## References
