library(docopt)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggpubr)
library(dataletes)

doc <- "
Usage:
  download.R <source> <destination>

Options:
  <source>         File path to source data CSV file.
  <destination>    File path where the visualization will be placed.
"

args <- docopt(doc)

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
plots <- generate_scatterplots(names(numeric_vars),train_data,"weeks_on_billboard",1)

# Compute correlations with the target variable (this was missing)
correlations <- train_data %>%
  select(where(is.numeric)) %>%
  cor() %>%
  as.data.frame() %>%
  select(weeks_on_billboard)
write(paste0("hcor: ", as.character(correlations[[1]][5])), "reports/output.txt", append = TRUE)
write(paste0("lcor: ", as.character(correlations[[1]][10])), "reports/output.txt", append = TRUE)
write(paste0("tIQR: ", as.character(IQR(cleaned_data$weeks_on_billboard))), "reports/output.txt", append = TRUE)

# Create a bar plot for the correlations
barplot <- ggplot(correlations, aes(x=rownames(correlations), y=weeks_on_billboard)) + 
  geom_bar(stat = "identity") +
  labs(title = "Figure 13: Correlations between Weeks on Billboard and Predictors", x = "Predictor", y = "Correlation Coefficient") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability

# Boxplots for the additional variables
boxplot_genre <- ggplot(train_data, aes(x = genre, y = weeks_on_billboard)) +
  geom_boxplot() +
  labs(title = "Figure 10: Weeks on Billboard by Genre", x = "Genre", y = "Weeks on Billboard") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability

boxplot_gender <- ggplot(train_data, aes(x = artist_gender, y = weeks_on_billboard)) +
  geom_boxplot() +
  labs(title = "Figure 11: Weeks on Billboard by Gender", x = "Gender", y = "Weeks on Billboard") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability

boxplot_type <- ggplot(train_data, aes(x = type, y = weeks_on_billboard)) +
  geom_boxplot() +
  labs(title = "Figure 12: Weeks on Billboard by Album Type", x = "Type", y = "Weeks on Billboard") +
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

pos <- nchar(args$destination) - 4 + 1
ggsave(paste0(substr(args$destination, 1, pos - 1), "s1", substr(args$destination, pos, nchar(args$destination))), plots[[1]],width = 10, height = 10)
ggsave(paste0(substr(args$destination, 1, pos - 1), "s2", substr(args$destination, pos, nchar(args$destination))), plots[[2]],width = 10, height = 10)
ggsave(paste0(substr(args$destination, 1, pos - 1), "s3", substr(args$destination, pos, nchar(args$destination))), plots[[3]],width = 10, height = 10)
ggsave(paste0(substr(args$destination, 1, pos - 1), "s4", substr(args$destination, pos, nchar(args$destination))), plots[[4]],width = 10, height = 10)
ggsave(paste0(substr(args$destination, 1, pos - 1), "s5", substr(args$destination, pos, nchar(args$destination))), plots[[5]],width = 10, height = 10)
ggsave(paste0(substr(args$destination, 1, pos - 1), "s6", substr(args$destination, pos, nchar(args$destination))), plots[[6]],width = 10, height = 10)
ggsave(paste0(substr(args$destination, 1, pos - 1), "s7", substr(args$destination, pos, nchar(args$destination))), plots[[7]],width = 10, height = 10)
ggsave(paste0(substr(args$destination, 1, pos - 1), "s8", substr(args$destination, pos, nchar(args$destination))), plots[[8]],width = 10, height = 10)
ggsave(paste0(substr(args$destination, 1, pos - 1), "s9", substr(args$destination, pos, nchar(args$destination))), plots[[9]],width = 10, height = 10)
ggsave(paste0(substr(args$destination, 1, pos - 1), "b1", substr(args$destination, pos, nchar(args$destination))), boxplots_list[[1]],width = 10, height = 10)
ggsave(paste0(substr(args$destination, 1, pos - 1), "b2", substr(args$destination, pos, nchar(args$destination))), boxplots_list[[2]],width = 10, height = 10)
ggsave(paste0(substr(args$destination, 1, pos - 1), "b3", substr(args$destination, pos, nchar(args$destination))), boxplots_list[[3]],width = 10, height = 10)
ggsave(paste0(substr(args$destination, 1, pos - 1), "b4", substr(args$destination, pos, nchar(args$destination))), boxplots_list[[4]],width = 10, height = 10)

# Save the combined plot to a PNG file
ggsave(args$destination, plot = combined_plot, width = 30, height = 20)