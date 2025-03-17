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
getwd()
args <- docopt(doc)

url <- args$url
destination <- args$destination

download.file(url, destination)

rollingstone <- read_csv(destination)
rollingstone