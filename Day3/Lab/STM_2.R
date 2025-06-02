# Advanced STM analysis of presidential_speeches.csv
# Builds upon STM_1.R and incorporates additional preprocessing and modeling features

# Load necessary libraries
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("quanteda")) install.packages("quanteda")
if (!require("stm")) install.packages("stm")
if (!require("textstem")) install.packages("textstem")
if (!require("data.table")) install.packages("data.table")
if (!require("ggplot2")) install.packages("ggplot2")

# Load the data
dta <- read.csv("presidential_speeches.csv")

# Preprocess metadata
dta <- dta %>% 
  filter(!is.na(speech)) %>% # delete empty speeches
  mutate(Year = as.numeric(format(as.Date(date, format="%m/%d/%Y"), "%Y")),
         President = factor(President),
         Party = factor(Party))

# Text size summary
sum(sapply(strsplit(dta$speech, " "), length))  # total words

# Construct corpus with document-level variables
fullcorpus <- corpus(dta$speech, 
                     docvars = dta[, c("President",
                                       "Party",
                                       "Year")]) # document-level variables to model later

# Tokenization
# use "quanteda::" to avoid conflicts with other packages
toks <- quanteda::tokens(fullcorpus, 
                         what = "word", 
                         remove_punct = TRUE, 
                         remove_symbols = TRUE, 
                         remove_numbers = TRUE, 
                         remove_url = TRUE, 
                         remove_separators = TRUE, 
                         split_hyphens = FALSE)
# Convert British to American English, not needed for this dataset but very commonly used
if (!require("devtools")) install.packages("devtools")
if (!require("quanteda.dictionaries")) install.packages("kbenoit/quanteda.dictionaries")
toks <- tokens_lookup(toks, 
                      dictionary = data_dictionary_uk2us, 
                      exclusive = FALSE, 
                      capkeys = FALSE)
# Remove specific n-grams
toks <- tokens_remove(toks, pattern = phrase(c("united states",
                                               "applause"))) # what else?

# Initial DFM
fullcorpus.dfm <- dfm(toks, 
                      tolower = TRUE, 
                      remove_punct = TRUE, 
                      remove_numbers = TRUE, 
                      remove_symbols = TRUE, 
                      remove_url = TRUE)
# Remove stopwords + additional common irrelevant terms
custom_stopwords <- c(stopwords("en",
                                source = "stopwords-iso"), 
                      "also", "one", "two", "three", "can") # what else?
fullcorpus.dfm <- dfm_remove(fullcorpus.dfm,
                             custom_stopwords)
topfeatures(fullcorpus.dfm, n = 300)
# Look at the dfm and see what prevalent terms you should remove

# Lemmatization (instead of stemming)
lemmas <- unique(tolower(unlist(toks)))
lemmas <- data.table(words = lemmas,
                     lemmas = lemmatize_words(lemmas))
fullcorpus.dfm <- dfm_replace(fullcorpus.dfm, 
                              pattern = lemmas$words, 
                              replacement = lemmas$lemmas, 
                              case_insensitive = TRUE)

# Trim rare/common words
# Think about what we mean by topics:
# If it is too common, it is not useful
# if it is too rare, it is not useful either
fullcorpus_trimed <- dfm_trim(fullcorpus.dfm, 
                              min_docfreq = 0.01, 
                              max_docfreq = 0.99, 
                              docfreq_type = "prop")

# Convert for STM
fullcorpus_trimed_stm <- convert(fullcorpus_trimed,
                                 to = "stm")

# Search for optimal K
set.seed(12345) # set a seed for reproducibility
k_search <- searchK(documents = fullcorpus_trimed_stm$documents, 
                    vocab = fullcorpus_trimed_stm$vocab, 
                    data = fullcorpus_trimed_stm$meta, 
                    prevalence = ~ Party + s(Year), # theoretically, what variables will influence your topic prevalence?
                    K = seq(5, 20, 5), # search for K (the number of topics) from 5 to 40, with increments of 5
                    max.em.its = 75, # maximum number of iterations to find the best model for a specific K
                    cores = 1) # How many PC/Mac cores you want to use for parallel processing
# It will take some time to run this

# Plot coherence vs. exclusivity
diagnostics_df <- data.frame(
  K = unlist(k_search$results$K),
  Coherence = unlist(k_search$results$semcoh),
  Exclusivity = unlist(k_search$results$exclus)
)
ggplot(diagnostics_df, aes(x = K)) +
  geom_line(aes(y = Coherence), color = "steelblue") +
  geom_line(aes(y = Exclusivity), color = "darkorange") +
  labs(
    title = "Model Diagnostics",
    x = "Number of Topics (K)",
    y = "Score"
  ) +
  theme_minimal()

# Fit final model with selected K
# Let's say you think K=10 is the best
set.seed(12345)
mod <- stm(documents = fullcorpus_trimed_stm$documents, 
           vocab = fullcorpus_trimed_stm$vocab, 
           data = fullcorpus_trimed_stm$meta, 
           prevalence = ~ Party + s(Year), 
           K = 10)

# Label topics
labelTopics(mod)
# Think:
# 1. What labels would you give to these topics?
# 2. Are there any topics that are too similar to each other?
# 3. Should we increase the number of topics (K) or decrease it?

# Estimate effects
prep <- estimateEffect(1:10 ~ s(Year), 
                       mod, 
                       meta = fullcorpus_trimed_stm$meta)
# Plot topic trends over time
plot.estimateEffect(prep,
                    covariate = "Year",
                    method = "continuous",
                    topics = 1:10, # or you can specific one specific topic
                    model = mod,
                    xlab = "Year",
                    ylab = "Topic Prevalence",
                    main = "Topic Trends Over Time")

# Save model
saveRDS(mod, "stm_presidential_speeches.rds")
# Since it takes a long time to run, you can save the model and load it later :)
