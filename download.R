library(docopt)
library(readr)

# Define usage string
doc <- "
Usage:
  download.R <url> <destination>

Options:
  <url>         URL location of the CSV file.
  <destination> File path where the CSV file will be placed.
"

args <- docopt(doc, args = c("https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2024/2024-05-07/rolling_stone.csv", "data/rolling_stone.csv"))

url <- args$url
destination <- args$destination

download.file(url, destination)

rollingstone <- read_csv(destination)
rollingstone