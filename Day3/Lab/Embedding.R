# ====================================================
# Step 1: Install required packages
# ====================================================

if (!require("tidyverse")) install.packages("tidyverse")
if (!require("text2vec")) install.packages("text2vec")
if (!require("Rtsne")) install.packages("Rtsne")
if (!require("ggplot2")) install.packages("ggplot2")

# ====================================================
# Step 2: Download pre-trained GloVe embeddings
# ====================================================

# Go to https://nlp.stanford.edu/data/glove.6B.zip
# Download the zip file
# Then extract it
# There are multiple models in the folder
# Let's move glove.6B.300d.txt to your working directory

# ====================================================
# Step 3: Load pre-trained GloVe vectors into R
# ====================================================

# Load the GloVe 100-dimensional embedding
glove_embeddings <- read_delim("glove.6B.300d.txt",
                               delim = " ", quote = "", col_names = FALSE)
# The first column is the word, the rest are vector values
word_vectors <- as.matrix(glove_embeddings[, -1])
rownames(word_vectors) <- glove_embeddings[[1]]
# You now have a word embedding matrix: rows = words, columns = dimensions

# ====================================================
# Step 4: Explore the loaded model
# ====================================================

# How many words and dimensions
# You have 400000 words, each word is represented by a 300-dimensional vector (i.e., 300 numbers)
print(dim(word_vectors))
# View a random sample of 20 words in the embedding
sample(rownames(word_vectors), 50)

# ====================================================
# Step 5: Find similar words
# ====================================================

# Example: words similar to "king"
king_vec <- word_vectors["king", , drop = FALSE]
# Compute "King"'s cosine similarity with other words
similar_words <- sim2(word_vectors, king_vec, method = "cosine", norm = "l2")
# Sort by similarity and show top 10 similar words
head(sort(similarities[,1], decreasing = TRUE), 10)

# ====================================================
# Step 6: Compute analogies
# ====================================================

# Word algebra: king - man + woman ≈ queen
analogy_vec <- word_vectors["king", ] - word_vectors["man", ] + word_vectors["woman", ]
analogy_result <- sim2(word_vectors, matrix(analogy_vec, nrow = 1), method = "cosine", norm = "l2")
head(sort(analogy_result[,1], decreasing = TRUE), 10)

# More analogies (some of them might not be perfect)
analogy_vec <- word_vectors["guy", ] - word_vectors["man", ] + word_vectors["woman", ]
print(head(sort(sim2(word_vectors, matrix(analogy_vec, nrow = 1), method = "cosine")[,1], decreasing = TRUE), 10))

analogy_vec <- word_vectors["china", ] - word_vectors["beijing", ] + word_vectors["tokyo", ]
print(head(sort(sim2(word_vectors, matrix(analogy_vec, nrow = 1), method = "cosine")[,1], decreasing = TRUE), 10))

analogy_vec <- word_vectors["tokyo", ] - word_vectors["japan", ] + word_vectors["germany", ]
print(head(sort(sim2(word_vectors, matrix(analogy_vec, nrow = 1), method = "cosine")[,1], decreasing = TRUE), 10))

# ====================================================
# Step 7: Compute similarity between two words
# ====================================================

sim2(word_vectors["beijing", , drop = FALSE],
     word_vectors["china", , drop = FALSE],
     method = "cosine")
sim2(word_vectors["beijing", , drop = FALSE],
     word_vectors["chair", , drop = FALSE],
     method = "cosine")
# You can see that "beijing" is more similar to "china" than to "chair"

# ====================================================
# Step 8: Visualize word embeddings with t-SNE
# ====================================================

# Pick some words to visualize
words_to_plot <- c("king", "queen", "man", "woman",
                   "dog", "cat", "house", "apartment",
                   "undergraduate", "graduate")
# Extract their vectors
word_matrix <- word_vectors[words_to_plot, ]
# You can print out the matrix to see the vectors
print(word_matrix)
# Run t-SNE (dimensionality reduction to 2D)
tsne_result <- Rtsne(word_matrix, dims = 2, perplexity = 2)
# Create data frame for plotting
tsne_df <- data.frame(x = tsne_result$Y[,1],
                      y = tsne_result$Y[,2],
                      word = words_to_plot)
# Plot using ggplot2
ggplot(tsne_df, aes(x = x, y = y, label = word)) +
  geom_text(size = 5) +
  ggtitle("t-SNE Visualization of Word Embeddings") +
  theme_minimal()

# Below, we are going to train our own GloVe model on a small corpus [OPTIONAL]

# ====================================================
# Step 9: Create a small example corpus
# ====================================================

# Let's simulate our own mini "corpus" (i.e., collection of text)
# We'll train a GloVe model from scratch on this toy dataset
text <- c("The cat sits on the mat",
          "The dog lies on the rug",
          "Dogs and cats are great")
# This is obviously a very small example — just enough to demonstrate the mechanics.
# In real applications, you'd use a large set of documents.
# Google uses billions of words to train their models!

# ====================================================
# Step 10: Tokenize the text
# ====================================================

# Convert to lowercase and split each sentence into words (tokens)
tokens <- text %>%
  tolower() %>%
  space_tokenizer()
# Each sentence is now a list of individual words
print(tokens)

# ====================================================
# Step 11: Create vocabulary and term co-occurrence matrix
# ====================================================

# Turn the tokens into an iterator — a stream of tokenized docs
it <- itoken(tokens, progressbar = FALSE)
# Build a vocabulary: just a list of all words in the corpus
vocab <- create_vocabulary(it)
# Create a vectorizer using the vocabulary
vectorizer <- vocab_vectorizer(vocab)
# Create a term co-occurrence matrix (TCM)
# This matrix captures how often each word appears near others
# The window size determines the range of "context" around each word
tcm <- create_tcm(it, vectorizer, skip_grams_window = 5L)

# ====================================================
# Step 12: Train a GloVe model on this toy corpus
# ====================================================

# Initialize GloVe
# Here, rank = "dimensionality of embeddings"
# rank = 50 means each word will be represented by a 50-dimensional vector (e.g., 50 numbers)
# x_max = weighting cap; You can ask ChatGPT for more details :)
glove <- GlobalVectors$new(rank = 50, x_max = 10)
# Fit the model to the term co-occurrence matrix
# n_iter controls how many training rounds to run (more = better but slower)
word_vectors <- glove$fit_transform(tcm, n_iter = 20)
# The GloVe model gives us two types of embeddings: word vectors and context vectors
# We add them together to get the final representation
context_vectors <- glove$components
word_vectors_final <- word_vectors + t(context_vectors)

# ====================================================
# Step 13: Explore relationships in the learned embeddings
# ====================================================

# For example: find words similar to "cat"
cat_vec <- word_vectors_final["cat", , drop = FALSE]
# Compute cosine similarity between "cat" and all other words
similarity_scores <- sim2(word_vectors_final, cat_vec, method = "cosine")
# Show top 5 most similar words
head(sort(similarity_scores[,1], decreasing = TRUE), 5)
# Based on our tiny corpus, "cat" is more similar to "the" than "dogs"

# ====================================================
# Step 14: Visualize the embeddings with t-SNE
# ====================================================

# Pick a few words from the tiny vocabulary to visualize
words_to_plot <- c("cat", "dog", "dogs", "cats", "mat", "rug", "great")
# Extract their vectors
word_matrix <- word_vectors_final[words_to_plot, ]
# Run t-SNE to reduce 50D vectors into 2D for plotting
tsne <- Rtsne(word_matrix, dims = 2, perplexity = 2)
# Create dataframe for ggplot
tsne_df <- data.frame(x = tsne$Y[,1],
                      y = tsne$Y[,2],
                      word = words_to_plot)
# Plot the result
ggplot(tsne_df, aes(x = x, y = y, label = word)) +
  geom_text(size = 5) +
  ggtitle("t-SNE of Custom Trained Word Embeddings") +
  theme_minimal()
# Not good, but expected, we are literally training on a toy dataset
