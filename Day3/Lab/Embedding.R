# Step 1: Install necessary packages
install.packages("text2vec")
install.packages("devtools")
devtools::install_github("bmschmidt/wordVectors")
install.packages("tidyverse")

# Step 2: Load required libraries
library("text2vec")
library("wordVectors")
library("tidyverse")

# Step 3: Download pre-trained Word2Vec model (GloVe or FastText can be loaded similarly)
# The popular Google News Word Embedding model is called GoogleNews-vectors-negative300.bin
# The file is big, around 1.6GB
# We will use its slim version: https://github.com/eyaler/word2vec-slim
# Go to the Github, download the file: https://github.com/eyaler/word2vec-slim/blob/master/GoogleNews-vectors-negative300-SLIM.bin.gz
# Unzip the file to get GoogleNews-vectors-negative300-SLIM.bin

# Step 4: Load pre-trained Word2Vec model into R
model <- read.vectors("GoogleNews-vectors-negative300-SLIM.bin", binary = TRUE)

# Step 5: Explore the loaded model
summary(model)
head(rownames(model)) # View some of the words in the embedding

# Step 6: Find similar words
similar_words <- closest_to(model, "king")
print(similar_words)

# Step 7: Compute analogy (e.g., king - man + woman = ?)
analogy_result <- closest_to(model,  ~"king"-"man"+"woman")
print(analogy_result)
analogy_result <- closest_to(model,  ~"guy"-"man"+"woman")
print(analogy_result)

# Step 8: Visualizing word embeddings using t-SNE and ggplot2
library("Rtsne")
library("ggplot2")

# Select a few words to visualize
words_to_plot <- model[c("king",
                         "queen",
                         "man",
                         "woman",
                         "dog",
                         "cat",
                         "house",
                         "apartment",
                         "undergraduate",
                         "graduate"), ]
words_matrix <- as.matrix(words_to_plot)

# Perform t-SNE dimensionality reduction
tsne_model <- Rtsne(words_matrix, dims = 2, perplexity = 2)

# Create a dataframe for ggplot
tsne_df <- data.frame(x = tsne_model$Y[, 1], y = tsne_model$Y[, 2], word = rownames(words_to_plot))

# Plot using ggplot2
ggplot(tsne_df, aes(x, y, label = word)) + 
  geom_text(size = 5) + 
  ggtitle("Word Embeddings t-SNE Visualization") +
  theme_minimal()
