# Evaluating crowd sourced forecasts of Covid-19 against epidemiological model forecasts in Germany and Poland

*Nikos Bosse\*, Sam Abbott\*, and Sebastian Funk*

*\* contributed unequally*\*\*

\*\* *did they?*

Target journal: elife

Target completion of first draft: 26/03/2021

Target preprint date: 14/04/2021

## Abstract

**Background** 

**Methods**

**Results**

**Conclusions**


## Introduction

The COVID-19 pandemic has resulted in an increase of interest in infectious disease forecasting, and the evaluation of these forecasts. Single model forecasts (cite Imperial, cite US version of Imperial) were impactful on policy decisions early in the pandemic despite previous work having shown that relying on a single model can lead to less accurate forecasts than decisions based on multiple approaches (cite whatever hubs cite for this). Since then several collaborations have sort to evaluate Covid-19 forecasts in the United Kingdom (cite Seb), in the United States of America (cite Reich), and in Germany and Poland (cite Johannes). Whilst all of these efforts have successfully delivered more accurate forecasts to policy makers compared to individual forecasters efforts they have struggled to unpick what leads to good Covid-19 forecasts (cite all hub evaluations again). 

This has been partly driven by the complexity of the models used to produce the consituent forecasts but also because of the level of expert intervention in most forecasting methods over time, and in response to changes in the pandemic. These issues can be decoupled by separating infectious disease forecasting into "automatic" model derived forecasts and human elicitation forecasts (from now on referred to as crowd forecasts). Model based forecasts have a rich history and have been growing in popularity over the last decade (cite influenza hub, cite dengue challenge, cite something else). However, it is unsusual for "automated" real-time forecasts (as opposed to retrospective forecasts) to be evaluated with forecasts usually being submitted by individual researchers and therefore liable to change over time in response to percieved performance, changes in the underlying infectious disease processes or for other reasons. A variety of human expert elicitation as well as crowd forecasting projects exist [Cite Tom McAndrew, Metaculus, GoodJudgement, PredicIt]. However, these forecasts usually follow a different format than the ones provided by traditional forecasting models or take on different questions. Unlike these projects the crowd forecasts we develop here have been specifically designed to be comparable to model based forecasts. 


In this work, we evaluate two constrasting forecasting approaches that simplify and synthesis some these themes. The first of these approaches is a crowd forecast, where expert and non-expert opinion is synthesised into a single forecast of cases and deaths in target locations. This represents modellers interventions in forecasts but in a model agnostic format. In the second approach, we use two recently developed short term forecasting methods that make minimal epidemiological assumptions of how notifications are generated over time coupled with a robust observation model. These models were then not tuned throughout the submission period in order to make a comparison to opinion derived forecasts possible. All of these forecasts were submitted to the German/Poland forecast hub over XX weeks from the XX to the XX and combined, along with other forecasts, into an ensemble used by policy makers as well as being independently evaluated by the research group running the German/Poland forecasting hub.

## Methods

### Data sources

Data on test positive cases and deaths linked to Covid-19 were provided by the organisers of the German and Polish forecast hub (P/L hub) (cite German/Poland hub). For the first half of the evaluation period (XX to XX) these data were sourced from the European Centre for Disease Control(ECDC) (cite ECDC data) with data then being sourced frok the Robert Koch Institute (RKI) for the remainder of the submission period. These data are subject to reporting artefacts (such as a retrospective case reporting in Poland on the 24th November (cite artefacts)), changes in reporting over time and variation in testing regimes.

Linelist data used to inform the delay from symptom onset to test postive case report or death in the model based forecasts was sourced from (cite public linelist) with data available up to June (check exact date). Population data at the national and state level in Germany and Poland used in the model based forecasts was sourced from (source for population data). 
 
### Forecasts

#### Model based forecasts

We used two models from the `EpiNow2` R package (version 1.3.0) as our baseline model based forecasts [@epinow2]. These were chosen for their relatively simplisticty, attention to modelling the observation model of the forecast targets, and their grounding in epidemiological assumptions which allows for relatively easy interpretation of their performance. The first of these models, which was used to forecast both test positive cases and deaths, used the renewal equation (cite EpiEstim paper) to estimate the effective reproduction number over time of latent infections and then convolved these infections to the target observation used delay distributions (cite EpiNow2, website and Kaths paper). The second model, which was only used to forecast deaths, assumed that deaths could be modelled using a scaling parameter and a convolution of test positive cases with a distribution that described the delay from case report to death [@epinow2]. 

These were a renewal equation based model that estimates the effective reproduction number of latent infecitons that assumed that Rt was static from the forecast horizon onwards and a convolution and scaling model which also assumed that both the delay from cases to deaths and the  that was only used to forecast deaths from test positive cases
- Which models (outline)
- Define Rt
    - Mathematical outline
    - data used
    - priors
    - Summarise key choices
- Define convolution model
    - Mathematical outline
    - data used
    - priors
    - Summarise key choices

[`EpiNow2`](https://epiforecasts.io/EpiNow2/) is an exponential growth model that uses a time-varying Rt trajectory to predict latent infections, and then convolves these infections with estimated delays to observations, via a negative binomial model coupled with a day of the week effect. It makes limited assumptions and is not tuned to the specifities of Covid in Germany and Poland beyond epidemioligical details such as literature estimates of the generation time, incubation period and the populatin of each area. The method and underlying theory are under active development with more details available [here](https://epiforecasts.io/covid/methods).


#### Crowd forecast

Crowd forecasts were formed as an ensemble of crowd opinion. Participants were recruited mostly within the Centre of Mathematical Modeling of Infectious Diseases within the London School of Hygiene and Tropical Medicine, but participants were also invited personally or via social media to submit predictions. 

##### Collection

Participants were asked to make forecasts using a web application (https://cmmid-lshtm.shinyapps.io/crowd-forecast/) built using the shiny R package (cite shiny) and available in the `crowdforecaster` R package (cite crowdforecaster). In the application they could select a predictive distribution, with the default being log-normal, and adjust the median and the width of the uncertainty by either interacting with a figure showing their forecast or providing numerical values. The baseline shown was a repetition of the last known observation with some constant uncertainty around it based on changes observed in the data in the previous four weeks. We required that participants submitted forecasts with uncertainty that increased over time. Our interface also allowed users to view the observed data, and their forecasts, using a log scale and presented additional contextual COVID-19 data sourced from our world in data (cite ourworldindata). These data included notifications of both test positive COVID-19 cases and COVID-19 linked deaths, case fatality rates and the number of COVID-19 tests though the availability of this data evolved over the study period. 


##### Processing

Forecasts were downloaded, cleaned and processed every week for submission. If a forecaster had submitted multiple predictions for a single target, only the latest submission was kept. Some personal information (like the exact time of the forecast) was removed. Information on the chosen distribution as well as the parameters for median and width were used to obtain a set of 23 quantiles from that distribution. Forecasts from all eligible forecasters were then aggregated using an unweighted quantile-wise mean. In the beginning, inclusion was decided based on the authors' ad-hoc assessment of the validitiy of the forecast submission. Almost all forecasts were kept if they weren't clearly a result of someone experimenting with the app. From XX we based inclusion on the criterion that a forecaster submitted forecasts for at least two targets. 


### Forecast submission

- When we submitted
- What we submitted
- How we submitted (Docker, R, R package, CRON, Azure).

Forecasts were submitted every Tuesday (using data up until Monday) for a one to four week ahead horizon. Forecasts were in a quantile-based formats with 22 quantiles plus the median prediction. 

Forecasts are available here:


### Statistical analysis
Forecasts were analysed by visual inspection as well formal model evaluation. Forecast submissions were visualised by forecast time horizon and compared to the ensemble of all forecasts from the German and Polish Forecast Hub. To evaluate model performance more formally we used the weighted interval score (wis) [@bracherEvaluatingEpidemicForecasts2021], as well as empirical coverage of the 50% and 90% prediction intervals. In order to obtain a model ranking, relative skill was assessed based on pairwise comparisons between all possible combinations of models. Scores were calculated using the `scoringutils` package [@scoringutils] in R. Dates with known reporting issues were excluded a priori from the evaluation. 

- Summarised forecast scores are presented across different horions (focus on weeks 1 and 2 like German hub). 
- Discuss outperformance at 4 week horizon with all 1 and 2 weeks repeated in the SI. Discuss performance in relation to the German/Poland hub ensemble.
- Split forecast time period into different states (stable/unstable?) and report short term model performance. 
- Pull out intervention dates in germany/poland which models did well/badly around these (we need to know the intervention dates to do this).

## Results

### Forecast submission

*This should be two concise paragraphs one about the first few points and one about the crowd forecast collection.*
- Submitted every week (number of weeks and number of forecasts). Comment that model based forecasts were also submitted at region level but not further analysised here as we could not also produce this number of expert forecasts.
- Interventions applied at different points throughtout the study period but not explicitly modelled.
- Model based forecasts used the same approach throughout the forecast period with no changes to the methodology or setting apart from the introduction of the convolution based model for forecasting deaths on the.
- Had X number of expert forecasters on average with min of and max of. Some comment on regularity of forecasters. 
- Changes over time to the interface for expert forecasts with improvements throughout the study period and a steady increase in participation.
    - added additional information from ourworldindata
    - changed visual appearance
    - small changes in usability (e.g. you can go back to your forecasts)


### Comparison of forecast submissions


- Overview of what we found. Discuss figure 1 showing forecasts at 1 and 2 week horizon (3 and 4 in SI and referenced here). Compare submissions to each other and to the german hub visually.
- Table 1 forecast scores at 2 week time horizon. SI for 1 week and 4 week.
- Table 2 (or figure) scores by forecast time period (stable, unstabe, intervention/no intervention).
- Compare performance on deaths vs cases (think about which to lead with and how to present).

### Comparison of individual forecasters (optional)

- Summary information of who the forecasters were. 
- Same structure as above but this time comparing forecasters by id with the expert forecast ensemble

## Discussion

**Summary**

- Expert opinion performed on average as well as or better than model derived, and expert tuned, forecasts.
- At short time horizons untuned models designed to perform well in real-time more rapidly adapted to state changes but this was offset but reduced long term improvement. 
- A simple model that assumed that cases were a convolution of deaths performed well compared to other approaches and outperformed expert opinion at short time horizons and did relatively well at longer time horizons.
- Optimising a forecast to a specific time horizon relies on understanding the use case of those consuming the forecasts.
- Crowd forecasts performed well but where difficult to recruit and hard to extend over a large number of forecast targets. Here for example we could not produce crowd forecasts at the state level in either Poland or Germany due to a lack of researcher time and our ability to reach out to potential forecasters.
- Something about how most of the participants were from the UK and therefore it as a) hard to motivate them for GM/PL and b) they didn't have a lot of domain expertise there

**Strengths and Weaknesses**

*When writing this layer strengths and limitations together. Start with a strength and then for every limitation counter with a strength*

- S: This work has robustly assessed the performance of both crowd and model based forecasts made in real-time over a period of X weeks and submitted to an independent research group for evaluation against other methods. 
- S: We used proper scoring rules to evaluate our forecasts and considered a range of features in the observed data that may have impacted forecast performance. 
- S: We used forecasts made in real-time for our evaluation rather than retrospective forecasts. This is important for two reasons. Firstly, notification data is subject to reporting artefacts (such as retrospective updates), changes in testing policy, and variation in reporting policy. Secondly, as our forecasts were registered with an independent research group we could not tune or alter our results inadvertantly post submission. This means that our findings reflect realistic real-time performance without any introducted bias. 
- W: The sample size of expert forecasters was limited.

**Strengths and weaknesses in the context of the literature**

*Same structure as for the previous section.*

- Compare to US hub work (they had lots more data and many more models however there data source was very challenging and their models were all essentially black boxes to one degree or another making drawing conclusions difficult).
- Compare to Germany hub work (similar as above + different focus). Mention prespecified which is good.
- Compare to other model comparison efforts that don't include crowd forecasting.
- Compare to other crowd forecasting efforts. Examples to include: Delphi (as most comparable) and then binary prediction projects.

**Future work**

- Optimise the model based forecasts into a single submission for the ECDC based hub
- Compare the model based forecasts used here to simple time series based approaches and evaluate using weighted ensembles. Mention we are currently doing this in the US. 
- Expand crowd forecasting work to more targets and continue to improve/evaluate interface.
- Explore other crowd forecasting methods (i.e Rt based if not including here).

**Conclusions**

- Crowd forecasts outperform models with simplistic epidemiology derived assumptions at longer time horizons. 
- At shorter time horizons performance is more comparable, especially when forecasting deaths when a model that simplistically assumes that deaths are scaled convolution of cases performs relatively well.


# Supplementary information

