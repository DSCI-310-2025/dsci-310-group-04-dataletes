library(docopt)
library(readr)
library(dplyr)
library(tidyr)

# Define usage string
doc <- "
Usage:
  download.R <source> <destination>

Options:
  <source>         File path to source data CSV file.
  <destination>    File path where the cleaned data CSV file will be placed.
"

# Simulate command-line arguments (for Jupyter)
args <- docopt(doc)  # Replace with actual file paths

# Extract file paths from args
source_file <- args$source
destination_file <- args$destination

# Load the data
set.seed(123)  # For reproducibility
rolling_stone <- read_csv(source_file)

# 1. Removing duplicates
rolling_stone_distinct <- distinct(rolling_stone)

# 4. Drop irrelevant columns (domain knowledge and EDA)
columns_to_drop <- c("rank_2003", "rank_2012", "rank_2020", "spotify_url", "sort_name", "clean_name", "album_id", "album")
rolling_stone_cleaned <- rolling_stone_distinct %>%
  select(-all_of(columns_to_drop))

# 5. Impute missing values in 'genre' with the most frequent value
most_frequent_genre <- names(sort(table(rolling_stone_cleaned$genre), decreasing = TRUE))[1]
rolling_stone_cleaned <- rolling_stone_cleaned %>%
  mutate(genre = ifelse(is.na(genre), most_frequent_genre, genre))

# 7. Impute missing values in 'weeks_on_billboard' with the mean
mean_weeks <- mean(rolling_stone_cleaned$weeks_on_billboard, na.rm = TRUE)
rolling_stone_cleaned <- rolling_stone_cleaned %>%
  mutate(weeks_on_billboard = ifelse(is.na(weeks_on_billboard), mean_weeks, weeks_on_billboard))

# 9. Drop rows with missing values in other columns
rolling_stone_cleaned <- rolling_stone_cleaned %>%
  drop_na()

# Save the cleaned data
write.csv(rolling_stone_cleaned, destination_file)

