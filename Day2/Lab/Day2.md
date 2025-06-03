# Day 2

Welcome to Day 2 of the CSS Workshop lab session. Today we’ll get hands-on with common dictionary-based approaches to text analysis. The focus is on learning to work with and interpret structured lexical categories.

## LIWC

Open `LIWC.R`, we'll start by exploring pre-processed LIWC scores from U.S. presidential speeches with this file:

You will:

1. Watch this video about how to use the point-and-click LIWC: [LIWC Video](https://www.youtube.com/watch?v=IGBI8LnYGNs)
2. **Read the assigned LIWC reading** from Tausczik & Pennebaker (2010) to understand what LIWC is and how it works. The Tausczik 2010.pdf file is available in this same directory.
   - **Key points to focus on**:
     - What is LIWC?
     - How does it categorize language?
     - What are some common categories and their meanings?
     - How can LIWC scores be interpreted in the context of political speeches?
3. **Load and explore the file** `presidential_speeches_LIWC.csv`. LIWC costs money (although not a lot), so I have processed the presidential_speeches.csv data that we used in Day 1 to generate LIWC scores. The file contains LIWC scores for various speeches by U.S. presidents.
4. **Interpret LIWC variables**, such as self-focus (“i”), positive/negative emotion, and other categories.
5. **Answer interpretive questions** such as:
   - Which president uses self-focus “I” the most?
   - Who is the most positive?
   - Which party is more positive?
   - How do positivity and negativity evolve over time?
   - What categories show the largest partisan difference?

## Sentiment Analysis

Open `Sentiment.R`, where we’ll walk through several dictionary-based sentiment analysis approaches using the raw speech text (`presidential_speeches.csv`).

You will:
1. **Load and preview** the presidential speeches dataset.
2. **Learn about three popular sentiment dictionaries** included in the `tidytext` package:
   - **Bing**: Categorizes words into positive or negative.
   - **AFINN**: Assigns a sentiment score ranging from -5 to +5.
   - **NRC**: Labels words with emotions like anger, joy, fear, sadness, etc.
3. **Try analyzing a single speech** first (e.g., Trump’s address) using the Bing lexicon.
   - Tokenize it into words.
   - Match the words with sentiment labels.
   - Count and compare how many positive vs. negative words were used.
4. **Apply sentiment analysis to all speeches** in the dataset.
   - Tokenize all speeches.
   - Join with the Bing dictionary.
   - Count and subtract negative from positive words to calculate a sentiment score per speech.
   - Merge the result back to the original dataset.
   - Interpret:
     - Who’s most positive?
     - Does positivity differ by party?
     - Over time?
5. **Explore other methods** with the `Syuzhet` and `SentimentAnalysis` packages on your own.

## Classification

In this section, we will learn how to classify comments as either uncivil (1) or civil (0) using supervised machine learning in R.

We’ll use a small labeled set of 600 political comments:
- 300 comments are labeled as civil
- 300 comments are labeled as uncivil
- These comments are labeled by human annotators (ground-truth)
- We will use 80% of these comments for training and 20% for testing our models in our `R` script
- This file is available as `comments_labeled.csv`

Once we train our models, we will apply them to a larger set of 1500 unlabeled comments to predict their labels. This file is available as `comments_test.csv`.

Our focus will be on understanding the core concepts behind text classification, how to process text into features that a machine can learn from, and how to compare the performance of multiple classification models.

We’ll walk through the full text classification workflow:
1. Load and explore labeled and unlabeled data
2. Preprocess text: tokenize, remove stopwords, and calculate TF-IDF scores
3. Create a document-term matrix (DTM) to convert text into numeric input
4. Split the labeled data into training (80%) and test (20%) sets
5. Train multiple models using the caret package:
   - Logistic Regression (regLogistic)
   - K-Nearest Neighbors (KNN)
   - Support Vector Machine (SVM) (svmLinear3)
   - Random Forest (ranger)
6. Evaluate model performance using accuracy, F1 score, and confusion matrices
7. Compare models to decide which one performs best
8. Optionally, predict the labels for the 1,500 new, unlabeled comments

Open the file `Classification.R` and follow along in RStudio.

## Google Perspective API

Tomorrow, we will explore the Google Perspective API, which provides a way to analyze text for various attributes like toxicity, politeness, and more.

To prepare, please read the documentation here: [Google Perspective API Documentation](https://developers.perspectiveapi.com/). But more importantly, please **sign up for an API key**, it takes time to get approved:

- Go to https://www.perspectiveapi.com/
- Apply for the API
- It takes a few hours to get this API access
- We will use it in the next lab