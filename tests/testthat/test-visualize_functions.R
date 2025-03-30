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
source("R/visualize_functions.R")

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

