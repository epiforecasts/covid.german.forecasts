!# bin/bash
cd submissions
cd rt-forecasts-retrospective
find . -name '*.csv' -exec cp {} ../../data-raw/epiforecasts-EpiNow2-retrospective/ \;
cd ..

cd deaths-from-cases-retrospective
find . -name '*.csv' -exec cp {} ../../data-raw/epiforecasts-EpiNow2_secondary-retrospective/ \;
cd ../..