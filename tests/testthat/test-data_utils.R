library(testthat)
source("R/data_utils.R")

# Test data for testing
test_data <- tibble::tibble(
  rank_2003 = c(1, 2, 3),
  rank_2012 = c(1, 2, 3),
  rank_2020 = c(1, 2, 3),
  spotify_url = c("url1", "url2", "url3"),
  sort_name = c("name1", "name2", "name3"),
  clean_name = c("clean1", "clean2", "clean3"),
  album_id = c("id1", "id2", "id3"),
  album = c("album1", "album2", "album3"),
  genre = c("Rock", "Rock", NA),
  weeks_on_billboard = c(10, 20, NA),
  other_column = c(1, 2, 3)
)

test_that("clean_rolling_stone_data removes duplicates", {
  # Create data with duplicates
  data_with_duplicates <- rbind(test_data, test_data[1, ])
  
  # Clean the data
  cleaned_data <- clean_rolling_stone_data(data_with_duplicates)
  
  # Check that duplicates are removed
  expect_equal(nrow(cleaned_data), nrow(test_data))
})

test_that("clean_rolling_stone_data drops specified columns", {
  # Clean the data
  cleaned_data <- clean_rolling_stone_data(test_data)
  
  # Check that specified columns are removed
  expect_false("rank_2003" %in% names(cleaned_data))
  expect_false("spotify_url" %in% names(cleaned_data))
  expect_false("sort_name" %in% names(cleaned_data))
  expect_false("clean_name" %in% names(cleaned_data))
  expect_false("album_id" %in% names(cleaned_data))
  expect_false("album" %in% names(cleaned_data))
})

test_that("clean_rolling_stone_data imputes missing values in genre", {
  # Clean the data
  cleaned_data <- clean_rolling_stone_data(test_data)
  
  # Check that NA in genre is replaced with most frequent value
  expect_false(any(is.na(cleaned_data$genre)))
  expect_equal(cleaned_data$genre[3], "Rock")
})

test_that("clean_rolling_stone_data imputes missing values in weeks_on_billboard", {
  # Clean the data
  cleaned_data <- clean_rolling_stone_data(test_data)
  
  # Check that NA in weeks_on_billboard is replaced with mean
  expect_false(any(is.na(cleaned_data$weeks_on_billboard)))
  expect_equal(cleaned_data$weeks_on_billboard[3], 15) # mean of 10 and 20
})

test_that("clean_rolling_stone_data drops rows with missing values", {
  # Create data with missing values in other columns
  data_with_missing <- test_data
  data_with_missing$other_column[3] <- NA
  
  # Clean the data
  cleaned_data <- clean_rolling_stone_data(data_with_missing)
  
  # Check that row with missing value is removed
  expect_equal(nrow(cleaned_data), 2)
})

test_that("clean_rolling_stone_data throws error for non-tibble input", {
  # Try to clean a data frame instead of a tibble
  df <- as.data.frame(test_data)
  
  # Check that error is thrown
  expect_error(clean_rolling_stone_data(df), "Input must be a tibble")
})

#test_that("save_cleaned_data saves data correctly", {
  # Create temporary file path
#  temp_file <- tempfile(fileext = ".csv")
  
  # Save the data
#  save_cleaned_data(test_data, temp_file)
  
  # Check that file exists
#  expect_true(file.exists(temp_file))
  
  # Read back the data and check it's the same
#  saved_data <- readr::read_csv(temp_file)
#  expect_equal(saved_data, test_data)
  
  # Clean up
#  unlink(temp_file)
#})

test_that("save_cleaned_data throws error for non-tibble input", {
  # Try to save a data frame instead of a tibble
  df <- as.data.frame(test_data)
  
  # Check that error is thrown
  expect_error(save_cleaned_data(df, "test.csv"), "Input must be a tibble")
})

test_that("save_cleaned_data throws error for non-character destination", {
  # Try to save with non-character destination
  expect_error(save_cleaned_data(test_data, 123), "Destination must be a character string")
}) 

test_that("generate_scatterplots creates scatterplots correctly", {
 plots <- generate_scatterplots(
   c("Age","Score"),
   data.frame(
   Age = c(25, 30, 35),
   Score = c(85.5, 90.0, 78.3)
   ),
   "Age",
   5
 )
  expect_equal(plots[[1]]$mapping,aes(x = .data[["Score"]], y = .data[["Age"]]))
  expect_equal(plots[[1]]$labels$title,"Figure 5: Weeks on Billboard vs. Score")
  expect_true(inherits(plots[[1]]$layers[[1]]$geom, "GeomPoint"))
  expect_true(inherits(plots[[1]]$layers[[2]]$geom, "GeomSmooth"))
})

test_that("generate_scatterplots throws error for non-existent column references", {
  expect_error(generate_scatterplots(
   c("Oldness","Points"),
   data.frame(
   Age = c(25, 30, 35),
   Score = c(85.5, 90.0, 78.3)
   ),
   "Oldness",
   5
 ),"Unknown variables in variable name list")
})

test_that("generate_scatterplots throws error for non-numeric variables", {
  expect_error(generate_scatterplots(
   c("Age","Score"),
   data.frame(
   Age = c("25", "30", "35"),
   Score = c(85.5, 90.0, 78.3)
   ),
   "Age",
   5
 ),"Non-numeric variables referenced in variable list")
})
