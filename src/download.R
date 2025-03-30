library(docopt)
library(readr)
source("R/download_functions.R")

# Define usage string
doc <- "
Usage:
  download.R <url> <destination>

Options:
  <url>         URL location of the CSV file.
  <destination> File path where the CSV file will be placed.
"

args <- docopt(doc)

# Download the data using our new function
rollingstone <- download_rolling_stone_data(args$url, args$destination)