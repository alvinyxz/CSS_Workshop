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
