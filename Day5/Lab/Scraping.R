# Script 1: Scrape GDP from Wikipedia
# ===================================
# Load packages
library(rvest)
library(dplyr)
library(ggplot2)

# Scrape the GDP table from Wikipedia
url <- "https://en.wikipedia.org/wiki/List_of_countries_by_GDP_(nominal)"
page <- read_html(url)
tables <- html_table(page, fill = TRUE)

# Find the table that contains the GDP data (usually the first or second)
gdp_table <- tables[[2]] %>% 
  select(Country = 1, GDP = 2) %>% 
  head(20) %>% 
  mutate(GDP = as.numeric(gsub("[,\$]", "", GDP))) %>% 
  filter(!is.na(GDP))

# Plot GDPs
ggplot(gdp_table, aes(x = reorder(Country, GDP), y = GDP)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 20 Countries by Nominal GDP", y = "GDP (US$ millions)", x = "Country")


# Script 2: Scrape NBA Standings from ESPN
# ========================================
library(rvest)
library(dplyr)

url <- "https://www.espn.com/nba/standings"
page <- read_html(url)
tables <- html_table(page, fill = TRUE)

# The first table is usually the Eastern Conference
nba <- tables[[1]] %>% 
  select(Team = 1, Wins = 2, Losses = 3, WinPct = 4) %>% 
  mutate(across(Wins:WinPct, as.numeric)) %>% 
  filter(!is.na(Wins)) %>% 
  head(10)

# Show teams with highest win percentages
nba %>% arrange(desc(WinPct))


# Script 3: Scrape UN Population Data
# ===================================
library(rvest)
library(dplyr)
library(ggplot2)

url <- "https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population"
page <- read_html(url)
tables <- html_table(page, fill = TRUE)

# Extract top population table
data <- tables[[1]]
pop_table <- data %>%
  select(Country = 1, Population = 2) %>%
  mutate(Population = as.numeric(gsub("[,\[\]]", "", Population))) %>%
  filter(!is.na(Population)) %>%
  head(20)

# Plot top 20 countries by population
ggplot(pop_table, aes(x = reorder(Country, Population), y = Population)) +
  geom_col(fill = "darkgreen") +
  coord_flip() +
  labs(title = "Top 20 Countries by Population", y = "Population", x = "Country")