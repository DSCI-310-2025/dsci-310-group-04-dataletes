#!/usr/bin/env Rscript

# Validation script for cleaned_data.csv

library(readr)

# Load cleaned data
cleaned_data_path <- "data/processed/cleaned_data.csv"

if (!file.exists(cleaned_data_path)) {
  stop("ERROR: cleaned_data.csv not found in data/processed/")
}

clean_data <- read_csv(cleaned_data_path, show_col_types = FALSE)

# 1. Expected column names
expected_cols <- c("release_year", "peak_billboard_position", "spotify_popularity", 
                   "weeks_on_billboard", "artist_gender")

if (!all(expected_cols %in% colnames(clean_data))) {
  stop("ERROR: One or more expected columns are missing in cleaned_data.")
}

# 2. No empty observations (entire row is NA)
if (any(rowSums(is.na(clean_data)) == ncol(clean_data))) {
  stop("ERROR: Completely empty rows found in cleaned_data.")
}

# 3. Missingness threshold
na_pct <- colMeans(is.na(clean_data))
if (any(na_pct > 0.3)) {
  stop("ERROR: Some columns have more than 30% missing values.")
}

# 4. Correct data types
expected_types <- c("numeric", "numeric", "numeric", "numeric", "character")
actual_types <- sapply(clean_data[expected_cols], class)

if (!all(actual_types == expected_types)) {
  stop("ERROR: One or more columns have incorrect data types.")
}

# 5. No duplicate rows
if (any(duplicated(clean_data))) {
  stop("ERROR: Duplicate rows found in cleaned_data.")
}

# 6. Valid value range for spotify_popularity
if (any(clean_data$spotify_popularity < 0 | clean_data$spotify_popularity > 100, na.rm = TRUE)) {
  stop("ERROR: Out-of-bounds values in spotify_popularity (should be 0–100).")
}

# 7. Valid category levels for artist_gender
valid_genders <- c("Male", "Female", "Male/Female")
invalid_levels <- setdiff(unique(clean_data$artist_gender), valid_genders)

if (length(invalid_levels) > 0) {
  stop(paste("ERROR: Invalid category levels in artist_gender:", paste(invalid_levels, collapse = ", ")))
}

# 8. Basic sanity check: Response variable (weeks_on_billboard) must be >0
if (any(clean_data$weeks_on_billboard <= 0, na.rm = TRUE)) {
  stop("ERROR: Non-positive values in weeks_on_billboard detected.")
}

cat("✅ All data validation checks passed.\n")
