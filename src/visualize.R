library(docopt)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggpubr)

doc <- "
Usage:
  download.R <source> <destination>

Options:
  <source>         File path to source data CSV file.
  <destination>    File path where the visualization will be placed.
"

# Simulate command-line arguments (for Jupyter)
args <- docopt(doc, args = c("data/cleaned_data.csv", "data/visualizations.png"))  # Replace with actual file paths

# Load the data
cleaned_data <- read_csv(args$source)

# Training and testing split
set.seed(123)
sample_index <- sample(1:nrow(cleaned_data), 0.8 * nrow(cleaned_data))
train_data <- cleaned_data[sample_index, ]

# Select all numeric variables
numeric_vars <- train_data %>%
  select(where(is.numeric))

# Create an empty list to store plots
plots <- list()

# Loop through all numeric variables (excluding the target variable)
num <- 1

for (var in names(numeric_vars)) {
  if (var != "weeks_on_billboard") {  # Skip the target variable
    # Create scatter plot
    p <- ggplot(train_data, aes(x = .data[[var]], y = weeks_on_billboard)) +
      geom_point(alpha = 0.5, color = "blue") +  # Add points with transparency
      geom_smooth(method = "lm", se = FALSE, color = "red") +  # Add a linear trendline
      labs(title = paste0("Figure ", num, ": Weeks on Billboard vs. ", var), x = var, y = "Weeks on Billboard")
    
    # Add the plot to the list
    plots[[num]] <- p
    num <- num + 1
  }
}

# Compute correlations with the target variable (this was missing)
correlations <- train_data %>%
  select(where(is.numeric)) %>%
  cor() %>%
  as.data.frame() %>%
  select(weeks_on_billboard)

# Create a bar plot for the correlations
barplot <- ggplot(correlations, aes(x=rownames(correlations), y=weeks_on_billboard)) + 
  geom_bar(stat = "identity") +
  labs(title = "Figure 14: Correlations between Weeks on Billboard and Predictors", x = "Predictor", y = "Correlation Coefficient") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability

# Boxplots for the additional variables
boxplot_genre <- ggplot(train_data, aes(x = genre, y = weeks_on_billboard)) +
  geom_boxplot() +
  labs(title = "Figure 11: Weeks on Billboard by Genre", x = "Genre", y = "Weeks on Billboard") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability

boxplot_gender <- ggplot(train_data, aes(x = artist_gender, y = weeks_on_billboard)) +
  geom_boxplot() +
  labs(title = "Figure 12: Weeks on Billboard by Gender", x = "Gender", y = "Weeks on Billboard") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability

boxplot_type <- ggplot(train_data, aes(x = type, y = weeks_on_billboard)) +
  geom_boxplot() +
  labs(title = "Figure 13: Weeks on Billboard by Album Type", x = "Type", y = "Weeks on Billboard") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability

boxplots_list <- list()
# Add the boxplots to the list of plots
boxplots_list[[1]] <- boxplot_genre
boxplots_list[[2]] <- boxplot_gender
boxplots_list[[3]] <- boxplot_type
boxplots_list[[4]] <- barplot

# Arrange all the plots side by side
scatterplots <- ggarrange(plotlist = plots, ncol = 5, nrow = 3)
boxplots <- ggarrange(plotlist = boxplots_list, ncol = 4, nrow = 1)

# Combine the scatterplots and boxplots into one layout
combined <- list()
combined[[1]] <- scatterplots
combined[[2]] <- boxplots

combined_plot <- ggarrange(plotlist = combined, ncol = 1, nrow = 3)

# Save the combined plot to a PNG file
ggsave(args$destination, plot = combined_plot, width = 30, height = 20)