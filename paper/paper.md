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


## Abstract

#### Background

Model based forecasts have played an important role in shaping public policy throughout the Covid-19 pandemic. The models, in turn, have been tweaked and shaped by human judgement. Any model forecast is therefore a mix between the researcher's subjective opinion and mechanistic model assumptions. 

#### Methods

To discern these two components we looked at forecasts Covid-19 case and death numbers we submitted to the German and Polish Forecast Hub between October 2020 until February 2021. Crowd sourced human forecasts were compared against a naive baseline model, against predictions by an untuned epidemiological model from the same working group, as well as against the ensemble of all predictions submitted to the hub by other research institutions. 

#### Results

Human forecasts clearly outperformed the untunted model as well as the Forecast Hub ensemble on case predictions one to four weeks ahead into the future (20%, 12%, 19%, and 30% relative improvement over the ensemble of Forecast Hub submissions excluding our contributions). On death forecasts, crowd predictions performed worse (7%, 26%, 29%, and 17% difference to the Forecast Hub ensemble excluding our contributions). The untuned epidemiological model performed on average worse than other models for most targets, but a simple convolution of cases on a delay distribution was able to predict deaths relatively well. Our contributions noticeably improved the German and Polish Forecast Hub ensemble on cases (20%, 10%, 7%, and 9% improvement through our contributions on one to four week ahead case forecasts) and had a neutral or even slightly negative impact on deaths (6%, -2%, -4%, and -5% change in performance due to our models).

#### Conclusions

Expert opinion can provide valuable insight and possibly outperforms models at predicting future case numbers, as humans can make use of information, e.g. about potential future policy interventions, not directly available to models. Computer models, however, have an advantage when predicting lagged quantities such as deaths, which are generally better predictable using mechanistic epidemiological relations like the delay between current case numbers and future deaths. Individual models can make positive contributions to an ensemble even if they individually perform worse than the pre-existing ensemble without them. 


## Introduction

The COVID-19 pandemic has resulted in an increase of interest in infectious disease forecasting, and the evaluation of these forecasts. Single model forecasts [@fergusonReportImpactNonpharmaceutical2020; @IHMEpaper] were impactful on policy decisions early in the pandemic despite previous work having shown that relying on a single model can lead to less accurate forecasts than decisions based on multiple approaches [@yamanaSuperensembleForecastsDengue2016; @gneitingWeatherForecastingEnsemble2005]. Since then several collaborations have sought to improve Covid-19 forecasting by eliciting submissions from a large number of research teams and collecting them in forecast hubs in the United Kingdom [@funkShorttermForecastsInform2020], in the United States of America [@esteecramerCOVID19ForecastHub2020; @cramerEvaluationIndividualEnsemble2021], and in Germany and Poland [@bracherShorttermForecastingCOVID192021]. Whilst all of these efforts have successfully delivered more accurate forecasts to policy makers compared to individual forecasting efforts they have struggled to unpick what leads to good Covid-19 forecasts [@cramerEvaluationIndividualEnsemble2021; @bracherShorttermForecastingCOVID192021; @funkShorttermForecastsInform2020]. 

This has been partly driven by the complexity of the models used to produce the constituent forecasts but also because of the level of expert intervention in most forecasting methods over time, and in response to changes in the pandemic. These issues can be decoupled by separating infectious disease forecasting into "automatic" model derived forecasts and human elicitation forecasts (from now on referred to as crowd forecasts). Model based forecasts have a rich history and have been growing in popularity over the last decade [@mcgowanCollaborativeEffortsForecast2019; @johanssonOpenChallengeAdvance2019; @viboudRAPIDDEbolaForecasting2018; @funkAssessingPerformanceRealtime2019]. However, such model based forecasts that are submitted by researchers usually change over time in response to percieved performance, changes in the underlying infectious disease processes or for other reasons. It is therefore unsusual for "automated" real-time forecasts (as opposed to retrospective forecasts) to be evaluated alongside these. A variety of human expert elicitation as well as crowd forecasting projects exist [@mcandrewAggregatingPredictionsExperts2021; @metaculusPreliminaryLookMetaculus2020; @tetlockForecastingTournamentsTools2014; @atanasovDistillingWisdomCrowds2016]. However, these crowd forecasts usually follow a different format than the ones provided by traditional forecasting models or take on different questions. Unlike other projects the crowd forecasts we develop here have been specifically designed to be comparable to model based forecasts. 


In this work, we evaluate two contrasting forecasting approaches that simplify and synthesise some of the previous work on evaluating model based forecasts as well as crowd forecasts. The first approach we analyse is a crowd forecast, where expert and non-expert opinion is combined into a single forecast of cases and deaths in target locations. This can be seen to represent modellers' interventions in forecasts but in a model agnostic format. In the second approach, we use two recently developed short term forecasting methods that make minimal epidemiological assumptions of how notifications are generated over time coupled with a robust observation model. These models were then not tuned throughout the submission period in order to make a comparison to opinion derived forecasts possible. All of these forecasts were submitted to the German and Polish Forecast Hub over 21 weeks from the 12th October 2020 to March 1st 2021 and combined, along with other forecasts, into an ensemble used by policy makers as well as being independently evaluated by the research group running the German and Polish Forecast Hub.

## Methods

### Data sources

Data on test positive cases and deaths linked to Covid-19 were provided by the organisers of the German and Polish forecast hub [@bracherShorttermForecastingCOVID192021]. Until December 14th 2020 these data were sourced from the European Centre for Disease Control (ECDC) [@DownloadHistoricalData2020a]. After ECDC stopped publishing daily data, observations were sourced from the Robert Koch Institute (RKI) for the remainder of the submission period [@RKICoronavirusSARSCoV2a]. These data are subject to reporting artefacts (such as a retrospective case reporting in Poland on the 24th November [@RozbieznosciStatystykachKoronawirusa0100]), changes in reporting over time and variation in testing regimes (e.g. in Germany from the 11th of November on [@aerzteblattSARSCoV2DiagnostikRKIPasst2020]). 

Line list data used to inform the delay from symptom onset to test postive case report or death in the model based forecasts was sourced from (cite public linelist) with data available up to June (check exact date). Population data at the national and state level in Germany and Poland used in the model based forecasts was sourced from (source for population data). 
 
### Forecasts

#### Model based forecasts

We used two models from the `EpiNow2` R package (version 1.3.3) as our baseline model based forecasts [@epinow2]. These were chosen for their relative simplicity, attention to modelling the observation model of the forecast targets, and their grounding in simplistic epidemiological assumptions. The first of these models, which was used to forecast both test positive cases and deaths, used the renewal equation [@coriNewFrameworkSoftware2013a] and an approximate Gaussian process [@approxGP] to estimate the effective reproduction number over time for latent infections and then convolved these infections to the target observation using data based delay distributions [@epinow2; @doiCovid19TemporalVariation; @EvaluatingUseReproduction]. The second model, which was only used to forecast deaths, assumed that deaths could be modelled using a scaling parameter, a convolution of test positive cases with a distribution that described the delay from case report to death, and a negative binomial observation model with a day of the week effect [@epinow2]. Both models are described in detail in the supplementary information. 

Each forecast target was fit independently for each model using Markov-chain Monte Carlo (MCMC) in stan [@rstan]. A minimum of 4 chains were used with a warmup of 250 samples for the renewal equation based model and 1000 samples for the convolution model. 2000 samples total post warmup were used for the renewal equation model and 4000 samples for the convolution model. Different settings were chosen for each model to optimise compute time contigent on convergence. Convergence was assessed using the R hat diagnostic [@rstan]. For the convolution model forecast the case forecast from the renewal equation model was used in place of observed cases beyond the forecast horizon using 1000 posterior samples. 


#### Crowd forecast

Crowd forecasts were created by ensembling forecasts submitted by individual participants. Participants were recruited mostly within the Centre of Mathematical Modeling of Infectious Diseases at the London School of Hygiene and Tropical Medicine, but participants were also invited personally or via social media to submit predictions. 

##### Collection

Participants were asked to make forecasts of Covid-19 cases and deaths over a four week ahead horizon using a web application (https://cmmid-lshtm.shinyapps.io/crowd-forecast/). The application was built using the `shiny` and `golem` R packages [@shiny; @golem] and is available in the `crowdforecastr` R package [@crowdforecastr]. To make a forecast in the application participants could select a predictive distribution, with the default being log-normal, and adjust the median and the width of the uncertainty by either interacting with a figure showing their forecast or providing numerical values. The baseline shown was a repetition of the last known observation with constant uncertainty around it computed as the standard deviation of the last four observed log changes in forecasts. We required that participants submitted forecasts with uncertainty that increased over time. Our interface also allowed participants to view the observed data, and their forecasts, using a log scale and presented additional contextual COVID-19 data sourced from ourworldindata.org [@COVID19DataExplorer]. These data included notifications of both test positive COVID-19 cases and COVID-19 linked deaths, case fatality rates and the number of COVID-19 tests though the availability of the data evolved over the study period. 


##### Processing

Forecasts were stored in a Google Sheet and downloaded, cleaned and processed every week for submission. If a forecaster had submitted multiple predictions for a single target, only the latest submission was kept. Some personal information (like the exact time of the forecast) was removed. Information on the chosen distribution as well as the parameters for median and width were used to obtain a set of 22 quantiles plus the median from that distribution. Forecasts from all forecasters were then aggregated using an unweighted quantile-wise mean. Inclusion was decided based on the authors' ad-hoc assessment of the validity of the forecast submission. Almost all forecasts were kept if they weren't clearly a result of someone experimenting with the app. 


### Forecast submission
<!--
- When we submitted
- What we submitted
- How we submitted (Docker, R, R package, CRON, Azure).
-->
Both computer generated forecasts and crowd preditions were submitted every Tuesday 3pm. The model based forecasts used data up to the previous Sunday. Human forecasters were allowed to make forecasts until Tuesday 12am, but were asked to use only information up to Monday. All orecasts were submitted in a quantile-based format with 22 quantiles plus the median prediction for a one to four week ahead horizon. 

All forecasts were processed in a Docker container that ran automated cron jobs to ensure a reproducible environment. All code and tools necessary to generate the forecasts and make a forecast submission are available in the covid.german.forecasts R package. 

All forecasts are available here: https://github.com/epiforecasts/covid.german.forecasts

### Forecast Hub ensemble

Our forecasts were compared against the ensemble of all other models submitted to the German and Polish Forecast Hub. For the purpose of this analysis and unless otherwise specified, 'ensemble' means the median ensemble of all predictions submitted to the forecast hub, excluding our models. The median ensemble was chosen as it is the default ensemble shown in the visualisations of the German and Polish Forecast Hub. The version of the ensemble that excluded our models was created retrospectively and kindly provided by the German and Polish Forecast Hub organisers. 

### Statistical analysis
Forecasts were analysed by visual inspection as well formal model evaluation. Formal model evaluation was based on the weighted interval score (WIS) [@bracherEvaluatingEpidemicForecasts2021], absolute error, a bias metric to capture a general tendency to over- or underpredict, as well as empirical coverage of the 50% and 90% prediction intervals. In addition to the WIS we also calculated WIS relative to the baseline by dividing through the WIS achieved by the baseline model. If not otherwise specified, scores were computed per forecast date, target and country and aggregated using the mean. All scores were calculated using the `scoringutils` package [@scoringutils] in R. For case forecasts, all forecasts from October 12th 2020 until March 1st 2021 were taken into account. For deaths, we only scored forecasts made after the 14th December, as no fully operational version of the convolution model was available before. 


For the main analysis we focused on one and especially two week ahead predictions, as predictions beyond this horizon are often unreliable due to rapidly changing conditions [@bracherShorttermForecastingCOVID192021]. Forecast scores for other horizons are given in the Appendix. As an additional analysis we stratified the time series into three different categories for every forecast date. Depending on whether numbers were monotonically rising or falling over the last two weeks prior to a given forecast date (i.e. whether a given data point and the last two points before formed a monotonically rising or falling line), the epidemic was categorised as either 'increasing', 'decreasing' or 'unclear'. Differences of less than 5% relative to the week before were treated as zero, meaning they were interpreted as consistent with either classification. 

## Results

### Forecast submission

From October 12 2020 until the December 7 2020, only the renewal model and the crowd forecasts were submitted. Starting with the 7th of December, the convolution model was added. As the first submission suffered from a software bug, we excluded it from this analysis. March 1st was chosen as the last submission date, as we switched to submitting our forecasts for Germany and Poland to the European Forecast Hub on the 8th of March (which involved changing the data source). From January 11 2021 on we also submitted model based forecasts on a regional level. These forecasts were not further analysed as we could not produce corresponding crowd forecasts due to the large number of locations and limited researcher time and ability to reach out to enough potential forecasters. Model based forecasts used the same approach throughout the forecast period with no changes to the methodology or setting. Interventions that applied at different points throughout the study period were therefore not explicitly modelled. Human forecasters were of course able to adapt their forecasts to current or likely future interventions. 

A total number of 31 participants have submitted forecasts (although duplicates cannot be ruled out). The median number of forecasters was 6, the minimum 2 and the maximum 9 for a single forecast target. Participation rose steadily and peaked in February, before declining again towards the end of the study period. Motivating forecasters to contribute regularly proved challenging, especially given that the majority of our participants were from the UK and had no real connection to either Germany or Poland. The mean number of submissions from an individual forecaster was 4.7, but the median number was only one - most participants unfortunately dropped out after their first submission. Only two participants submitted a forecast every single week. To increase usability, the interface and its visual appearance was continuously tweaked and improved and additional information, e.g. from ourworldindata.org was added. The core functionality, however, remained unchanged. 

### Comparison of forecast performance

Summarised scores for one and two weak ahead forecasts are given in Table 1 (and scores for three and four weeks ahead in Table XX in the supplementary information), and a visualisation of two week ahead forecasts and weighted interval scores relative to the baseline for the different models over time is shown in Figure 1. 

#### Case forecasts

Human forecasts clearly outperformed the Forecast Hub ensemble on case predictions one to four weeks ahead into the future (20%, 12%, 19%, and 30% relative improvement over the ensemble of Forecast Hub submissions excluding our contributions). The renewal model performed on average noticeably worse than the ensemble (with a difference in average WIS of 0%, 39%, 51%, and 64% for one to four week ahead forecasts). At two weeks ahead, only the renewal failed to beat the baseline on average. For all models, mean weighted interval score was markedly higher than median interval score, implying that the distribution is skewed and influenced by outliers were predictions were far away from the observed values. This was especially true for the renewal model, where the median prediction was better than the median baseline forecast, but the average was worse. With an average sharpness (smaller means less dispersed) of 3660 for two week ahead predictions (2680 for one week ahead predictions), the crowd forecasts were sharpest. For one-week ahead forecasts the baseline model was on average the least sharp, but had constant uncertainty across horizons. At greater horizons, the renewal model and the hub ensemble were less sharp, with the uncertainty of the renewal model growing quickest (to 19500 at a 4 week ahead horizon compared to 12200 for the hub ensemble and 5970 for the crowd forecast). At one and two week ahead horizons both the crowd forecasts and the hub-ensemble were unbiased. The bias metric that captures an overall tendency of a model to over- or underpredict on a scale from -1 (complete underprediction) to 1 (complete overprediction) showed values of -0.01 and -0.01 for crowd forecasts one and two weeks ahead and -0.04 and -0.03 for the hub ensemble. The Baseline model had a small tendency to underpredict (implying that cases went up slightly more often than not), whereas the renewal model had a clear tendency to overpredict (bias values of 0.18 and 0.17). This is also reflected in the average penalties for over- und underprediction in Table 1. On average, the median forecast of the crowd forecast was closest to the true observed value and showed the smallest absolute error. All models showed poor calibration with respect to the empirical coverage of the 50% and 90% prediction intervals. Notably, only 55% of observations fell within the 90% prediction interval of the crowd forecast. Calibration was best for the Hub-ensemble, which covered 69% of the observed values with its 90% prediction intervals at a 2 week ahead horizon. 

#### Death forecasts

With regard to deaths, the ensemble clearly outperformed all other models, including the crowd forecasts. The average WIS for the crowd forecasts was 7% and 26% higher than that of the hub ensemble. Average performance of the renewal model was 20% and 80% worse than the hub ensemble for one and two week ahead predictions. All models except the renewal model were able to noticeably beat the baseline model on average for one and two week ahead forecasts. The convolution model that estimates deaths as a convolution of the cases predicted by the renewal model, did 3% and 22% worse than the hub ensemble at one and two week horizons. The crowd forecasts were again sharper (less dispersed) than the other models, except the convolution model which was slightly sharper at the two week ahead horizon. As with cases, uncertainty of forecasts from the renewal model grew rapidly with increasing forecast horizon. The hub-ensemble made nearly unbiased forecasts (with values of -0.04 and 0.01 for one and two week ahead predictions). The renewal model, which had a noticeable tendency to overpredict cases, was also nearly unbiased for deaths (with bias values of -0.07 and -0.02). The convolution model had a strong tendency to underpredict deaths, which decreased with increasing forecast horizon (with a bias value of -0.18 for one week ahead and a value of 0.01 for four week ahead predictions). The crowd forecast on average overpredicted deaths at all forecast horizons. The baseline forecast also, on average, overpredicted deaths implying that deaths went down more often than not. Calibration of death forecasts was generally better than for case forecasts. Especially the hub ensemble showed very good calibration at one and two weeks ahead with the empirical coverage of the 50% and 90% prediction intervals at or even above nominal coverage. Coverage the 50% predcition interval was slightly worse than for cases, but coverage at the 90% prediction interval was improved, reaching 79% and 75% one and two weaks ahead. Coverage for the convolution model was comparable to the crowd forecasts, while coverage of the renewal model was slightly better at 50% prediction intervals and slightly worse at 90% prediction intervals. 

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table_scores_2_ahead.png)

*Table 1: Scores for one and two week ahead forecasts (cut to three significant digits and rounded). WIS is the mean weighted interval score (lower values ar better), WIS - median and WIS - sd give the median and standard deviation of all scores achieved by a model. WIS - rel. is the average WIS relative to the average WIS achieved by the baseline model. Sharpness, overprediction and underprediction together some up to the weighted interval score. Bias (between -1 and 1, 0 is ideal) represents the general average tendency of a model to over- or underpredict. 50% and 90%-coverage are the percentage of observed values that fell within the 50% and 90% prediction intervals of a model.*

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/figure-forecasts-2.png) 

*Figure 1. A, C: Visualisation of 2 week ahead forecasts against the true observed values. The shape indicates whether there has been a monotonic increase or decrease over the last two weeks leading up to a given data point, or an unclear trend. Forecasts that aren't scored (because there was no complete set of death forecasts available) are greyed out. 
B, D: Visualisation of corresponding WIS relative to the baseline that can be thought of as ‘improvement over the baseline model’. The shape indicates whether the trend was rising, falling or unclear at the date when the corresponding forecast was made (i.e. two weeks earlier, which leads to a shift of two weeks when compared to panels A and C)*


#### The distribution of scores

*- This section needs more work and a clearer description of the distribution of scores in different phases. However, I need to get a break from this to be able think clearly about it again -*

Figure 2A shows the distribution of WIS scores for a two week ahead horizon achieved by each model (The distribution of WIS relative to the baseline is shown in Figure XX in the supplementary information). The distribution of WIS scores for different forecast horizons can be seen in Figure XX in the SI, a summary can be seen in Table XX in the Appendix. 

The crowd forecasts tended to have the lowest variance in scores (standard deviation of 7600 and 16800 for cases one and two week ahead, 322 and 450 for deaths), while scores for the renewal equation are most dispersed (11900 and 34200 for cases, 407 and 681 for deaths). The hub ensemble, baseline and convolution where usually in between, with performance of the convolution model being almost as variying as the performance of the renewal model for deaths. Notably, the baseline model had the lowest variability in scores (and also the lowest mean and median score) for cases at a four week ahead horizon. 
The WIS distribution was skewed for all models, with the median being higher than the mean. This was most extreme for the renewal model, and usually least extreme for the crowd forecasts. Whether or not a model was 'better than another model' therefore depends on whether one cares about mean performance or median performance. For one and two weeks ahead, for example, the median forecast from the renewal model beat the baseline, while the mean forecast did not. 
<!-- not sure this is true
For the renewal and the convolution model, performance relative to the baseline varied across countries, where the median forecast of the two models beat the baseline in one country, but not the other, as can be seen in Figure 2B. Interestingly, the convolution model performed well on deaths in Germany, even though the renewal model performed poorly. Conversely, the convolution model performed poorly on deaths in Poland even though the renewal had performed relatively well. 
-->
Figure 2C shows the distribution of scores in different phases of the epidemic and Table 3 shows accompanying summarised scores. Across different targets, countries and phases the WIS for the renewal model had the strongest tendency towards a bimodal distribution, meaning that performance was often either very good or very bad. 

<!--
- Renewal and Crowd forecast good when cases are rising (maybe: renewal model is good at modelling exponential growth and humans are good at adapting to turning points)
- hard to identify a clear pattern
-->

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/distribution_scores_wis.png)
*Figure 2. A: Estimated density distribution of weighted interval scores (smaller is better) for two week ahead forecasts of the different models and forecast targets. Points indicate single data points. B: Distribution of WIS separate by country. C: Distribution of WIS in different phases of the epidemic. 
Phases are classified according to whether the two weeks prior to the date when a forecast was made show a consistent trend.*

--- 

<!--
![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table-Cases-DecreasingPhase-2.png)             |  ![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table-Cases-UnclearPhase-2.png) | ![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table-Cases-IncreasingPhase-2.png)
:-------------------------:|:-------------------------:|:-------------------------:
![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table-Deaths-DecreasingPhase-2.png)  |  ![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table-Deaths-UnclearPhase-2.png) | ![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table-Deaths-IncreasingPhase-2.png)
*Table 2. Summarised scores in the different phases of the epidemic. Do we want sd and median of the WIS here and if yes, do we want it for the table above as well?*
-->

#### Contribution to the Forecast Hub

The crowd forecasts and the renewal model affected the median ensemble mostly positively (especially for cases) - both individually and together. This positive contribution from a model often even occured when the ensemble without that model was better than the model itself. Scores from the ensembles with and without the two models included can be seen in Table 3 for one and two week ahead forecasts and in the Table XX in the SI for three and four week ahead forecasts. A pot with the number of ensemble member models over time can be seen in Figure XX in the SI. The median number of models included in the ensemble was 7, with an increase over time. 

For case forecasts, including both models improved the average WIS of the forecast hub median ensemble for one week ahead predictions by 20% from 8770 to 7000. Each of the models alone achieved a reduction of around 10%. For two weak ahead case forecasts, the average WIS was reduced from 18300 to 17500 by the including the renewal model alone, to 16900 by including the crowd forecasts alone and to 16500 with both models included. Note that the renewal model performed, on average, worse than the hub ensemble without it for two week ahead case forecasts (its WIS was 25600). For three and four weeks ahead, inclusion of the renewal model slightly deteriorated ensemble predictions on average, while the crowd forecasts made a positive contribution at all forecast horizons. 
For death forecasts, including both models improved average WIS from 248 to 235 for one week ahead forecasts. For two week ahead forecasts, both models deteriorated performance, albeit only slightly, from an average WIS of 292 to 296 with both models included. At three and four weeks ahead, crowd forecasts made a neutral (three weeks ahead) or positive contribution (four weeks ahead), while the renewal model made the overall performance of the ensemble slightly worse. 

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table_median-ensemble_scores_2_ahead.png)
*Table 3. Summarised scores for the one and two week ahead predictions of the forecast hub median ensemble with and without the crowd forecasts and the renewal model included*


### Decomposition of the weighted interval score
*- This could be more concise - need to think more about in which direction this should be going and what we're getting out of it. Comparison to the Figure in the SI that plots a distribution of bias values should be interesting to contrast absolute contributions with an overall tendency to over- or underpredict -*

Relative contributions to the weighted interval scores can be seen in Figure 3. In general, a large share of penalties from over- and underprediction, as opposed to sharpness, tends to be associated with poor overall performance, because this often occurs when a forecast is far away from the true observed value, regardless of the sharpness of the forecast. While Figure 3 shows the absolute penalties from over- und underprediction, Figure XX in the SI shows the distribution of bias values for the models, which is limited between -1 and 1 and therefore gives a better understanding of the general tendency to over- or underpredict. 
The relative WIS composition varied greatly between models and changed noticeably depending on the phase of the epidemic. When cases and deaths had been falling over the previous two weeks, the baseline model tended to overpredict future cases and deaths, implying that numbers usually continued to fall when they had been falling before. In decreasing phases both the renewal model and the hub ensemble tended to underpredict case numbers, forecasting cases to fall lower than they actually did). For death forecasts in decreasing phases, sharpness (i.e. forecast uncertainty) played a larger relaive role in overall WIS scores. In increasing phases (especially for cases), underprediction dominated the overall WIS score for the baseline model, implying that usually numbers tended to rise further in these situations. All models, (with the exception of the convolution model and to a certain extent case forecasts from the crowd), overpredicted both future cases and deaths when numbers had been rising before. In unclear phases, over- and underprediction penalties were about equal for the case forecasts from all models. For deaths, however, all models severely underpredicted future deaths in situations where there was no clear trend previously, implying that deaths often rose in these situations. 

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/wis-components.png)
*Figure 3. Relative contributions of sharpness, over- and underprediction to the overall weighted interval score achieved by a model in different phases of the epidemic. Note that the uncertainty of the baseline model depends on the variation of observed differences in the past and is therefore naturally hihger in an unclear phase.*

## Discussion

### Summary

Any model forecasts are informed by mechanistic model assumptions as well as the researcher’s subjective opinion that shapes they way a model is tweaked and tuned. Expert judgement alone (in the form of aggregated crowd forecasts) can make a valuable contribution to Covid-19 forecasting. With regards to cases our crowd forecasts clearly outperformed the untuned renewal model and performed on average as well as or better than a large ensemble of model derived, and expert tuned, forecasts submitted to the German and Polish Forecast Hub. This suggests that expert judgement may often play a large and important role even in forecast models that on the surface derive their predictive ability from epidemiological theory. Given that the majority of our crowd participants had little connection to either Germany or Poland, local domain knowledege and expertise of our forecasters was limited. This, together with the low number of participants, suggests that the performance of the crowd forecast ensemble we observed is likely closer to the lower than to the upper bound of what could reasonably be expected of an expert forecast ensemble. 

It interesting to note that crowd forecasts (especially for cases) were very good in terms of the absolute error, but relatively poor in terms of calibration (represented by the empirical coverage of the 50% and 90% prediction intervals). This suggests that human forecasters were able to predict the general trend reasonably well, but failed to calibrate their own uncertainty and were often overly confident in their predictions. This overconfidence of expert predictions has been noted before [@recchiaHowWellDid2021]. 
<!-- not sure about this: 
The visualisation of forecasts in Figure 1 suggests that human forecasters may be slightly better than model based forecasts to predict changes in trend. In November, for example, they were able to predict a slowdown in the number of cases in Germany and Poland more accurately than the model based forecasts. 
-->
The poorer relative performance of the crowd forecasts for deaths suggest that humans may generally be at a relative disadvantage there. Future cases depend on a large degree on countless factors that are very hard to model (e.g. future policy interventions, adherence to rules, seasonal effects) but that can potentially be taken into account by humans. For deaths, there is exists a more direct relationship to past observed case numbers which can to a certain exent be captured using epidemiological insight and mechanistic modelling. This makes deaths in general easier to predict [@cramerEvaluationIndividualEnsemble2021; @bracherShorttermForecastingCOVID192021], but puts model-based forecasts that can quantify these epidemiological relations at an even greater advantage. It is interesting to note that the convolution model outperformed the renewal model on deaths, implying that it was easier to model deaths as a convolution of predicted case numbers, instead of generating a separate death forecast based on an Rt value estimated from deaths. In general, the convolution model performed surprisingly well given that the case predictions from the renewal model, on which it relied, were often not good. In the future, we intend to look at how a combination of crowd forecasts and the convolution model performs, seeing whether the relative strengths of both human insight and mechanistic modelling can be combined.

<!-- - 
BITS AND PIECES TO BE TIDIED UP
Especially when case numbers were rising, there was a large danger of overshooting and missing a change in trend. This danger is asymmetric when looking at numbers on a linear scale instead of a log scale, as numbers are bound by zero, but can grow very large. 

To a certain extent, underpredicting may be interpretable as 'hedging against' or incorporating the fact that a sudden downturn may be possible. Given that underpredictions made up a large part of penalties incurred during increasing phases this implies that either humans were not well prepared to forecast exponential growth in cases or systematically overestimated the probably of a sudden downturn. For deaths it was even more striking that all models consistently overpredicted deaths, maybe missing a change in the observed case fatality rate due to changes in testing. It is interesting to see that the pattern of the relative share of the WIS components for human forecasters most closely resembles the pattern of the baseline model. 


At short time horizons untuned models designed to perform well in real-time more rapidly adapted to state changes but this was offset but reduced long term improvement. 
--> 
<!--
- Optimising a forecast to a specific time horizon relies on understanding the use case of those consuming the forecasts.

The renewal model had a general tendency to overpredict that was especially pronounced in situations where case numbers were growing on the date of the forecast. 

The renewal model which used daily data was good at predicting exponential growth or decline and adapted well to changes in trend. It performed well at short horizons, but suffered at times from severe overprediction and a general tendency to deteriorate over longer forecast horizons. Whether or not that is acceptable depends on the use case of those who are consuming the forecasts. While the German and Polish Hub asked for one to four week ahead predictions it is not clear what forecast horizon the predictions should be optimised for (and evaluated against) without further context. 


--> 




### Strengths and Weaknesses

<!-- *When writing this layer strengths and limitations together. Start with a strength and then for every limitation counter with a strength* -->

Our work has robustly assessed the performance of crowd-sourced human predictions and model based forecasts in a realistic real-time setting. Forecasts reflect unbiased predictive performance at the time and could not be tuned in response to reporting artifacts after submission as they were registered with an independent research organisation. Our evaluation followed a methodology pre-registered by the German and Polish Forecast Hub [@bracherComparisonCombinationRealtime2020] which makes sure our results can be fairly compared against official forecast hub evaluations. 

While the methodology did not change for the Renewal model, the Convolution model and the Baseline model, this continuity is not given for the crowd forecasts and the hub ensemble model. Comparability of crowd forecasts at different time points is hampered by the low number of participants we were able to recruit initially and the fact that participants kept joining or dropping out. Similarly, the composition of the Hub ensemble changed over time as did many of the individual models contributing forecasts to the Forecast Hub. To mitigate this, a wide range of potential confounding factors, like different time periods, were considered to ensure the robustness of the obtained results. 

We showed that even a small number of expert forecasters without a lot of a prior local domain expertise can make good Covid-19 forecasts. Due to the small number of participants we were not able to easily compare the performance of experts versus non-experts. It is, however, plausible to assume that an ensemble of a larger number of experts who have genuine knowledge not only in epidemiology but also in the country for which they make a forecast, would show improved performance. In that sense our crowd forecasts established a baseline that is likely at the lower end of what can reasonably achieved with human expert forecasting. The fact that the interface demanded some understanding of distributions and time series made it hard to recruit participants who didn't already have a background in either some quantitative field or epidemiology. On the other hand, the setup allowed us to obtain a full predictive distribution instead of only a limited set of quantiles. This made it possible to compare expert forecasts directly against computer generated forecasts using the same evaluation tools. While forecasts performed well for a limited set of targets the setup is not easily scalable to a large set of prediction targets. Using R shiny also came with some limitations in terms of usability. On the other hand, setting the platform up as a public R package means that it can easily be adapted and re-used for future forecasting projects. 

**Strengths and weaknesses in the context of the literature**

<!--*Same structure as for the previous section.*-->

Other efforts have attempted to compare forecasts of Covid-19 submitted by different research groups. A comparison of model performance in the US [@cramerEvaluationIndividualEnsemble2021] had a much larger data set of forecast targets and models. On the one hand, this allowed for more robust statistical inference. On the other hand, a large number of models and targets makes it more difficult to draw conclusions that go beyond a ranking of models. Models in the US Forecast Hub essentially had to be treated as a black box, as not all details were known (or collecting them was infeasible). In addition no human forecasts directly entered the models analysed in @cramerEvaluationIndividualEnsemble2021. Focusing on a small number of known models and forecast targets allowed us to obtain a deeper understanding of how models and human forecasts performed. @bracherShorttermForecastingCOVID192021 published an evaluation of all forecasts submitted to the German and Polish Forecast Hub. Their study was pre-registered, ensuring full transparency of the results obtained. They also included different interventions in their analysis and the effect they may have had on scores. This was not feasible for us to do, as especially a list of Polish interventions was not readily available to us. In addition it is not entirely clear what constitutes an 'intervention' and there are many researcher degrees of freedom involved. Instead, we decided to categorise the time series in 'rising', 'falling' and 'unclear' and therefore implicitly looked at whether models were able to foresee future interventions or other factors that may lead to a change in trend. 

Other crowd forecasting projects like the Delphi project [no citation found], the expert elicitation efforts led by Thomas McAndrew [@mcandrewAggregatingPredictionsExperts2021], Metaculus [@metaculusPreliminaryLookMetaculus2020] or Good Judgement Open [@tetlockForecastingTournamentsTools2014] often had a far greater number of participants. However, their forecasts are not directly comparable to model based forecasts. The pool of participants is also much different from the modellers who usually submit predictions to Covid-19 Forecast Hubs. In our case many of our forecasters came from the same modelling group that also submitted model based forecasts, allowing us to more clearly disentangle the contributions of human judgement and model derived insights. As our user interface was slightly less easy to use than a simply survey, raising the bar to entry may have positively affected the quality of our forecasts, compared to what was found e.g. by @recchiaHowWellDid2021.

<!--
- Compare to US hub work (they had lots more data and many more models however there data source was very challenging and their models were all essentially black boxes to one degree or another making drawing conclusions difficult).
- Compare to Germany hub work (similar as above + different focus). Mention prespecified which is good.
- Compare to other model comparison efforts that don't include crowd forecasting.
- Compare to other crowd forecasting efforts. Examples to include: Delphi (as most comparable) and then binary prediction projects.
-->

**Future work**

The work presented here can and should be expanded in various ways. For the purpose of this paper, crowd forecasts were treated as a a single model, where in reality they are are an ensemble of very different individual opinions. There are various ways in which these opinions could be combined into a single forecast that we intend to explore in the future, for example weighted ensembles that give forecasters more weight who performed well in the past. Investigating *why* successful forecasters predicted numbers to rise or fall is also likely to yield insights that can be useful for policy makers. Another promising research project is a forecast that combines human opinion with epidemiological modelling. In the UK we are currently asking humans to predict Rt instead of cases and deaths directly. From the projected Rt trajectory we simulate cases as well as deaths which means that humans can focus on the overall trend, while models deal with the mechanistic details. We hope to improve human death forecasts substantially using this method. 

<!--
- Optimise the model based forecasts into a single submission for the ECDC based hub
- Compare the model based forecasts used here to simple time series based approaches and evaluate using weighted ensembles. Mention we are currently doing this in the US. 
- Expand crowd forecasting work to more targets and continue to improve/evaluate interface.
- Explore other crowd forecasting methods (i.e Rt based if not including here).
-->

**Conclusions**

Crowd (or expert) forecasts can perform en par or even better than a large ensemble of epidemiological models and is a viable approach for a manageable set of forecasting targets. Human forecasters are good at predicting general trends, even if they tend to be overly confident in their predictions. Our research suggests that purely theory-derived forecasts are not optimal and that models may benefit from human intervention and fine-tuning. Epidemiological models are most at an advantage when there are a large number of targets to predict or when forecasting lagged quantities such as deaths, as these models can more easily cope with large amounts of data and quantify known relations between parameters. Models can make a positive contribution to an existing ensemble even in situation where the model performs worse than the existing ensemble. Future work should investigate how forecasts can be improved, for example by means of weighted ensembles, and by looking into forecasting methods that combine expert opinion and mechanistic modelling. 






# Todos

- rethink formulations: are we a crowd forecast or an expert forecast? 
- Numbering all the tables
- Unsure whether we should report on 3-4 week ahead predictions in the text or not? 
- Maybe add a sentence somewhere that what forecast horizon you care about is a trade-off and that that needs to be determined by the user
- Go through all citations and clean formatting
- Maybe think of a sexier title? Comparing human predictions against epidemiological model forecasts of Covid-19 in Germany and Poland
- Think about the baseline model: We're only using it in Figure 1 and nowhere else and also aren't really talking about it. We should maybe either talk more about it or remove it?
- maybe look more into the composition of forecasters - e.g. we had some Germans, but no one from Poland
- I didn't really find a citation for the Delphi Crowdcast project. Could site this website? https://delphi.cmu.edu/crowdcast/ but that is just the url of the app...Ich wieß nich
- maybe add something about the European Hub
- Maybe address the fact that rankings between models aren't consistent across horizons --> what does that tell us? 
- Rework paragraph about the WIS decomposition
- Rework paragraph about the different phases
- Maybe reword introduction slightly (The beginnin of the second paragraph could be clearer)
- At the moment, we don't really make use of the fact that we know the EpiNow2 model in the interpretation. Essentially, we're still treating it as a black box and not delivering on our promise to 'unpick what leads to good Covid-19 forecasts'. Is there a way that we can improve the interpretation of the renewal model results? 
- Recheck numbers after they have changed with the new ensemble
- Spelling: COVID or Covid? 
- Mention somewhere that the Convolution model never made it into the hub ensemble
- Plots
    - Redo order for all plots with phases: decreasing, unclear, increasing
    - Maybe change color maps
    - Add missing plots to Appendixperfomed
    - Add overall panel for the one plot in the Appendix


--- 

# Supplementary information

## Forecast models

### Effective Reproduction number model

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
    \alpha &\sim \mathcal{N}(0.25, 0.05) \\https://hackmd.io/eF0CIZFERbqHpWnQ57AYsQ?edit
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


## Daily forecasts
![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/daily_truth.png)
*Visualisation of daily report data. Issue with this is that it isn't data os of then, but as of now.*


## Forecast scores 3-4 weeks ahead

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table_scores_4_ahead.png)

*Table XX: Scores for three and four weeks ahead forecasts (cut to three significant digits and rounded). WIS is the mean weighted interval score (lower values ar better), WIS - median and WIS - sd give the median and standard deviation of all scores achieved by a model. WIS - rel. is the average WIS relative to the average WIS achieved by the baseline model. Sharpness, overprediction and underprediction together some up to the weighted interval score. Bias (between -1 and 1, 0 is ideal) represents the general average tendency of a model to over- or underpredict. 50% and 90%-coverage are the percentage of observed values that fell within the 50% and 90% prediction intervals of a model.*

## Visualisation of scores and forecasts 1, 3, 4 weeks ahead

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/figure-forecasts-1.png) 

*Figure XX. A, C: Visualisation of one week ahead forecasts against the true observed values. The shape indicates whether there has been a monotonic increase or decrease over the last two weeks leading up to a given data point, or an unclear trend. Forecasts that aren't scored (because there was no complete set of death forecasts available) are greyed out. 
B, D: Visualisation of corresponding scaled relative skill scores for the forecasts shown on the left. Scaled relative skill scores can be thought of as ‘improvement over the baseline model’ (see Methods for details). The shape indicates whether the trend was rising, falling or unclear at the date when the corresponding forecast was made (i.e. two weeks earlier)*

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/figure-forecasts-3.png) 

*Figure XX. A, C: Visualisation of three week ahead forecasts against the true observed values. The shape indicates whether there has been a monotonic increase or decrease over the last two weeks leading up to a given data point, or an unclear trend. Forecasts that aren't scored (because there was no complete set of death forecasts available) are greyed out. 
B, D: Visualisation of corresponding scaled relative skill scores for the forecasts shown on the left. Scaled relative skill scores can be thought of as ‘improvement over the baseline model’ (see Methods for details). The shape indicates whether the trend was rising, falling or unclear at the date when the corresponding forecast was made (i.e. two weeks earlier)*

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/figure-forecasts-4.png) 

*Figure XX. A, C: Visualisation of four week ahead forecasts against the true observed values. The shape indicates whether there has been a monotonic increase or decrease over the last two weeks leading up to a given data point, or an unclear trend. Forecasts that aren't scored (because there was no complete set of death forecasts available) are greyed out. 
B, D: Visualisation of corresponding scaled relative skill scores for the forecasts shown on the left. Scaled relative skill scores can be thought of as ‘improvement over the baseline model’ (see Methods for details). The shape indicates whether the trend was rising, falling or unclear at the date when the corresponding forecast was made (i.e. two weeks earlier)*

## Distribution of scores 1, 3, 4 week

**Still Missing**

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/distribution_scores_wis.png)

*Figure 2. A: Estimated density distribution of weighted interval scores (smaller is better) for two week ahead forecasts of the different models and forecast targets. Points indicate single data points. B: Distribution of WIS separate by country. C: Distribution of WIS in different phases of the epidemic. 
Phases are classified according to whether the two weeks prior to the date when a forecast was made show a consistent trend.*

## Distriution of scores at different forecast horizons

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/scores_horizons.png)

*Figure 3. Distribution of weighted interval scores achieved by the models at different horizons. Mean performance (black circles) was generally worse than median performance (black squares), implying that the distribution is skewed and suffers from outliers where models make predictions far away from the true observed values.*
**Maybe make an 'overall' panel as well**


## Contribution to the hub ensemble

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



## Over- and underprediction


![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/distribution_bias_phases.png)
*Figure XX. Distribution of bias values for all models in different phases of the epidemic.*



# References
