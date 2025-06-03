# https://tutorials.quanteda.io/basic-operations/fcm/fcm/

# This script processes three datasets (Congress, Agency, Hospital) and builds semantic networks
# using the quanteda package in R.

# Load necessary libraries
if (!require("quanteda")) install.packages("quanteda")                     # Text processing
if (!require("quanteda.textplots")) install.packages("quanteda.textplots") # Visualizing semantic networks
if (!require("quanteda.textstats")) install.packages("quanteda.textstats") # Co-occurrence and term statistics
if (!require("lexicon")) install.packages("lexicon")                       # For lemmatization
if (!require("ggplot2")) install.packages("ggplot2")                       # For visualization

### PROCESS CONGRESS DATASET ###

# Load Congress data
Congress <- read.csv("Congress.csv")
# Explore the dataset
head(Congress)
names(Congress)
# Important Columns:
# docn: The numeric label of the document
# cleanedtext: The cleaned text of the document
# Message: The original message text
# Likes: The number of likes the post received
# Comments: The number of comments the post received
# Shares: The number of shares the post received
# Love: The number of love reactions the post received
# ...

# Create corpus and incorporate some document variables
Corpus_Congress <- corpus(Congress$cleanedtext,
                          docvars = Congress[, c("Page.Name",
                                                 "User.Name",
                                                 "Facebook.Id",
                                                 "Post.Created",
                                                 "Comments",
                                                 "Shares")])

# Tokenize and clean
Corpus_Congress_tokens <- tokens(Corpus_Congress,
                                 what = "word",
                                 remove_punct = TRUE,      # remove punctuation
                                 remove_symbols = TRUE,    # remove symbols
                                 remove_numbers = TRUE,    # remove numbers
                                 remove_url = TRUE,        # remove URLs
                                 remove_separators = TRUE, # remove separators
                                 split_hyphens = TRUE) %>% # split hyphens
  tokens_tolower() %>% # convert to lowercase
  tokens_remove(pattern = stopwords("en")) %>% # remove English stopwords
  tokens_replace(pattern = lexicon::hash_lemmas$token, # lemmatization
                 replacement = lexicon::hash_lemmas$lemma) %>%
  tokens_remove(c("de", "also", "may", "include", "can", # you can custom words to remove here
                  "p.m", "a.m", "va", "st", "pm", "datum",
                  "covid", "vaccination", "vaccinate", "vaccine", "coronavirus",
                  "2")) %>%
  tokens_replace(pattern = "numb", replacement = "number") # you can also replace specific patterns

# Build document-feature-matrix and compute top features
Corpus_Congress_dfm <- Corpus_Congress_tokens %>%
  dfm()
topfeatures_Congress <- textstat_frequency(Corpus_Congress_dfm, n = 75)
topfeatures_Congress
topfeatures_Congress_features <- topfeatures_Congress$feature

# Build co-occurrence matrix (FCM: Feature Co-occurrence Matrix)
Corpus_Congress_tokens_fcm <- fcm(Corpus_Congress_tokens,
                                  context = "document",
                                  tri = FALSE) # tri = FALSE means we are not considering tri-grams
# We are not going to visualize the whole network, we are only interested in the top features:
Corpus_Congress_tokens_fcm_trimmed <- fcm_select(Corpus_Congress_tokens_fcm,
                                                 pattern = topfeatures_Congress_features)

# Plot and save network
set.seed(123) # for reproducibility
pdf("Congress_Network.pdf", width = 10, height = 10)
textplot_network(Corpus_Congress_tokens_fcm_trimmed,
                 min_freq = 0.5,
                 edge_alpha = 0.25,
                 edge_size = 2)
dev.off()

# Plot top 50 words as a bar chart
top50_Congress <- textstat_frequency(Corpus_Congress_dfm, n = 50)
ggplot(top50_Congress,
       aes(x = reorder(feature,
                       frequency),
           y = frequency)) +
  # reorder the words by frequency,
  # so that the most frequent words appear at the top
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 50 Words in Congress Posts",
       x = "Words", y = "Frequency") +
  theme_minimal()
ggsave("Congress_Top50.pdf",
       plot = last_plot(),
       width = 10,
       height = 8)

### PROCESS AGENCY DATASET ###

# Load Agency data
Agency <- read.csv("Agency.csv")
# Explore the dataset
head(Agency)
names(Agency)

# Create corpus and incorporate some document variables
Corpus_Agency <- corpus(Agency$cleanedtext,
                        docvars = Agency[, c("Page.Name",
                                             "User.Name",
                                             "Facebook.Id",
                                             "Post.Created",
                                             "Comments",
                                             "Shares")])

# Tokenize and clean
Corpus_Agency_tokens <- tokens(Corpus_Agency,
                               what = "word",
                               remove_punct = TRUE,
                               remove_symbols = TRUE,
                               remove_numbers = TRUE,
                               remove_url = TRUE,
                               remove_separators = TRUE,
                               split_hyphens = TRUE) %>%
  tokens_tolower() %>%
  tokens_remove(pattern = stopwords("en")) %>%
  tokens_replace(pattern = lexicon::hash_lemmas$token,
                 replacement = lexicon::hash_lemmas$lemma) %>%
  tokens_remove(c("de", "also", "may", "include", "can",
                  "p.m", "a.m", "va", "st", "pm", "datum",
                  "covid", "vaccination", "vaccinate", "vaccine", "coronavirus",
                  "2")) %>%
  tokens_replace(pattern = "numb", replacement = "number")

# Build document-feature-matrix and compute top features
Corpus_Agency_dfm <- Corpus_Agency_tokens %>%
  dfm()
topfeatures_Agency <- textstat_frequency(Corpus_Agency_dfm, n = 75)
topfeatures_Agency
topfeatures_Agency_features <- topfeatures_Agency$feature

# Build co-occurrence matrix (FCM)
Corpus_Agency_tokens_fcm <- fcm(Corpus_Agency_tokens,
                                context = "document",
                                tri = FALSE)
Corpus_Agency_tokens_fcm_trimmed <- fcm_select(Corpus_Agency_tokens_fcm,
                                               pattern = topfeatures_Agency_features)

# Plot and save network
set.seed(123) # for reproducibility
pdf("Agency_Network.pdf", width = 10, height = 10)
textplot_network(Corpus_Agency_tokens_fcm_trimmed,
                 min_freq = 0.5,
                 edge_alpha = 0.25,
                 edge_size = 2)
dev.off()

# Plot top 50 words as a bar chart
top50_Agency <- textstat_frequency(Corpus_Agency_dfm, n = 50)
ggplot(top50_Agency,
       aes(x = reorder(feature,
                       frequency),
           y = frequency)) +
  # reorder the words by frequency,
  # so that the most frequent words appear at the top
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 50 Words in Agency Posts",
       x = "Words", y = "Frequency") +
  theme_minimal()
ggsave("Agency_Top50.pdf",
       plot = last_plot(),
       width = 10,
       height = 8)

### PROCESS HOSPITAL DATASET ###

# Load Hospital data
Hospital <- read.csv("Hospital.csv")
# Explore the dataset
head(Hospital)
names(Hospital)

# Create corpus and incorporate some document variables
Corpus_Hospital <- corpus(Hospital$cleanedtext,
                          docvars = Hospital[, c("Page.Name",
                                                 "User.Name",
                                                 "Facebook.Id",
                                                 "Post.Created",
                                                 "Comments",
                                                 "Shares")])

# Tokenize and clean
Corpus_Hospital_tokens <- tokens(Corpus_Hospital,
                                 what = "word",
                                 remove_punct = TRUE,
                                 remove_symbols = TRUE,
                                 remove_numbers = TRUE,
                                 remove_url = TRUE,
                                 remove_separators = TRUE,
                                 split_hyphens = TRUE) %>%
  tokens_tolower() %>%
  tokens_remove(pattern = stopwords("en")) %>%
  tokens_replace(pattern = lexicon::hash_lemmas$token,
                 replacement = lexicon::hash_lemmas$lemma) %>%
  tokens_remove(c("de", "also", "may", "include", "can",
                  "p.m", "a.m", "va", "st", "pm", "datum",
                  "covid", "vaccination", "vaccinate", "vaccine", "coronavirus",
                  "2")) %>%
  tokens_replace(pattern = "numb", replacement = "number")

# Build document-feature-matrix and compute top features
Corpus_Hospital_dfm <- Corpus_Hospital_tokens %>%
  dfm()
topfeatures_Hospital <- textstat_frequency(Corpus_Hospital_dfm, n = 75)
topfeatures_Hospital
topfeatures_Hospital_features <- topfeatures_Hospital$feature

# Build co-occurrence matrix (FCM)
Corpus_Hospital_tokens_fcm <- fcm(Corpus_Hospital_tokens,
                                  context = "document",
                                  tri = FALSE)
Corpus_Hospital_tokens_fcm_trimmed <- fcm_select(Corpus_Hospital_tokens_fcm,
                                                 pattern = topfeatures_Hospital_features)

# Plot and save network
set.seed(123) # for reproducibility
pdf("Hospital_Network.pdf", width = 10, height = 10)
textplot_network(Corpus_Hospital_tokens_fcm_trimmed,
                 min_freq = 0.5,
                 edge_alpha = 0.25,
                 edge_size = 2)
dev.off()

# Plot top 50 words as a bar chart
top50_Hospital <- textstat_frequency(Corpus_Hospital_dfm, n = 50)
ggplot(top50_Hospital,
       aes(x = reorder(feature,
                       frequency),
           y = frequency)) +
  # reorder the words by frequency,
  # so that the most frequent words appear at the top
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 50 Words in Hospital Posts",
       x = "Words", y = "Frequency") +
  theme_minimal()
ggsave("Hospital_Top50.pdf",
       plot = last_plot(),
       width = 10,
       height = 8)
