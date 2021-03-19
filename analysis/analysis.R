library(here)
library(magrittr)
library(stringr)
library(data.table)

# update data ------------------------------------------------------------------
## update forecasts
# trying to use 'here', but the problem is that there is a white space in my 
# folder path and that therefore fails
system(
  paste(". analysis/update-forecasts.sh")
)

## update truth data 
# not sure how we want to handle this - ideally we want to avoid dependencies 
# on this repo / package for later reproducibiity?
# for now I'm just loading it from file

source(here("data-raw", "update.R"))


# load forecasts ---------------------------------------------------------------
file_paths <- get_file_paths()
forecasts <- load_all_forecasts(file_paths)

# load truth data --------------------------------------------------------------
# problem here is that the truth data source changed in the middle. 
# need to talk to Johannes about that
truth <- load_all_truth()

# score forecasts --------------------------------------------------------------
