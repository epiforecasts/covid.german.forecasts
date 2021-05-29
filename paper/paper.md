---
title: Evaluating crowd sourced forecasts of Covid-19 against epidemiological model forecasts in Germany and Poland
output: html_document
bibliography: references.bib  
---

# Evaluating crowd sourced forecasts of Covid-19 against epidemiological model forecasts in Germany and Poland

*Nikos Bosse, Sam Abbott, and Sebastian Funk*

Target journal: elife


## Abstract

#### Background

Model based forecasts have played an important role in shaping public policy throughout the Covid-19 pandemic. The models, in turn, have been tweaked and shaped by human judgement. Any model forecast is therefore a mix between the researcher's subjective opinion and mechanistic model assumptions. 

#### Methods

To discern these two components we looked at forecasts Covid-19 case and death numbers submitted to the German and Polish Forecast Hub between October 2020 until February 2021. Crowd sourced human forecasts were compared against predictions by an untuned epidemiological baseline model from the same working group, as well as against the ensemble of all predictions submitted to the hub. 


#### Results

Human forecasts outperformed models (including the Forecast Hub ensemble) on case forecasts, but not on death forecasts. They performed best over longer time horizons and around Christmas where reporting artifacts had a major influence on the data. 

#### Conclusions

Expert opinion outperforms models at predicting long-term trends and when dealing with data anomalies, as humans can make use of information, e.g. about potential future policy interventions, not directly available to models. Computer models, however, have an edge in situations like XY and when modelling epidemiological parameters like the delay between current case numbers and future deaths. 

## Introduction

The COVID-19 pandemic has resulted in an increase of interest in infectious disease forecasting, and the evaluation of these forecasts. Single model forecasts (cite Imperial, cite US version of Imperial) were impactful on policy decisions early in the pandemic despite previous work having shown that relying on a single model can lead to less accurate forecasts than decisions based on multiple approaches (cite whatever hubs cite for this). Since then several collaborations have sort to evaluate Covid-19 forecasts in the United Kingdom (cite Seb), in the United States of America (cite Reich), and in Germany and Poland (cite Johannes). Whilst all of these efforts have successfully delivered more accurate forecasts to policy makers compared to individual forecasters efforts they have struggled to unpick what leads to good Covid-19 forecasts (cite all hub evaluations again). 

This has been partly driven by the complexity of the models used to produce the constituent forecasts but also because of the level of expert intervention in most forecasting methods over time, and in response to changes in the pandemic. These issues can be decoupled by separating infectious disease forecasting into "automatic" model derived forecasts and human elicitation forecasts (from now on referred to as crowd forecasts). Model based forecasts have a rich history and have been growing in popularity over the last decade (cite influenza hub, cite dengue challenge, cite something else). However, it is unsusual for "automated" real-time forecasts (as opposed to retrospective forecasts) to be evaluated with forecasts usually being submitted by individual researchers and therefore liable to change over time in response to percieved performance, changes in the underlying infectious disease processes or for other reasons. A variety of human expert elicitation as well as crowd forecasting projects exist [Cite Tom McAndrew, Metaculus, GoodJudgement, PredicIt]. However, these forecasts usually follow a different format than the ones provided by traditional forecasting models or take on different questions. Unlike these projects the crowd forecasts we develop here have been specifically designed to be comparable to model based forecasts. 


In this work, we evaluate two constrasting forecasting approaches that simplify and synthesise some these themes. The first of these approaches is a crowd forecast, where expert and non-expert opinion is combined into a single forecast of cases and deaths in target locations. This represents modellers interventions in forecasts but in a model agnostic format. In the second approach, we use two recently developed short term forecasting methods that make minimal epidemiological assumptions of how notifications are generated over time coupled with a robust observation model. These models were then not tuned throughout the submission period in order to make a comparison to opinion derived forecasts possible. All of these forecasts were submitted to the German/Poland forecast hub over 21 weeks from the 12th October 2020 to March 1st 2021 and combined, along with other forecasts, into an ensemble used by policy makers as well as being independently evaluated by the research group running the German/Poland forecasting hub.

## Methods

### Data sources

Data on test positive cases and deaths linked to Covid-19 were provided by the organisers of the German and Polish forecast hub (P/L hub) (cite German/Poland hub). Until XXX these data were sourced from the European Centre for Disease Control(ECDC) (cite ECDC data). After ECDC stopped publishing daily data, observations were sourced from the Robert Koch Institute (RKI) for the remainder of the submission period. These data are subject to reporting artefacts (such as a retrospective case reporting in Poland on the 24th November (cite and list artefacts)), changes in reporting over time and variation in testing regimes.

Line list data used to inform the delay from symptom onset to test postive case report or death in the model based forecasts was sourced from (cite public linelist) with data available up to June (check exact date). Population data at the national and state level in Germany and Poland used in the model based forecasts was sourced from (source for population data). 
 
### Forecasts

#### Model based forecasts

We used two models from the `EpiNow2` R package (version 1.3.3) as our baseline model based forecasts [@epinow2]. These were chosen for their relative simplicity, attention to modelling the observation model of the forecast targets, and their grounding in simplistic epidemiological assumptions. The first of these models, which was used to forecast both test positive cases and deaths, used the renewal equation (cite EpiEstim paper) and an approximate Gaussian process [@approxGP] to estimate the effective reproduction number over time for latent infections and then convolved these infections to the target observation using data based delay distributions (cite EpiNow2, website and Kaths paper). The second model, which was only used to forecast deaths, assumed that deaths could be modelled using a scaling parameter, a convolution of test positive cases with a distribution that described the delay from case report to death, and a negative binomial observation model with a day of the week effect [@epinow2]. Both models are described in detail in the supplementary information. 

Each forecast target was fit independently for each model using Markov-chain Monte Carlo (MCMC) in stan [@rstan]. A minimum of 4 chains were used with a warmup of 250 samples for the renewal equation based model and 1000 samples for the convolution model. 2000 samples total post warmup were used for the renewal equation model and 4000 samples of the convolution model. Different settings were chosen for each model to optimise compute time contigent on convergence. Convergence was assessed using the R hat diagnostic [@rstan]. For the convolution model forecast the case forecast from the renewal equation model was used in place of observed cases beyond the forecast horizon using 1000 posterior samples. 


#### Crowd forecast

Crowd forecasts were created by ensembling forecasts submitted by individual participants. Participants were recruited mostly within the Centre of Mathematical Modeling of Infectious Diseases at the London School of Hygiene and Tropical Medicine, but participants were also invited personally or via social media to submit predictions. 

##### Collection

Participants were asked to make forecasts of Covid-19 cases and deaths over a four week ahead horizon using a web application (https://cmmid-lshtm.shinyapps.io/crowd-forecast/). The application was built using the shiny R package (cite shiny) and is available in the `crowdforecastr` R package (cite crowdforecastr). Forecasts could be made until Tuesday, but forecasters were only allowed to use data available up until Monday. To make a forecast in the application participants could select a predictive distribution, with the default being log-normal, and adjust the median and the width of the uncertainty by either interacting with a figure showing their forecast or providing numerical values. The baseline shown was a repetition of the last known observation with constant uncertainty around it computed as the standard deviation of the last four observed log changes in forecasts. We required that participants submitted forecasts with uncertainty that increased over time. Our interface also allowed participants to view the observed data, and their forecasts, using a log scale and presented additional contextual COVID-19 data sourced from our world in data (cite ourworldindata). These data included notifications of both test positive COVID-19 cases and COVID-19 linked deaths, case fatality rates and the number of COVID-19 tests though the availability of the data evolved over the study period. 


##### Processing

Forecasts were downloaded, cleaned and processed every week for submission. If a forecaster had submitted multiple predictions for a single target, only the latest submission was kept. Some personal information (like the exact time of the forecast) was removed. Information on the chosen distribution as well as the parameters for median and width were used to obtain a set of 23 quantiles from that distribution. Forecasts from all eligible forecasters were then aggregated using an unweighted quantile-wise mean (citation mean ensembles are good). In the beginning, inclusion was decided based on the authors' ad-hoc assessment of the validitiy of the forecast submission. Almost all forecasts were kept if they weren't clearly a result of someone experimenting with the app. From XX we based inclusion on the criterion that a forecaster submitted forecasts for at least two targets. 


### Forecast submission
<!--
- When we submitted
- What we submitted
- How we submitted (Docker, R, R package, CRON, Azure).
-->
Both computer generated forecasts and crowd preditions were submitted every Tuesday 3pm (using data up until Monday) for a one to four week ahead horizon. Forecasts were submitted in a quantile-based formats with 22 quantiles plus the median prediction.

All forecasts were processed in a Docker container that ran automated cron jobs to ensure a reproducible environment. All code and tools necessary to generate the forecasts and make a forecast submission are available in the covid.german.forecasts R package. 

All forecasts are available here: https://github.com/epiforecasts/covid.german.forecasts


### Statistical analysis
Forecasts were analysed by visual inspection as well formal model evaluation. Forecast submissions were visualised by forecast time horizon and compared to the ensemble of all forecasts from the German and Polish Forecast Hub. Formal model evaluation was based on the weighted interval score (wis) [@bracherEvaluatingEpidemicForecasts2021], as well as empirical coverage of the 50% and 90% prediction intervals. The WIS was used to compute a relative skill value (smaller means better) that takes all possible pairwise comparisons between models into account and therefore provides a relative model ranking. Relative skill for all models was divided by the relative skill achieved by the baseline model to obtain a scaled relative skill value. All scores were calculated using the `scoringutils` package [@scoringutils] in R. For case forecasts, all forecasts from October 12th 2020 until March 1st 2021 were taken into account. For deaths, we only score forecasts made after the 14th December, as no fully operational version of the convolution model was available before. 


For the main analysis we focused on two week ahead predictions, as this is the horizon commonly used by the Forecast Hubs (cite Hubs). Forecasts more than two weeks are often very unreliable as conditions change rapidly. Forecast scores for other horizons are given in the Appendix. Scores were aggregated by target type (deaths or cases) in the table, but plotted for every country separately to give a more detailed overview. In addition we also stratified the time series into three different categories for every forecast date. Depending on whether numbers were monotonically rising or falling over the last two weeks prior to a given forecast date (i.e. whether the last three points formed a monotonically rising or falling line), the epidemic was categorised as either 'increasing', 'decreasing' or 'unclear'. Differences of less than 5% relative to the week before were treated as zero in the classification, meaning they were interpreted as consistent with either classification. 


<!--

- Discuss outperformance at 4 week horizon with all 1 and 2 weeks repeated in the SI. Discuss performance in relation to the German/Poland hub ensemble.
- Split forecast time period into different states (stable/unstable?) and report short term model performance. 
- Pull out intervention dates in germany/poland which models did well/badly around these (we need to know the intervention dates to do this).
-->

## Results

### Forecast submission

<!--*This should be two concise paragraphs one about the first few points and one about the crowd forecast collection.* -->

Forecasts were submitted every Tuesday, 3pm. The model based forecasts used data up to the previous Sunday. Human forecasters were allowed to make forecasts on Tuesday, but were asked to use only information up to Monday. Before the 7th of December, only the renewal model and the crowd forecasts were submitted. Starting with the 7th of December, the convolution model was added. As the first submission suffered from a software bug, we excluded it from this analysis. March 1st was chosen as the last submission date, as we switched to submitting to the European Forecast Hub on the 8th of March (which involved changing the data source). From the XXth on we also submitted model based forecasts on a regional level. These forecasts were not further analysed as we could not produce corresponding crowd forecasts due to the large number of locations. Model based forecasts used the same approach throughout the forecast period with no changes to the methodology or setting. Interventions that applied at different points throughout the study period were therefore not explicitly modelled. Human forecasters were of course able to adapt their forecasts to current or likely future interventions. 

A total number of 31 participants have submitted forecasts (although duplicates cannot be ruled out). The median number of forecasters was 6, the minimum 2 and the maximum 9 for a single forecast target. Participation rose steadily and peaked in February, before declining again towards the end of the study period. Motivating forecasters to contribute regularly proved challenging. The mean number of submissions from an individual forecaster was 4.7, but the median number was only one - most participants unfortunately dropped out after their first submission. Only two participants submitted a forecast every single week. To increase usability, the interface and its visual appearance was continuously tweaked and improved and additional information, e.g. from ourworldindata.org was added. The core functionality, however, remained unchanged. 

### Comparison of forecast performance

Summarised scores are given in Table 1, and a visualisation of two week ahead forecasts and scaled relative skill scores for the different models over time is shown in Figure 1. 
Model performance was quite varied across time and prediction targets. For cases, crowd forecasts were able to perfom en par with the ensemble of all forecasts from the Hub. The renewal model performed noticeably worse, owing to a few predictions that were far away from the observed data. The renewal model had a general tendency to overpredict that was especially pronounced in situations where case numbers were growing on the date of the forecast. Figure 3 illustrates the relative contributions of sharpness, over- and underprediction to the WIS in different situations. All models showed poor calibration with respect to the empirical coverage of the 50% and 90% prediction intervals. Notably, only 55% of observations fell within the 90% prediction interval of the crowd forecast. It was, however, best in terms of the absolute error, suggesting that human forecasters were able to predict the general trend reasonably well, but failed to calibrate their own uncertainty and were overly confident in their predictions. The visualisation of forecasts in Figure 1 suggests that human forecasters may be slightly better than model based forecasts to predict changes in trend. In November, for example, they were able to predict a slowdown in the number of cases in Germany and Poland more accurately than the model based forecasts. 

With regards to death forecasts, the ensemble clearly outperformed all other models and overall made unbiased and well calibrated predictions. The poorer relative performance of the crowd forecasts suggest that humans may be at a relative disadvantage when it comes to forecasting deaths. Future cases depend on a large degree on countless factors that are very hard to model (e.g. future policy interventions, adherence to rules, seasonal effects) but that can potentially be taken into account by humans. For deaths, the direct relationship to past case numbers is more pronounced and can to a certain exent be captured using epidemiological modelling. From an epidemiological point of view, deaths, for example, can simplistically be understood as a convolution of case numbers on some delay distribution multiplied by a case fatality rate. These relationships are hard for humans to untangle and quantify who can only rely on their intuition to make predictions. On deaths, the convolution model outperformed the Renewal model, implying that it was easier to model deaths as a convolution of case numbers, instead of estimating a separate death forecast based on a separate Rt value. It should be noted that the convolution model based its predictions on the forecast of the renewal model, which often struggled with case predictions. Its performance therefore needs to be interpreted accordingly. Possible future research could look into how a convolution model performs that is based on a more accurate case forecast. 

--- 

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/table_scores_2_ahead.png)

*Table 1: Scores for 2 week ahead forecasts (cut to three significant digits and rounded). Skill is the scaled relative skill, a measure of relative performance with respect to the baseline model (lower values are better). Sharpness, overprediction and underprediction together some up to the weighted interval score (WIS, lower values are better). Bias (between -1 and 1, 0 is ideal) represents the general average tendency of a model to over- or underpredict. 50% and 90%-coverage are the percentage of observed values that fell within the 50% and 90% prediction intervals of a model.*

---

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/figure-forecasts-2.png) 

*Figure 1. A, C: Visualisation of 2 week ahead forecasts against the true observed values. The shape indicates whether there has been a monotonic increase or decrease over the last two weeks leading up to a given data point, or an unclear trend. Forecasts that aren't scored (because there was no complete set of death forecasts available) are greyed out. 
B, D: Visualisation of corresponding scaled relative skill scores for the forecasts shown on the left. Scaled relative skill scores can be thought of as ‘improvement over the baseline model’ (see Methods for details). The shape indicates whether the trend was rising, falling or unclear at the date when the corresponding forecast was made (i.e. two weeks earlier)*

---

Figure 2 shows the distribution of scaled relative skill scores achieved by each model. The renewal model had by far the largest variance in terms of its performance. Across different targets, countries and phases the distirbution of its scores tended to be bimodal, meaning that forecasts tend to be either really good, clearly outperforming the baseline and often most other models, but also frequently very far off. Among all models, the crowd forecasting model had the lowest variance in scores and performed most consistently. 

As is illustrated in panel A in Figure 2, median forecasts from all models beat the baseline on the two week horizon displayed here (note that as shown in Table 1 mean forecasts from the renewal model performed worse than the baseline). Models outperformed the baseline more easily for death forecasts than for case forecasts, reinforcing the notion that deaths are easier to forecast than cases (cite US Hub, cite GM Hub). 

For the renewal and the convolution model, performance varied more stronlgy across countries than for the ensemble and crowd forecast model. Interestingly, the convolution model performed well on deaths in Germany, even though the model performed poorly. Conversely, it performed poorly on deaths in Poland even though the renewal had performed relatively well. 

**Interpretation of the different phases - Discuss with Sam** 
- Renewal and Crowd forecast good when cases are rising (maybe: renewal model is good at modelling exponential growth and humans are good at adapting to turning points)
- hard to identify a clear pattern



![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/distribution_scores.png)
*Figure 2. A: Overall distribution of the scaled relative skill scores (smaller is better) for the different models and forecast targets. The vertical black line at x = 1 represents the baseline model. B: Distribution of scaled relative skill scores separate by country. C: Distribution of scaled relative skill in different phases of the epidemic. 
Phases are classified according to whether the two weeks prior to the date when a forecast was made show a consistent trend.*

---

All forecasts deteriorated with increasing forecast horizons, albeit at different rates. Figure 3 shows the distribution of the WIS for all models, locations and horizons. While mean and median performance was generally good for the renewal model one week ahead, it quickly deteriorated with increasing forecast horizon. 


![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/scores_horizons.png)

*Figure 3. Distribution of weighted interval scores achieved by the models at different horizons. Mean performance (black circles) was generally worse than median performance (black squares), implying that the distribution is skewed and suffers from outliers where models make predictions far away from the true observed values.*
**Maybe make an 'overall' panel as well**

---

Relative contributions to the weighted interval scores changed depending on the phase of the epidemic. Generally, models tended to underpredict when cases or deaths where increasing, and overprdict when cases and deaths were decreasing. Especially when case numbers are rising, there is a large danger of overshooting and missing a change in trend. This danger is asymmetric when looking at numbers on a linear scale instead of a log scale, as numbers are bound by zero, but can grow very large. To a certain extent, underpredicting may be interpretable as 'hedging against' or incorporating the fact that a sudden downturn may be possible. Given that underpredictions made up a large part of penalties incurred during increasing phases this implies that either humans were not well prepared to forecast exponential growth in cases or systematically overestimated the probably of a sudden downturn. For deaths it was even more striking that all models consistently overpredicted deaths, maybe missing a change in the observed case fatality rate due to changes in testing. It is interesting to see that the pattern of the relative share of the WIS components for human forecasters most closely resembles the pattern of the baseline model. 

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/wis-components.png)

*Figure 3. Relative contributions of sharpness, over- and underprediction to the overall weighted interval score achieved by a model in different phases of the epidemic. Note that the uncertainty of the baseline model depends on the variation of observed differences in the past and is therefore naturally hihger in an unclear phase.*

## Discussion

### Summary

Any model forecasts are informed by mechanistic model assumptions as well as the researcher’s subjective opinion that shapes they way a model is tweaked and tuned. Expert judgement alone (in the form of aggregated crowd forecasts) can make a valuable contribution to Covid-19 forecasting. Participants, however, were difficult to recruit. In addition, forecasting a lot of different targets is strenous for individual forecasters, limiting the number of possible forecast targets. We therefore could not produce crowd forecasts at the state level in either Poland or Germany due to a lack of researcher time and our ability to reach out to potential forecasters. The fact that most participants were from the UK and had no connection to Germany or Poland made motivating them even more difficult. It also severely limited the amount of domain knowledge and expertise amoung our forecasters. This suggests that the performance of the crowd forecast ensemble is likely closer to the lower than to the upper bound of what could reasonably be expected of an expert forecast. 

With regards to cases our crowd forecasts clearly outperformed the untuned renewal model and performed on average as well as or better than a large ensemble of model derived, and expert tuned, forecasts. This suggests (*does it?*) that expert judgement may often play a large and important role even in forecast models that on the surface derive their predictive ability from epidemiological theory. Humans are relatively good at foreseeing trends in case numbers which are influenced by many factors that are hard to model (such as likely future interventions, adherence to policy interventions or unknown seasonal effects). However, humans tended to be even more overconfident in their predictions than model based forecasts. 

Compared to human forecasters, mechanistic models are at a relative advantage when predicting deaths from Covid-19. The ensemble forecast clearly outperformed crowd forecasts and provided unbiased and well calibrated predictions. Notably, a simple model that assumed that cases were a convolution of deaths performed well compared to other approaches. The convolution model outperformed expert opinion at short time horizons and did relatively well at longer time horizons. This was the case even though the convolution model was based on case forecasts from the renewal model which often performed poorly. 

The renewal model which used daily data was good at predicting exponential growth or decline and adapted well to changes in trend. It performed well at short horizons, but suffered at times from severe overprediction and a general tendency to detiorate over longer forecast horizons. Whether or not that is acceptable depends on the use case of those who are consuming the forecasts. While the German and Polish Hub asked for one to four week ahead predictions it is not clear what forecast horizon the predictions should be optimised for (and evaluated against) without further context. 

<!-- - At short time horizons untuned models designed to perform well in real-time more rapidly adapted to state changes but this was offset but reduced long term improvement. 
--> 
<!--
- Optimising a forecast to a specific time horizon relies on understanding the use case of those consuming the forecasts.
-->


### Strengths and Weaknesses

*When writing this layer strengths and limitations together. Start with a strength and then for every limitation counter with a strength*

Our work has robustly assessed the performance of crowd-sourced human predictions and model based forecasts in a realistic real-time setting. Forecasts reflect unbiased predictive performance at the time and could not be tuned in response to reporting artifacts after submission as they were registered with an independent research organisation. Our evaluation followed a methodoloy pre-registered by the German and Polish Forecast Hub [@pre-registration] which makes sure our results can be fairly compared against offical forecast hub evaluations. 

While the methodology did not change for the Renewal model, the Convolution model and the Baseline model, this continuity is not given for the crowd forecasts and the hub ensemble model. Comparability of crowd forecasts at different time points is hampered by the low number of participants we were able to recruit initially and the fact that participants kept joining or dropping out. Similarly, the composition of the Hub ensemble changed over time as did many of the individual models contributing forecasts to the Forecast Hub. To mitigate this, a wide range of potential confounding factors, like different time periods, were considered to ensure the robustness of the obtained results. 

Human forecasters performed surprisingly well in spite of the low number of contributors and the limited knowledge of the situation in Germany and Poland among participants. Due to the small number of participants we were not able to easily compare the performance of experts versus non-experts. It is, however, plausible to assume that an ensemble of a larger number of experts who have genuine knowledge not only in epidemiology but also in the country for which they make a forecast, would show improved performance. In that sense our crowd forecasts established a baseline that is likely at the lower end of what can reasonably achieved with human expert forecasting. The fact that the interface demanded some understanding of distributions and time series made it hard to recruit participants who didn't already have a background in either some quantitative field or epidemiology. On the other hand, the setup allowed us to obtain a full predictive distribution instead of only a limited set of quantiles. This made it possible to compare expert forecasts directly against computer generated forecasts using the same evaluation tools. While forecasts performed well for a limited set of targets the setup is not easily scalable to a large set of prediction targets. Using R shiny also came with some limitations in terms of usability. On the other hand, setting the platform up as a public R package means that it can easily be adapted and re-used for future forecasting projects. 

**Strengths and weaknesses in the context of the literature**

*Same structure as for the previous section.*

Other efforts have attempted to compare forecasts of Covid-19 submitted by different research group. A comparison of model performance in the US (cite Cramer et al.) had a much larger data set of forecast targets and models. On the one hand, this allowed for more robust statistical inference. On the other hand, a large number of models and targets makes it more difficult to draw conclusions that go beyond a ranking of models. Models in the US Forecast Hub essentially had to be treated as a black box, as not all details were known (or collecting them was infeasible). In addition no human forecasts directly entered the models analysed in [Cramer et al] Focusing on a small number of known models and forecast targets allowed us to obtain a deeper understanding of how models and human forecasts performed. [Cite Johannes] published an evaluation of all forecasts submitted to the German and Polish Forecast Hub. Their study was pre-registered, ensuring full transparency of the results obtained. They also included different interventions in their analysis and the effect they may have had on scores. This was not feasible for us to do, as especially a list of Polish interventions was not readily available to us. In addition it is not entirely clear what constitutes an 'intervention' and there are many researcher degrees of freedom involved. Instead, we decided to categorise the time series in 'rising', 'falling' and 'unclear' and therefore implicitly looked at whether models were able to foresee future interventions or other factors that may lead to a change in trend. 

Other crowd forecasting projects like the [cite DELPHI] project, Metaculus or Good Judgement Open arguably have a far greater numbe of participants. However, their forecasts are not directly comparable to model based forecasts. The pool of participants is also much different from the modellers who usually submit predictions to Covid-19 Forecast Hubs. In our case many of our forecasters came from the same modelling group that also submitted model based forecasts, allowing us to more clearly disentangle the contributions of human judgement and model derived insights. 

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

- Crowd forecasts outperform models with simplistic epidemiology derived assumptions at longer time horizons. 
- At shorter time horizons performance is more comparable, especially when forecasting deaths when a model that simplistically assumes that deaths are scaled convolution of cases performs relatively well.






# Todo

## Decisions and things to think about
- which dates, if any, do we want to exclude? Daily forecasts don't look too irregular, except for the spike of cases in Poland
- Can we recalculate the ensemble excluding our models? 
- Figure 2: maybe we don't want to stratify according to location? --> idea is that we don't do it for the table. We also don't really talk about particular interventions in Germany and Poland, so maybe it would make sense to stick with 'cases' and 'deaths' as the two distinct categories and avoid introducing more noise by stratifiying it according to country
- Same reasoning for Figure 3?
- For Figure 1 we might want to rearrange the plots such that the forecast is always above the score. I.e. have it
case case
score score
deaths deaths
score score
- maybe move Figure 3 to the Appendix?
- in general be clearer: are we a crowd forecast or an expert forecast? 
- maybe look more into the composition of forecasters - e.g. we had some Germans, but no one from Poland

## Actual todos


--- 

# Supplementary information

## Daily forecasts
![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/daily_truth.png)
*Visualisation of daily report data. Issue with this is that it isn't data os of then, but as of now.*
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

$\alpha$, $\mu$, $\sigma$, and $\phi$ were truncated to be greater than 0 and with $\xi$, and $w$ normalised to sum to 1. $GP_t$ is an approximate Hilbert space gaussian process as defined in [@approxGP] using a Matern 3/2 kernel using a boundary factor of 1.5 and 17 basis functions (20% of the number of days used in fitting). The lengthscale of the Gaussian process was given a log-normal prior with a mean of 21 days, and a standard deviation of 7 days truncated to be greater than 3 days and less than 60 days. The magnitude of the Gaussian process was assumed be normally distributed centred at 0 with a standard deviation of 0.1. The prior for the generation time was sourced from [@generationinterval] but refit using a log-normal incubation period with a mean of 5.2 days (SD 1.1) and SD of 1.52 days (SD 1.1) with this incubation period also being used as a prior [@incubationperiod] for $\xi_{O}. This resulted in a gamma distributed generation time with mean 3.6 days (standard deviation (SD) 0.7), and SD of 3.1 days (SD 0.8) for all estimates. We estimated the delay between symyptom onset and case report or death required to convolve latent infections to observations by fitting an integer adjusted log-normal distribution to 10 subsampled bootstraps of a public linelist for cases in Germany from April 2020 to June 2020 with each bootstrap using 1% or 1769 samples of the available data  [@kraemer2020epidemiological; @covidregionaldata] and combining the posteriors for the mean and standard deviation of the log-normal distribution [@epinow2; @rt-website; @kath; @rstan]. This resulted in a delay distribution from symptom onset to case report with a mean of XX and a standard deviation of XX and a delay distribution from sypmtom onset to death with a mean of XX and a standard deviation of XX.


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


## Distribution of WIS
--> maybe kick these
![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/distribution_scores_wis.png)
*This plot has wis instead of scaled relative skill*

![](https://raw.githubusercontent.com/epiforecasts/covid.german.forecasts/analysis/analysis/plots/distribution_scores_ae.png)
*same plot with absolute error*


