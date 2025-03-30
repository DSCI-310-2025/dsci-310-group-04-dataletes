library(testthat)
library(readr)
library(tibble)
source("R/download_functions.R")

# Test data creation helper function
create_test_data <- function() {
  tibble::tibble(
    title = c("Song 1", "Song 2", "Song 3"),
    artist = c("Artist 1", "Artist 2", "Artist 3"),
    genre = c("Rock", "Pop", "Jazz"),
    weeks_on_billboard = c(10, 15, 20),
    type = c("Single", "Album", "Single")
  )
}

test_that("download_rolling_stone_data downloads and saves file correctly", {
  # Create a temporary directory for testing
  temp_dir <- tempfile("test_dir")
  dir.create(temp_dir)
  temp_file <- file.path(temp_dir, "test_data.csv")

  # Create test data and save it as a temporary file to "download" from
  test_data <- create_test_data()
  source_file <- file.path(temp_dir, "source.csv")
  write.csv(test_data, source_file, row.names = FALSE)

  # Download the data
  result <- download_rolling_stone_data(source_file, temp_file)

  # Check that file exists and is not empty
  expect_true(file.exists(temp_file))
  expect_gt(file.size(temp_file), 0)

  # Check that the downloaded data matches the original
  expect_equal(as.data.frame(result), as.data.frame(test_data))

  # Clean up
  unlink(temp_dir, recursive = TRUE)
})

test_that("download_rolling_stone_data handles invalid inputs", {
  # Test with NULL inputs
  expect_error(
    download_rolling_stone_data(NULL, "test.csv"),
    "URL and destination must be character strings"
  )
  expect_error(
    download_rolling_stone_data("http://example.com", NULL),
    "URL and destination must be character strings"
  )

  # Test with empty inputs
  expect_error(
    download_rolling_stone_data("", "test.csv"),
    "cannot open empty URL"
  )
  expect_error(
    download_rolling_stone_data("http://example.com", ""),
    "Destination path cannot be empty"
  )
})

test_that("download_rolling_stone_data creates destination directory
if needed", {
  # Create a temporary directory for testing
  temp_dir <- tempfile("test_dir")
  dir.create(temp_dir)
  nested_dir <- file.path(temp_dir, "nested", "path")
  temp_file <- file.path(nested_dir, "test_data.csv")

  # Create test data and save it as a temporary file to "download" from
  test_data <- create_test_data()
  source_file <- file.path(temp_dir, "source.csv")
  write.csv(test_data, source_file, row.names = FALSE)

  # Download the data (should create nested directory)
  result <- download_rolling_stone_data(source_file, temp_file)

  # Check that the nested directory was created
  expect_true(dir.exists(dirname(temp_file)))

  # Check that file exists and is not empty
  expect_true(file.exists(temp_file))
  expect_gt(file.size(temp_file), 0)

  # Clean up
  unlink(temp_dir, recursive = TRUE)
})
