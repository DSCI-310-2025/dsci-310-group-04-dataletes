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

#' Converts a df into a table grob and prints turns it into a png placed in the destination
#'
#' @param df A dataframe to be converted into a table 
#' @param title A character string representing the title to place above the table
#' @param destination A character string representing the filepath to place the png
#' @param name A character string representing the name of the png
#' @param dimensions A length 2 list containing the width and height of the png represented as numbers (width first)
#' @return Nothing
#' @export
#' @examples
#' \dontrun{
#' create_table(
#'   data.frame(
#'   Age = c(25, 30, 35),
#'   Score = c(85.5, 90.0, 78.3)
#'   ),
#'   "TableTitle",
#'   "tests/testdir",
#'   "MyTableImage",
#'   list(1500,1000)
#' )
#' }
create_table <- function(df,title,destination,name,dimensions) {
# Save head of train_data_final

dir_path <- destination

# Check if the directory exists
if (!dir.exists(dir_path)) {
  stop("Unknown file destination")
}

if (dimensions[[1]]<=0 || dimensions[[2]] <= 0) {
    stop("Invalid dimensions")
}

png(paste0(destination,"/",name,".png"), dimensions[[1]],dimensions[[2]])
table_grob <- tableGrob(df)
grid.text(title, x = 0.5, y = 0.97, gp = gpar(fontsize = 14, fontface = "bold"))
grid.draw(table_grob)  # Adjust number of rows if needed
dev.off()
invisible(NULL)
}