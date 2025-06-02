if (!require("devtools")) install.packages("devtools")
if (!require("peRspective")) install.packages("favstats/peRspective")

# Set your API key first
Sys.setenv(perspective_api_key = "")  # Replace with your key
# Go to this page to get your API key: https://console.cloud.google.com/apis/credentials if you have already enabled the API.

# Analyze a single sentence for toxicity
sentence <- "This is a beautiful and thoughtful comment."
result <- prsp_score(text = sentence,
                     languages = "en",
                     score_model = "TOXICITY")
print(result)

# Analyze a single sentence for toxicity
sentence <- "I hate you so much, you're the worst!"
result <- prsp_score(text = sentence,
                     languages = "en",
                     score_model = "TOXICITY")
print(result)

# Analyze a single sentence for toxicity
sentence <- "卧槽你怎么那么傻逼"
result <- prsp_score(text = sentence,
                     languages = "zh",
                     score_model = "TOXICITY")
print(result)

# Let's try it on the first speech
if (!require("tidyverse")) install.packages("tidyverse")
df <- read.csv("presidential_speeches.csv")
df <- df %>%
  select(President, date, speech) %>%
  filter(!is.na(speech)) # remember, some speeches may be missing
# Extract and truncate the first speech
# Because Google Perspective API is designed for shorter text (e.g., tweets and news comments)
speech_text <- substr(df$speech[1], 1, 1000)
# Analyze the speech
speech_result <- prsp_score(text = speech_text,
                            languages = "en",
                            score_model = "TOXICITY")
print(speech_result)

# Now let's analyze the first 10 speeches for toxicity
# Otherwise, it is going to take hours to run
# Initialize a vector to store toxicity scores
df_subset <- df[1:10, ]
toxicity_scores <- vector("numeric", length = 10)
# Loop through the first 10 speeches
for (i in 1:10) {
  text <- substr(df_subset$speech[i], 1, 1000)  # Truncate to 1000 characters
  result <- prsp_score(text = text,
                       languages = "en",
                       score_model = "TOXICITY")
  toxicity_scores[i] <- result$TOXICITY
  Sys.sleep(1.1)  # Respect API rate limits
}
# Add toxicity scores to the subset dataframe
df_subset$toxicity <- toxicity_scores
# View the updated subset
print(df_subset[, c("President", "date", "toxicity")])

# Perspective’s primary attribute is TOXICITY
# Which is what we have tried so far.
# But it also gives other attributes:
# SEVERE_TOXICITY, IDENTITY_ATTACK, INSULT, PROFANITY, THREAT
# Try out other attributes using your own code below:









