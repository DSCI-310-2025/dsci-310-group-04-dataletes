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

# 8. Anomalous correlation between response and nummeric predictors( < 0.01)
# Check correlation between response and each predictor
response_var <- "weeks_on_billboard"
predictors <- c("release_year", "peak_billboard_position", "spotify_popularity", 
                "debut_album_release_year", "artist_gender", "years_between", 
                "artist_member_count", "artist_birth_year_sum", "ave_age_at_top_500")

# Only keep numeric ones
numeric_predictors <- predictors[sapply(clean_data[predictors], is.numeric)]

cor_with_response <- sapply(numeric_predictors, function(col) {
    cor(clean_data[[response_var]], clean_data[[col]], use = "complete.obs")
})

# Define a correlation "floor" — flag if abs(cor) is very low (< 0.01)
low_info_predictors <- names(cor_with_response)[abs(cor_with_response) < 0.01]

if (length(low_info_predictors) > 0) {
    stop(paste(" Warning: Very weak correlation (< 0.01) with response detected for:",
                  paste(low_info_predictors, collapse = ", ")))
}

cat("✅ All data validation checks passed.\n")
