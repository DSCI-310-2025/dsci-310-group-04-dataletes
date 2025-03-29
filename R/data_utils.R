#' Download data from a URL and save it to a specified location
#'
#' @param url A character string containing the URL of the data to download
#' @param destination A character string containing the file path where the data should be saved
#' @return A tibble containing the downloaded data
#' @export
#' @examples
#' \dontrun{
#' download_data("https://example.com/data.csv", "data/raw/data.csv")
#' }
download_data <- function(url, destination) {
  if (!is.character(url) || !is.character(destination)) {
    stop("URL and destination must be character strings")
  }
  
  download.file(url, destination)
  readr::read_csv(destination)
}

#' Clean Rolling Stone dataset by removing duplicates and handling missing values
#'
#' @param data A tibble containing the Rolling Stone dataset
#' @return A cleaned tibble with no duplicates and handled missing values
#' @export
#' @examples
#' \dontrun{
#' clean_rolling_stone_data(rolling_stone_data)
#' }
clean_rolling_stone_data <- function(data) {
  if (!tibble::is_tibble(data)) {
    stop("Input must be a tibble")
  }
  
  # Remove duplicates
  data <- dplyr::distinct(data)
  
  # Drop irrelevant columns
  columns_to_drop <- c(
    "rank_2003", "rank_2012", "rank_2020",
    "spotify_url", "sort_name", "clean_name", "album_id", "album"
  )
  data <- data %>%
    dplyr::select(-all_of(columns_to_drop))
  
  # Impute missing values in 'genre' with the most frequent value
  most_frequent_genre <- names(
    sort(table(data$genre), decreasing = TRUE)
  )[1]
  data <- data %>%
    dplyr::mutate(genre = ifelse(is.na(genre), most_frequent_genre, genre))
  
  # Impute missing values in 'weeks_on_billboard' with the mean
  mean_weeks <- mean(data$weeks_on_billboard, na.rm = TRUE)
  data <- data %>%
    dplyr::mutate(weeks_on_billboard = ifelse(is.na(weeks_on_billboard),
      mean_weeks, weeks_on_billboard
    ))
  
  # Drop rows with missing values in other columns
  data %>%
    tidyr::drop_na()
}

#' Save cleaned data to a CSV file
#'
#' @param data A tibble containing the cleaned data
#' @param destination A character string containing the file path where the data should be saved
#' @return NULL (invisible)
#' @export
#' @examples
#' \dontrun{
#' save_cleaned_data(cleaned_data, "data/processed/cleaned_data.csv")
#' }
save_cleaned_data <- function(data, destination) {
  if (!tibble::is_tibble(data)) {
    stop("Input must be a tibble")
  }
  if (!is.character(destination)) {
    stop("Destination must be a character string")
  }
  
  write.csv(data, destination)
  invisible(NULL)
}

#' Process Rolling Stone dataset from download to cleaned state
#'
#' @param url A character string containing the URL of the data to download
#' @param raw_destination A character string containing the file path for raw data
#' @param cleaned_destination A character string containing the file path for cleaned data
#' @return A tibble containing the cleaned data
#' @export
#' @examples
#' \dontrun{
#' process_rolling_stone_data(
#'   "https://example.com/data.csv",
#'   "data/raw/data.csv",
#'   "data/processed/cleaned_data.csv"
#' )
#' }
process_rolling_stone_data <- function(url, raw_destination, cleaned_destination) {
  # Download data
  raw_data <- download_data(url, raw_destination)
  
  # Clean data
  cleaned_data <- clean_rolling_stone_data(raw_data)
  
  # Save cleaned data
  save_cleaned_data(cleaned_data, cleaned_destination)
  
  cleaned_data
} 