library(caret)
library(docopt)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggpubr)
library(gridExtra)
library(grid)
library(knitr)


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