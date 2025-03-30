library(testthat)
library(readr)
library(dplyr)
library(tidyr)
library(tibble)
source("../../R/clean_functions.R")

# Test data creation helper function
create_test_data <- function() {
            tibble::tibble(
                        title = c("Song 1", "Song 2", "Song 3", "Song 1"),  # Duplicate row
                        artist = c("Artist 1", "Artist 2", "Artist 3", "Artist 1"),
                        genre = c("Rock", NA, "Jazz", "Rock"),
                        weeks_on_billboard = c(10, 15, NA, 10),
                        rank_2003 = c(1, 2, 3, 1),
                        rank_2012 = c(4, 5, 6, 4),
                        rank_2020 = c(7, 8, 9, 7),
                        spotify_url = paste0("https://spotify.com/", 1:4),
                        sort_name = paste0("sort_", 1:4),
                        clean_name = paste0("clean_", 1:4),
                        album_id = 1:4,
                        album = paste0("Album ", 1:4),
                        type = c("Single", "Album", "Single", "Single")
            )
}

test_that("clean_rolling_stone_data removes duplicates correctly", {
            # Create test data with duplicates
            test_data <- create_test_data()
            
            # Clean the data
            cleaned_data <- clean_rolling_stone_data(test_data)
            
            # Check that duplicates are removed
            expect_equal(nrow(cleaned_data), nrow(test_data) - 1)
            expect_false(any(duplicated(cleaned_data)))
})

test_that("clean_rolling_stone_data drops specified columns", {
            test_data <- create_test_data()
            
            # Clean the data
            cleaned_data <- clean_rolling_stone_data(test_data)
            
            # Check that specified columns are dropped
            dropped_cols <- c(
                        "rank_2003", "rank_2012", "rank_2020",
                        "spotify_url", "sort_name", "clean_name", 
                        "album_id", "album"
            )
            expect_false(any(dropped_cols %in% names(cleaned_data)))
})

test_that("clean_rolling_stone_data handles missing values correctly", {
            # Create test data with missing values
            test_data <- create_test_data()
            
            # Clean the data
            cleaned_data <- clean_rolling_stone_data(test_data)
            
            # Check that missing values are handled correctly
            expect_false(any(is.na(cleaned_data$genre)))
            expect_false(any(is.na(cleaned_data$weeks_on_billboard)))
            expect_false(any(is.na(cleaned_data)))  # All columns should be complete
})

test_that("clean_rolling_stone_data handles invalid inputs", {
            # Test with NULL input
            expect_error(clean_rolling_stone_data(NULL), "Input must be a tibble")
            
            # Test with empty tibble
            empty_df <- tibble::tibble()
            expect_error(clean_rolling_stone_data(empty_df), "Input tibble is empty")
})

test_that("save_cleaned_data saves data correctly", {
            # Create a temporary directory for testing
            temp_dir <- tempfile("test_dir")
            dir.create(temp_dir)
            temp_file <- file.path(temp_dir, "test_data.csv")
            
            # Create test data
            test_data <- create_test_data()
            
            # Save the data
            save_cleaned_data(test_data, temp_file)
            
            # Check that file exists and is not empty
            expect_true(file.exists(temp_file))
            expect_gt(file.size(temp_file), 0)
            
            # Read back the data and check it's the same
            saved_data <- readr::read_csv(temp_file, show_col_types = FALSE)
            expect_equal(as.data.frame(saved_data), as.data.frame(test_data))
            
            # Clean up
            unlink(temp_dir, recursive = TRUE)
})

test_that("save_cleaned_data handles invalid inputs", {
            # Test with NULL data
            expect_error(save_cleaned_data(NULL, "test.csv"), "Input must be a tibble")
            
            # Test with NULL file path
            test_data <- create_test_data()
            expect_error(save_cleaned_data(test_data, NULL), "Destination must be a character string")
            
            # Test with empty file path
            expect_error(save_cleaned_data(test_data, ""), "Destination path cannot be empty")
})

test_that("save_cleaned_data creates destination directory if needed", {
            # Create a temporary directory for testing
            temp_dir <- tempfile("test_dir")
            dir.create(temp_dir)
            nested_dir <- file.path(temp_dir, "nested", "path")
            temp_file <- file.path(nested_dir, "test_data.csv")
            
            # Create test data
            test_data <- create_test_data()
            
            # Save the data (should create nested directory)
            save_cleaned_data(test_data, temp_file)
            
            # Check that the nested directory was created
            expect_true(dir.exists(dirname(temp_file)))
            
            # Check that file exists and is not empty
            expect_true(file.exists(temp_file))
            expect_gt(file.size(temp_file), 0)
            
            # Clean up
            unlink(temp_dir, recursive = TRUE)
}) 