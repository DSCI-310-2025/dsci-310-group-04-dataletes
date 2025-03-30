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
library(testthat)
source("R/model_functions.R")

test_that("create_table creates the png of the table", {
create_table(
   data.frame(
   Age = c(25, 30, 35),
   Score = c(85.5, 90.0, 78.3)
   ),
   "TableTitle",
   "tests/testthat",
   "MyTableImage",
   list(300,200)
 )
  png_file <- "tests/testthat/MyTableImage.png"
    expect_true(file.exists(png_file))
})

test_that("create_table creates a table with looping columns", {
create_table(
   data.frame(
   Age = c(25, 30, 35,1,2,3),
   Score = c(85.5, 90.0, "thing")
   ),
   "TableTitle",
   "tests/testthat",
   "SecondImage",
   list(123,456)
 )
  png_file <- "tests/testthat/SecondImage.png"
    expect_true(file.exists(png_file))
})

test_that("create_table throws error for non-existent path", {
expect_error(create_table(
   data.frame(
   Age = c(25, 30, 35,1,2,3),
   Score = c(85.5, 90.0, 78.3)
   ),
   "TableTitle",
   "invalid/unknown",
   "SecondImage",
   list(123,456)
 ),"Unknown file destination")
})

test_that("create_table throws error for invalid dimensions", {
expect_error(create_table(
   data.frame(
   Age = c(25, 30, 35,1,2,3),
   Score = c(85.5, 90.0, 78.3)
   ),
   "TableTitle",
   "tests/testthat",
   "SecondImage",
   list(100,0)
 ),"Invalid dimensions")
})
# Clean up test files
file.remove("tests/testthat/MyTableImage.png")
file.remove("tests/testthat/SecondImage.png")