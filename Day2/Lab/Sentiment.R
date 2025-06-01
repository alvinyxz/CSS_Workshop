# Load necessary libraries
library("tidyverse")      # For data manipulation
library("ggplot2")        # For data visualization

# Read the dataset
df <- read_csv("presidential_speeches.csv")

# Preview the data
head(df)

# load tidytext and textdata for sentiment analysis
library("tidytext")
library("textdata")
# Tidytext provides several sentiment lexicons/dictionary to label sentiment
# For example: "afinn", "nrc", "bing"
get_sentiments("afinn") # you might need to download the lexicon first, input "1" to download
# afinn categories words into positive and negative sentiments with scores
# Similar to bing
get_sentiments("bing") # bing categories words into positive and negative sentiments, no strength
get_sentiments("nrc")
# nrc categories words into positive, negative, anger, fear, joy, sadness, surprise, and trust

# We can look at what words are categorized as joy in the nrc lexicon
get_sentiments("nrc") %>% 
  filter(sentiment == "joy")

# Let's apply the bing lexicon to the first speech by Donald Trump
speech_to_try <- df$speech[1]
speech_to_try # Print it
# Create a data frame so tidytext can process it
speech_df <- data.frame(line = 1, text = speech_to_try)
# Tokenize the speech into words
speech_words <- speech_df %>%
  unnest_tokens(word, text)
# Load the Bing sentiment lexicon
bing_lex <- get_sentiments("bing")
# Join the words with the lexicon to get sentiment labels
speech_sentiment <- speech_words %>%
  inner_join(bing_lex, by = "word")
# View the words matched with sentiment
speech_sentiment
# Summarize counts of positive and negative words
table(speech_sentiment$sentiment)
# Trump used negative words 51 times and positive words 54 times

# Let's apply bing dictionary to our complete df$speech column
# Click objects in the Environment tab to see what the code is doing to your data

# Add a unique ID to each row so we can track speeches after unnesting
df$id <- 1:nrow(df)
# Tokenize: Break each speech into individual words
df_words <- df %>%
  unnest_tokens(word, speech)
# Load Bing lexicon
bing_lex <- get_sentiments("bing")
# Join words with sentiment labels
df_sentiment <- df_words %>%
  inner_join(bing_lex, by = "word", relationship = "many-to-many")
# Count positive and negative words per speech
df_score <- df_sentiment %>%
  count(id, sentiment) %>%
  pivot_wider(names_from = sentiment,
              values_from = n,
              values_fill = 0) %>%
  mutate(bing_sentiment_score = positive - negative)
# Merge sentiment scores back to original dataframe
df_final <- left_join(df, df_score, by = "id")
# Preview
head(df_final[, c("id", "President", "bing_sentiment_score")])

# Which President is the most positive?
df_final %>%
  group_by(President) %>%
  summarise(mean_bing_sentiment = mean(bing_sentiment_score, na.rm = TRUE)) %>%
  arrange(desc(mean_bing_sentiment))

# Does positivity differ by Party?
df_final %>%
  group_by(Party) %>%
  summarise(mean_bing_sentiment = mean(bing_sentiment_score, na.rm = TRUE)) %>%
  arrange(desc(mean_bing_sentiment))

# Over time?
df_final$date <- mdy(df_final$date)
df_final$year <- year(df_final$date)
df_final_by_year <- df_final %>%
  group_by(year) %>%
  summarise(mean_bing_sentiment = mean(bing_sentiment_score,
                                       na.rm = TRUE))
View(df_final_by_year) # some years have no speeches, so the mean is NAN
# Delete rows with NA values
df_final_by_year <- df_final_by_year[!is.na(df_final_by_year$mean_bing_sentiment), ]

ggplot(df_final_by_year,
       aes(x = year,
           y = mean_bing_sentiment)) +
  geom_line() +
  # or you can un-comment the lines below to smooth the line with geom_smooth()
  # geom_smooth(formula = y ~ x,
  #             se = TRUE,
  #             method = "loess",
  #             color = "blue",
  #             span = 0.1) +
  labs(title = "Average Sentiment Over Time",
       x = "Year",
       y = "Average Bing Sentiment Score") +
  theme_minimal()

# There are other commonly used R packages for sentimental analysis
# For example "Syuzhet" "SentimentAnalysis"

# Look at Syuzhet here:
# https://cran.r-project.org/web/packages/syuzhet/vignettes/syuzhet-vignette.html

# Look at SentimentAnalysis here:
# https://cran.r-project.org/web/packages/SentimentAnalysis/vignettes/SentimentAnalysis.html

# For the rest of the lab, you will explore and use Syuzhet and SentimentAnalysis packages
# to classify the sentiment of the speeches

# Your own code below:


















