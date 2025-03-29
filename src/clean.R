library(docopt)
library(readr)
library(dplyr)
library(tidyr)
source("R/data_utils.R")

# Define usage string
doc <- "
Usage:
  clean.R <source> <destination>

Options:
  <source>         File path to source data CSV file.
  <destination>    File path where the cleaned data CSV file will be placed.
"

# Parse command-line arguments
args <- docopt(doc)

# Load the data
set.seed(123) # For reproducibility
rolling_stone <- read_csv(args$source)

# Clean the data using our new function
rolling_stone_cleaned <- clean_rolling_stone_data(rolling_stone)

# Save the cleaned data using our new function
save_cleaned_data(rolling_stone_cleaned, args$destination)