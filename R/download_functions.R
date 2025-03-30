#' Download Rolling Stone dataset from URL
#'
#' Downloads the Rolling Stone dataset from a specified URL and saves it to a destination file.
#' The function handles both local and remote files, and ensures proper error handling.
#'
#' @param url A character string containing the URL of the data to download
#' @param destination A character string containing the file path where the data should be saved
#' @return A tibble containing the downloaded data
#' @export
#' @examples
#' \dontrun{
#' download_rolling_stone_data(
#'   "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2024/2024-05-07/rolling_stone.csv",
#'   "data/rolling_stone.csv"
#' )
#' }
download_rolling_stone_data <- function(url, destination) {
  if (!is.character(url) || !is.character(destination)) {
    stop("URL and destination must be character strings")
  }
  
  if (url == "") {
    stop("cannot open empty URL")
  }

  if (destination == "") {
    stop("Destination path cannot be empty")
  }
  
  # Create destination directory if it doesn't exist
  dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
  
  # If URL is a local file, just copy it
  if (file.exists(url)) {
    file.copy(url, destination, overwrite = TRUE)
  } else {
    # Otherwise try to download it
    download.file(url, destination)
  }
  
  # Read and return the data
  readr::read_csv(destination, show_col_types = FALSE)
} 