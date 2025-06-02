# STM.R — Structural Topic Modeling with U.S. Presidential Speeches

# Load required libraries
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("quanteda")) install.packages("quanteda")
if (!require("stm")) install.packages("stm")
if (!require("ggplot2")) install.packages("ggplot2")

# Load the data
df <- read.csv("presidential_speeches.csv")

# Keep only rows with valid speeches
df_clean <- df %>%
  filter(!is.na(speech))
# Let's focus on $year and $Party for analysis
df_clean$Year <- as.numeric(format(as.Date(df_clean$date, format = "%m/%d/%Y"), "%Y"))
df_clean$Party

# Create a corpus from the speech text
corp <- corpus(df_clean$speech,
               docnames = paste0("doc", seq_len(nrow(df_clean))),
               docvars = df_clean)

# Preprocess text: tokenization, cleaning, stopword removal
toks <- tokens(corp,
               remove_punct = TRUE,
               remove_numbers = TRUE) %>%
  tokens_tolower() %>%
  tokens_remove(stopwords("en")) %>%
  tokens_wordstem()

# Create a document-feature matrix (DFM)
dfm <- dfm(toks)

# Trim sparse terms (optional)
dfm <- dfm_trim(dfm, min_termfreq = 10, min_docfreq = 5)

# Convert to STM format
stm_input <- convert(dfm, to = "stm")

# Fit STM model — start with 5 topics (can change later)
mod <- stm(documents = stm_input$documents,
           vocab = stm_input$vocab,
           data = stm_input$meta,
           prevalence=~s(Year), # this line allows us to model topic prevalence over time, s() means smooth
           K = 5,
           max.em.its = 75,
           init.type = "Spectral")

# Summarize model
labelTopics(mod)

# Plot top words in each topic
plot(mod, type = "labels", n = 10)

# Plot topic prevalence over time
prep <- estimateEffect(1:5 ~ Year, mod, meta = stm_input$meta)

plot.estimateEffect(prep,
                    covariate = "Year",
                    method = "continuous",
                    topics = 1:5,
                    model = mod,
                    xlab = "Year",
                    ylab = "Topic Prevalence",
                    main = "Topic Trends Over Time")

# Optional: see which presidents are most associated with a topic
top_topic_docs <- findThoughts(mod,
                               texts = df_clean$speech,
                               topics = 1, # specify which topic to explore
                               n = 5) # specify number of documents to return
print(top_topic_docs)
# That's a lot of text, let's print the first few
print(substr(top_topic_docs$docs[[1]], 1, 150))

# Now think about what is not good about this model and the code above
# Discuss potential improvements with your team
