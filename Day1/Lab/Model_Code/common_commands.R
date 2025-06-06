# Create a vector
my_vector <- c(1, 2, 3, 4, 5)

# Create a matrix
my_matrix <- matrix(1:9, nrow = 3)

# Create a data frame
my_data_frame <- data.frame(Name = c("Alice", "Bob"), Age = c(25, 30))
View(my_data_frame)

# Clean working environment
rm(list = ls())

# Get and set working directory
getwd()
# setwd("path/to/your/directory")

# Read a CSV
my_data <- read.csv("Day1.csv")
head(my_data)
head(my_data, n = 1)

# Column names
colnames(my_data)
View(my_data)

# Access specific variables
head(my_data$favorites)
# Access specific rows
head(my_data[1:5, ])
# Access specific columns
head(my_data[, c("favorites", "retweets")])
# Access specific cells
my_data[1, "favorites"] # or
my_data$favorites[1]

# Descriptive statistics
mean(my_data$favorites)
median(my_data$favorites)
sd(my_data$favorites)
var(my_data$favorites)
max(my_data$favorites)
min(my_data$favorites)

# Correlation
cor(my_data$favorites, my_data$retweets)
cor.test(my_data$favorites, my_data$retweets)

# Plot
plot(my_data$favorites, my_data$retweets)

# Regression
lm_model <- lm(my_data$retweets ~ my_data$favorites)
summary(lm_model)

# Frequency counts
table(my_data$Party)
table(my_data$chamber)
table(my_data$author)

# Basic summarization
summary(my_data)
table(my_data$Party)  # Frequency table by party

# Create a new variable: difference between virtue and vice scores
my_data$Loyalty_diff <- my_data$Loyaltyvirtue - my_data$Loyaltyvice

# Grouped summary: average moral scores by party
# The tidyverse package is often used for data manipulation
if (!require("tidyverse")) install.packages("tidyverse")
# or you can write in tidyverse style
my_data %>%
  group_by(Party) %>%
  summarise(
    avg_Carevirtue = mean(Carevirtue, na.rm = TRUE),
    avg_Carevice = mean(Carevice, na.rm = TRUE),
    avg_Loyaltyvirtue = mean(Loyaltyvirtue, na.rm = TRUE),
    avg_Loyaltyvice = mean(Loyaltyvice, na.rm = TRUE)
  )

# Install and load ggplot2 (if not yet installed)
# ggplot2 is the go-to package for data visualization in R
if (!require("ggplot2")) install.packages("ggplot2")

# Basic ggplot2: scatterplot of retweets vs. favorites
ggplot(my_data,
       aes(x = retweets,
           y = favorites,
           color = Party)) +
  geom_point(alpha = 0.7) +
  theme_minimal() +
  labs(title = "Retweets vs Favorites by Party")

# Boxplot of moral foundation by party
ggplot(my_data,
       aes(x = Party,
           y = Carevirtue,
           fill = Party)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Care Virtue Score by Party")
