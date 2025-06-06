# Script 1: Scrape the text from Wikipedia's page on University of Minnesota
# ===================================
# Load packages
library("rvest")
library("tidyverse")
library("xml2")

url <- "https://en.wikipedia.org/wiki/University_of_Minnesota"
# Go to the URL, right-click on the page, and
# select "Inspect" to find how the content you want is nested in the HTML.
# The next line reads the HTML content of the page
page <- read_html(url)
# You can see that, the main content is nested under 
# <div id="mw-content-text" class="mw-body-content">
# Therefore, to extract the main content, we can use the following code:
content <- page %>%
  html_nodes("#mw-content-text p") %>%
  # we specify "p" because paragraphs have the <p> tag
  # if you do not specify "p", it will return all the text in the div, which contains many other random elements
  html_text() %>%
  paste(collapse = "\n")
# Now, we can print the content
cat(content)

# These "[13]" references are so annoying, so we can remove them
# Go to the website again, right-click on the references, and select "Inspect"
# to find how the references are nested in the HTML. It shows
# <sup id="cite_ref-::0_14-1" class="reference">
# We can guess that maybe using "class="reference"" will identify those annoyance
# The next line removes the references nodes from the "page" object
page %>% html_nodes("sup.reference") %>% xml_remove()

content <- page %>%
  html_nodes("#mw-content-text p") %>%
  html_text() %>%
  paste(collapse = "\n")
cat(content)

# Save it as a text file
writeLines(content, "University_of_Minnesota.txt")

# Script 2: Scrape GDP table from Wikipedia
# ===================================
# Load packages
library("rvest")
library("tidyverse")
library("xml2")
library("ggplot2")

url <- "https://en.wikipedia.org/wiki/List_of_countries_by_GDP_(nominal)"
# Go to the URL, scroll down, you will see a table listing all countries' GDP
page <- read_html(url)
# The function html_table() extracts all tables from the page
tables <- html_table(page)
tables # This will return a list of data frames, each corresponding to a table on the page
# Look through, you will see that the GDP table is the third one
gdp_table <- tables[[3]]
View(gdp_table)

# Then you realized, damn, there are some annoying footnotes in the table
# that are [n 1] and [n 2] and so on

# So you have to go back to the `page` object and remove those footnotes
# Right click on the footnotes, select "Inspect", and you will see that
# Those footnotes are like this:
# <sup id="cite_ref-China-THM_1-1" class="reference">
# Therefore, we can use the following code to remove them
page %>% html_nodes("sup.reference") %>% xml_remove()
# And then we run the whole thing again
tables <- html_table(page)
gdp_table <- tables[[3]]
View(gdp_table)
# Perfect!

# Now let's clean the table
# First, the first row is not actual content, it is a header
# So we can delete it and then change the column name to something that makes more sense
gdp_table <- gdp_table[-1, ]
colnames(gdp_table) <- c("Country",
                         "IMF_Forecast",
                         "IMF_Year",
                         "World_Bank",
                         "World_Bank_Year",
                         "UN",
                         "UN_Year")
gdp_table$IMF_Forecast[2]
class(gdp_table$IMF_Forecast[2])
# Many columns that should have been numeric are actually characters
# To correct that, we can remove non-numeric characters and convert to numeric
gdp_table$IMF_Forecast <- as.numeric(gsub("[^0-9.]", "", gdp_table$IMF_Forecast))
gdp_table$World_Bank   <- as.numeric(gsub("[^0-9.]", "", gdp_table$World_Bank))
gdp_table$UN           <- as.numeric(gsub("[^0-9.]", "", gdp_table$UN))
# Some rows have "—" values which means no data available
# We can convert those to NA
gdp_table[gdp_table == "—"] <- NA

# Now it should look pretty good
View(gdp_table)

# Plot GDPs - only the top 20 countries and only using the IMF_Forecast
top20 <- gdp_table[order(-gdp_table$IMF_Forecast), ][2:21, ] # Exclude the first row which is "World"
ggplot(top20,
       aes(x = reorder(Country,
                       IMF_Forecast), # higher-GDP countries are to the most left
           y = IMF_Forecast / 1e6)) + # divide by 1e6 (million)
  geom_bar(stat = "identity",
           fill = "darkred") +
  coord_flip() + # flip the coordinates so that countries are on Y axis
  labs(title = "Top 20 Countries by IMF Forecast (Nominal GDP)",
       x = "Country",
       y = "GDP (in Millions USD)") +
  theme_minimal()
# Save it as a PDF
ggsave("Top_20_Countries_by_GDP.pdf",
       width = 8,
       height = 8)

# Some other websites also allow you to scrape data, such as:
# Script 3: Scrape NBA Standings from ESPN
# ========================================
library("rvest")
library("tidyverse")

url <- "https://www.espn.com/nba/standings"
# Go to the URL, you will see a table listing NFL standings
page <- read_html(url)
# The function html_table() extracts all tables from the page
tables <- html_table(page)
tables # This will return a list of data frames, each corresponding to a table on the page
# Look through, you will see that:
# the team standing table is the second one, while the team name is in the first one
team_names <- tables[[1]] # This is the first table, which contains team names
team_standings <- tables[[2]] # This is the second table, which contains team standings
View(team_names)
View(team_standings)
# Let's combine them into one table
nba <- cbind(team_names, team_standings)
View(nba)

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
# Also, you can save the page as an HTML file, send it to ChatGPT and tell ChatGPT what you want to scrape,
# ChatGPT may be able to tell you what code you should write in R to scrape it :)

# =========================================
# Your code below


# (Check Scraping_Google_Scholar.R if you really can't figure it out)


# Your code above
# =========================================

# However, some websites cannot be scraped with simple techniques such as rvest
# Script 5: Scrape NBA Standings from NBA.com
# ========================================
library("rvest")
library("tidyverse")
library("xml2")

url <- "https://www.nba.com/standings"
# Go to the URL, you will see a table listing NBA standings
page <- read_html(url)
# The function html_table() extracts all tables from the page
tables <- html_table(page)
tables
# Well, empty!
# This is because the data is loaded dynamically using JavaScript, which "rvest" cannot handle
# Or in some cases, the website simply blocks all scraping attempts
# In such cases, you can use Selenium
# Selenium: it is *not* a scraping tool, but a web automation tool
# You can use it to automate web browsers, such as clicking buttons, filling forms, etc.
# Then, once it loads all the content you want, you can use scraping tools to collect the content
# We usually use Selenium in Python, but there is an R package for it as well
