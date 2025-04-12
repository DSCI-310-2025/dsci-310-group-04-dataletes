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
library(dataletes)

doc <- "
Usage:
  download.R <source> <destination>

Options:
  <source>         File path to source data CSV file.
  <destination>    File path where the model data will be placed.
"

# Simulate command-line arguments (for Jupyter)
args <- docopt(doc)  # Replace with actual file paths

# Training and testing split
set.seed(123)

clean_data <- read_csv(args$source)


sample_index <- sample(1:nrow(clean_data), 0.8 * nrow(clean_data))
train_data <- clean_data[sample_index, ]
test_data <- clean_data[-sample_index, ]
# Drop irrelevant columns
cols_to_drop <- c("differential", "artist_member_count", "artist_birth_year_sum", 
                  "ave_age_at_top_500", "years_between")
train_data_cleaned <- train_data %>% select(-all_of(cols_to_drop))
test_data_cleaned <- test_data %>% select(-all_of(cols_to_drop))

# Define target column
target_col <- "weeks_on_billboard"

# Separate features and target
train_data_features <- train_data_cleaned %>% select(-all_of(target_col))
test_data_features <- test_data_cleaned %>% select(-all_of(target_col))

# Scale features
scaler <- preProcess(train_data_features, method = c("range"))
train_data_features_scaled <- predict(scaler, train_data_features)
test_data_features_scaled <- predict(scaler, test_data_features)

# Check levels of categorical variables in the training and testing sets
train_levels <- unique(train_data_features_scaled$type)
test_levels <- unique(test_data_features_scaled$type)

# Find new levels in the testing set
new_levels <- setdiff(test_levels, train_levels)


# Remove rows with new levels from the testing set
test_data_final <- test_data_features_scaled %>%
  filter(!type %in% new_levels)

# Filter the target column to match the filtered features
test_data_target_filtered <- test_data_cleaned[[target_col]][!test_data_features_scaled$type %in% new_levels]

# Combine scaled features with the filtered target column
test_data_final <- cbind(test_data_final, target = test_data_target_filtered)

# Combine scaled features with the target in the final training data
train_data_final <- cbind(train_data_features_scaled, target = train_data_cleaned[[target_col]])

# Check the final datasets
traininghead <- head(train_data_final,10)
testinghead <- head(test_data_final,10)



#make dest if it does not exist
if (dir.exists(args$destination)) {
  unlink(args$destination, recursive = TRUE)
}
dir.create(args$destination)

create_table(traininghead,"First 10 rows of the Training Dataset",args$destination,"train_data_head",list(1500,400))
create_table(testinghead,"First 10 rows of the Testing Dataset",args$destination,"test_data_final",list(1500,400))

# Define the formula
formula <- as.formula("target ~ .")

# Define the tuning grid for k (number of neighbors)
tune_grid <- expand.grid(k = seq(1, 20, by = 1))  # Test k values from 1 to 20

# Set up cross-validation
ctrl <- trainControl(method = "cv", number = 5)  # 5-fold cross-validation

# Train the kNN model with custom metric
knn_model <- train(
  formula,
  data = train_data_final,
  method = "knn",
  tuneGrid = tune_grid,
  trControl = ctrl,
  metric = "RMSE",  # Use RMSE as the primary metric (required by caret)
  maximize = FALSE,  # Minimize RMSE
  # Custom function to calculate Adjusted R-squared
  custom = list(
    summaryFunction = function(data, lev = NULL, model = NULL) {
      n <- nrow(data)
      p <- length(model$finalModel$xNames)
      adj_r2 <- adjusted_r2(data$obs, data$pred, n, p)
      out <- c(adj_r2 = adj_r2)
      return(out)
    }
  )
)


# Make predictions on the testing set
predictions <- predict(knn_model, newdata = test_data_final)
# Calculate RMSE
rmse <- sqrt(mean((test_data_final$target - predictions)^2))
write(paste0("rmse: ", as.character(rmse)), "reports/output.txt", append = TRUE)

# Calculate R-squared
ss_total <- sum((test_data_final$target - mean(test_data_final$target))^2)
ss_residual <- sum((test_data_final$target - predictions)^2)
r2 <- 1 - (ss_residual / ss_total)

model_summary <- paste(paste("RMSE on Testing Set:", rmse),paste("R-squared on Testing Set:", r2))
write(paste0("perr: ", as.character(r2)), "reports/output.txt", append = TRUE)
# Extract tuning results
tuning_results <- knn_model$results
# Extract the best model's results
best_knn <- knn_model$bestTune$k
caption_text <- paste(paste(paste("kNN Model Tuning Results with Best k:", best_knn),"\n"),paste(paste("RMSE on Testing Set:", rmse),paste("R-squared on Testing Set:", r2)))

# Save table as PNG

create_table(tuning_results,caption_text,args$destination,"knn_tuning_results",list(1000,600))