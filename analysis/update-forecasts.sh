#!bin/bash

# this requires subversion to be installed

## Move out one directory and clone (or pull) data repo
cd analysis
printf "Cloning forecasts folder\n"
svn checkout https://github.com/KITmetricslab/covid19-forecast-hub-de/trunk/data-processed/epiforecasts-EpiExpert
svn checkout https://github.com/KITmetricslab/covid19-forecast-hub-de/trunk/data-processed/epiforecasts-EpiExpert_Rt
svn checkout https://github.com/KITmetricslab/covid19-forecast-hub-de/trunk/data-processed/epiforecasts-EpiNow2
svn checkout https://github.com/KITmetricslab/covid19-forecast-hub-de/trunk/data-processed/epiforecasts-EpiNow2_secondary

cd ..

