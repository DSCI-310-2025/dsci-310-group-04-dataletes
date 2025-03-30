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
            
            if (nrow(data) == 0) {
                        stop("Input tibble is empty")
            }
            
            # Drop columns if they exist
            columns_to_drop <- c(
                        "rank_2003", "rank_2012", "rank_2020",
                        "spotify_url", "sort_name", "clean_name", 
                        "album_id", "album"
            )
            cols_to_drop <- intersect(columns_to_drop, names(data))
            if (length(cols_to_drop) > 0) {
                        data <- data %>% dplyr::select(-all_of(cols_to_drop))
            }
            
            # Remove duplicates based on title and artist
            data <- data %>% 
                        dplyr::distinct(title, artist, .keep_all = TRUE)
            
            # Impute missing values in 'genre' with the most frequent value
            if ("genre" %in% names(data)) {
                        most_frequent_genre <- names(sort(table(data$genre), decreasing = TRUE))[1]
                        data <- data %>%
                                    dplyr::mutate(genre = ifelse(is.na(genre), most_frequent_genre, genre))
            }
            
            # Impute missing values in 'weeks_on_billboard' with the mean
            if ("weeks_on_billboard" %in% names(data)) {
                        mean_weeks <- mean(data$weeks_on_billboard, na.rm = TRUE)
                        data <- data %>%
                                    dplyr::mutate(weeks_on_billboard = ifelse(is.na(weeks_on_billboard),
                                                mean_weeks, weeks_on_billboard))
            }
            
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
            if (destination == "") {
                        stop("Destination path cannot be empty")
            }
            
            # Ensure the directory exists
            dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
            
            # Save the data preserving types
            readr::write_csv(data, destination)
            invisible(NULL)
} 