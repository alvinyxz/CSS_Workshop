# This R script trains a text classifier to detect uncivil comments.
# Open comments_train.csv and comments_test.csv to have a look at what the data look like

# ================================
# 1. Install and load required packages
# ================================
# Run these lines only once. If you've installed the packages already, skip them.
# install.packages("tidyverse")   # Data wrangling
# install.packages("tidytext")    # Text processing
# install.packages("caret")       # Machine learning
# install.packages("tm")          # Text mining

library("tidyverse")
library("tidytext")
library("caret")
library("tm")

# ================================
# 2. Read in your data
# ================================
labeled_df <- read_csv("comments_labeled.csv")
test_df <- read_csv("comments_test.csv")

# Peek at the data structure
head(labeled_df, 5)  # View first 5 rows of training data
# You can see that the 1st, 4th, and 5th comments are uncivil (1)
# Supervised machine learning has to have some training data that are correctly labeled (by human)
head(test_df, 5)   # View first 5 rows of test data
# We will apply our selected model to this data in the end
print(paste("Training set size:", nrow(labeled_df)))   # Should be 600
print(paste("Test set size:", nrow(test_df)))          # Should be 1500

# How many civil (0) vs uncivil (1) comments in training set?
table(labeled_df$label)
# This should show a 50%/50% balanced distribution between civil (0) and uncivil (1) comments
# Which is not common: most datasets are imbalanced
# In those cases, you would need to use techniques like
# oversampling, undersampling, or using specialized algorithms that handle imbalance.
# You can read: https://www.analyticsvidhya.com/blog/2016/03/practical-guide-deal-imbalanced-classification-problems/

# ================================
# 3. Convert label to a categorical variable
# ================================
labeled_df$label <- as.factor(labeled_df$label)

# Add an ID column to keep track of comments
labeled_df$id <- 1:nrow(labeled_df)

# ================================
# 4. Process the text data
# ================================
# Turn text into individual words (called tokens), remove stopwords, and calculate TF-IDF
text_tokens <- labeled_df %>%
  unnest_tokens(word, text, token = "words") %>%  # Tokenize the text into words
  anti_join(stop_words, by = "word") %>%          # Remove common stopwords (like "the", "is", etc.)
  count(id, word, sort = TRUE) %>%                # Count how many times each word appears in each comment
  bind_tf_idf(word, id, n)                        # Calculate TF-IDF (Term Frequency-Inverse Document Frequency)

# Take a look at text_tokens
text_tokens
# $n means the number of times a word appears in the labeled_df
# $tf means "term frequency", which is how often a word appears in one document
# for the first word "die", the 0.788 means that it the 245th comment (the "id" shows that this is the 245th comment)
# "die" takes up 78.8% of the words
# Damn, now I am curious what the comment actually is! Let's see:
labeled_df$text[labeled_df$id == 245]
# Ouch...
text_tokens
# Then, idf means "inverse document frequency", which is a measure of
# how common or rare a word is across all documents
# The higher the idf, the more unique the word is to that document
# To calculate idf, we take the total number of documents (in this case, 600)
# and divide it by the number of documents that contain the word, and do a log transformation
# check how many document contains the word "die"
sum(text_tokens$word == "die")  # Should be 8, because it is a relatively unique word in this dataset
# so the idf for "die" is log(600/8) = 4.31
# The tf_idf column is the product of tf and idf
# which, for "die", is 0.788 * 4.31 = 3.40

# ================================
# 5. Create the document-term matrix (DTM)
# ================================
# A DTM is a matrix where each row is a comment and each column is a word
train_dtm <- text_tokens %>%
  cast_dtm(id, word, tf_idf)

# Too see how the DTM looks like, we can convert it to a matrix and then to a data frame
train_dtm_preview <- as.data.frame(as.matrix(train_dtm))
# View a few rows and columns
train_dtm_preview[1:5, 1:10]
# we will not use the train_dtm_preview object, it is just here to show you how the DTM looks like

# ================================
# 6. Match each comment ID with its label
# ================================
meta <- tibble(id = as.numeric(dimnames(train_dtm)[[1]])) %>%
  left_join(labeled_df %>% select(id, label), by = "id")

head(meta)
# this meta object shows you that the 245th comment is considered uncivil (1)
# and the 31st comment is considered civil (0)

# ================================
# 7. Split data into training and testing
# ================================
set.seed(2025)  # Makes results reproducible
# Create a partition of the data: 80% for training, 20% for testing
train_index <- createDataPartition(meta$label, p = 0.8, list = FALSE)

# Training set
data_to_train <- train_dtm[train_index, ] %>% as.matrix() %>% as.data.frame()
labels_train <- meta$label[train_index]
View(data_to_train)
dim(data_to_train)
# 479 rows, 4914 columns; which means:
# 479 comments used to train our classifier, each comment represented by 4914 words/features/tokens

# Testing set
data_to_test <- train_dtm[-train_index, ] %>% as.matrix() %>% as.data.frame()
labels_test <- meta$label[-train_index]
View(data_to_test)
dim(data_to_test)
# 119 rows, 4914 columns; which means:
# 119 comments will be used to test how well our classifier performs, each comment is also represented by 4914 words/features/tokens

# ================================
# 8. Train Classifiers
train_control <- trainControl(method = "boot")
# Bootstrapping is a resampling method that helps estimate the model's performance
# You can ignore what Bootstrapping is for now
# ================================

# ================================
# 8.1. Logistic regression
# A common, simple classification model
# ================================

logistic_model <- train(x = data_to_train, # training data
                        y = labels_train,  # those training data's (correct) labels
                        method = "regLogistic", # the algorithm
                        trControl = train_control)
# Look at model results
print(logistic_model)
# The above training actually tests all kinds of logistic regression parameters (L1/L2 epsilon)
# And automatically selects the best one based on the training data

# Applying the model to the test data and see how good it performs
logistic_predict <- predict(logistic_model, newdata = data_to_test)
results <- confusionMatrix(logistic_predict, labels_test, mode = "prec_recall")
print(results)

# ================================
# 8.2. K-Nearest Neighbors (KNN)
# A simple, intuitive classification model
# ================================

knn_model <- train(x = data_to_train, # training data
                   y = labels_train, # labeled data
                   method = "knn", # the algorithm
                   trControl = train_control)
print(knn_model)
# The above training actually tests all kinds of KNN parameters (K, e.g., how many neighbors to consider)
# And automatically selects the best one based on the training data
knn_predict <- predict(knn_model, newdata = data_to_test)
results <- confusionMatrix(knn_predict, labels_test, mode = "prec_recall")
print(results)

# ================================
# 8.3. Support Vector Machine (SVM)
# A powerful classification model that works well with high-dimensional data
# ================================

svm_model <- train(x = data_to_train,
                   y = labels_train,
                   method = "svmLinear3",
                   trControl = train_control) # accounts for misclassifications
print(svm_model)
# The above training actually tests all kinds of SVM parameters (cost, loss)
# And automatically selects the best one based on the training data
svm_predict <- predict(svm_model, newdata = data_to_test)
results <- confusionMatrix(svm_predict, labels_test, mode = "prec_recall")
print(results)

# ================================
# 8.4. Random Forest
# An ensemble method that combines multiple decision trees for better accuracy
# ================================

rf_model <- train(x = data_to_train,
                  y = labels_train,
                  method = "ranger",
                  trControl = train_control,
                  tuneGrid = data.frame(mtry = floor(sqrt(dim(data_to_train)[2])),
                                        splitrule = "extratrees",
                                        min.node.size = 5))
# The tuneGrid specify the number of variables randomly sampled at each split
# tuneGrid can also be used for logistic_model, knn_model, and svm_model above
# Remember how when running logistic_model, knn_model, and svm_model
# We actually created many many models, and the computer picked one automatically for us?
# This tuneGrid function basically tells it which model we want, which saves time
# If you don't include it, the above code will take an hour to run, where the computer
# Tries out all different kinds of random forest parameters
print(rf_model)
rf_predict <- predict(rf_model, newdata = data_to_test)
results <- confusionMatrix(rf_predict, labels_test, mode = "prec_recall")
print(results)

# So now, we have trained four different classifiers:
# 1. Logistic Regression
# 2. K-Nearest Neighbors (KNN)
# 3. Support Vector Machine (SVM)
# 4. Random Forest
# Based on the results, which model do you think performs the best?







# ================================
# 9. Apply the selected model to the test data [OPTIONAL]
# Once you decide which model to use
# We can apply that classification model to the test_df dataset
final_model <- rf_model
# Replace with the model you want to use (e.g., logistic_model, knn_model, svm_model, or rf_model)
# ================================

# Step 1: Add an ID column to test_df so we can track rows
test_df$id <- 1:nrow(test_df)
# Step 2: Tokenize and process test_df the same way we did with the training data
test_tokens <- test_df %>%
  unnest_tokens(word, text, token = "words") %>%
  anti_join(stop_words, by = "word") %>%
  count(id, word, sort = TRUE) %>%
  bind_tf_idf(word, id, n)
# Step 3: Create document-term matrix for test_df
test_dtm <- test_tokens %>%
  cast_dtm(id, word, tf_idf)
# Step 4: Convert test_dtm to data frame for prediction
test_dtm_df <- as.data.frame(as.matrix(test_dtm))
# Step 5: Align test_dtm_df with training feature set
train_features <- colnames(data_to_train)
# You should know that features/tokens from labeled_df is different from those in test_df
# Therefore, we need to ensure that the test data has the same features as the training data
# And we will ignore any features that are not present in the training data
missing_features <- setdiff(train_features, colnames(test_dtm_df))
# Add missing features (columns) with zeros
for (col in missing_features) {
  test_dtm_df[[col]] <- 0
}
# Drop any extra columns not seen during training
test_dtm_df <- test_dtm_df[, intersect(colnames(test_dtm_df), train_features)]
# Reorder columns to match training feature order
test_dtm_df <- test_dtm_df[, train_features]
# Predict using aligned test set
test_predictions <- predict(final_model, newdata = test_dtm_df)
# Grab the IDs from test_dtm_df (these are the ones that survived preprocessing)
# Some comments may not have any words left after preprocessing (e.g., all are stopwords)
# so we need to keep track of IDs
test_ids <- as.integer(rownames(test_dtm_df))
# Combine predictions with IDs
predictions_df <- tibble(id = test_ids, predicted_label = test_predictions)
# Merge with test_df (safe join)
test_results <- test_df %>%
  mutate(id = row_number()) %>%
  left_join(predictions_df, by = "id") %>%
  select(id, predicted_label, text)
# Save result
write_csv(test_results, "comments_test_predictions_R.csv")
# Done! You now have a file with predicted labels for new comments.
# Open it, and see if the labels make sense.
# You will find some are misclassified, but many are correct (hopefully).
