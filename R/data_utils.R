library(docopt)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggpubr)



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


#' Create scatterplots to compare all variables against a target variable
#'
#' @param vars A character vector of the names of the numeric variables inside data
#' @param plotdata A tibble or data frame that contains the values for all of the variables
#' @param target A character string representing the variable of interest that we will plot all the other variables against
#' @param numberfrom A number that represents the starting figure number of the first scatterplot
#' @return A list of scatterplots
#' @export
#' @examples
#' \dontrun{
#' generate_scatterplots(
#'   c("Age","Score"),
#'   data.frame(
#'   Age = c(25, 30, 35),
#'   Score = c(85.5, 90.0, 78.3)
#'   ),
#'   "Age",
#'   5
#' )
#' }
generate_scatterplots <- function(vars, plotdata, target, numberfrom) {
plots <- list()
if (!is.character(target)) {
  stop(paste0("Expected string but was given: ",as.character(target)))
}

# Loop through all numeric variables (excluding the target variable)
num <- 1
number <- numberfrom
missing_vars <- setdiff(vars, colnames(plotdata))
if (length(missing_vars) > 0) {
  stop("Unknown variables in variable name list")
}
non_numeric_vars <- vars[!sapply(vars, function(var) is.numeric(plotdata[[var]]))]
  
if (length(non_numeric_vars) > 0) {
  stop(paste("Non-numeric variables referenced in variable list"))
}

for (var in vars) {

  if (!is.character(var)) {
    stop(paste0("Expected string but was given: ",as.character(var)))
  }
  if (var != target) {  # Skip the target variable
    # Create scatter plot
    p <- ggplot(plotdata, aes(x = .data[[var]], y = .data[[target]])) +
      geom_point(alpha = 0.5, color = "blue") +  # Add points with transparency
      geom_smooth(method = "lm", se = FALSE, color = "red") +  # Add a linear trendline
      labs(title = paste0("Figure ", numberfrom, ": Weeks on Billboard vs. ", var), x = var, y = "Weeks on Billboard")
    
    # Add the plot to the list
    plots[[num]] <- p
    num <- num + 1
    numberfrom <- numberfrom + 1
  }
}
plots
}