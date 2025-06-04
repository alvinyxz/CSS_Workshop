# Script 4: [Practice Yourself] Scrape Google Scholar
# ===================================
# Load packages
library("rvest")
library("tidyverse")
library("xml2")

# This is my Google Scholar page, you can use your own
url <- "https://scholar.google.com/citations?user=_gHXwrsAAAAJ"
page <- read_html(url)
# You will write the code yourself to scrape the following:
# - Title of each publication
# - Authors of each publication
# - Year of each publication
# - Number of citations of each publication

# Remember, for each element that you want to scrape, you can right-click on it,
# select "Inspect", and find how it is nested in the HTML.
# Also, you can save the page as an HTML file, tell ChatGPT what you want to scrape,
# And ChatGPT may be able to tell you what code you should write in R to scrape it :)

titles <- page %>%
  html_elements(xpath = '//*[@class="gsc_a_at"]') %>%
  html_text()
# Select the class being "gsc_a_at" to get the titles of the publications
# Or you can use CSS selector: ".gsc_a_at" (which is the same as xpath above)
titles <- page %>%
  html_nodes(".gsc_a_at") %>%
  html_text()

authors <- page %>%
  html_elements(xpath = '//a[@class="gsc_a_at"]/following-sibling::div[@class="gs_gray"][1]') %>%
  html_text()
# Find the class gsc_a_at, and then select the class gs_gray underneath it
# Or you can use CSS selector: ".gsc_a_at + .gs_gray" (which is the same as xpath above)
authors <- page %>%
  html_nodes(".gsc_a_at + .gs_gray") %>%
  html_text()

years <- page %>%
  html_elements(xpath = '//*[@class="gsc_a_y"]') %>%
  html_text()
# Select the class being "gsc_a_y" to get the years of the publications
# Or you can use CSS selector: ".gsc_a_y" (which is the same as xpath above)
years <- page %>%
  html_nodes(".gsc_a_y") %>%
  html_text()
# You will see that the first two years are not numbers, they are the clickable "Year" links
# So you can remove them by
years <- years[3:length(years)]

citations <- page %>%
  html_elements(xpath = '//*[@class="gsc_a_c"]') %>%
  html_text()
# Select the class being "gsc_a_c" to get the number of citations of the publications
# Or you can use CSS selector: ".gsc_a_c" (which is the same as xpath above)
citations <- page %>%
  html_nodes(".gsc_a_c") %>%
  html_text()
citations <- citations[3:length(citations)]

# Combine them together
publications <- data.frame(
  title = titles,
  authors = authors,
  year = years,
  citations = citations
)
# Save the data frame to a CSV file
write.csv(publications, "publications.csv", row.names = FALSE)
