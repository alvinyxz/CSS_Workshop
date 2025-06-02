# Day 3

Welcome to Day 3 of the CSS Workshop! Today we will apply text-as-data techniques that go beyond keyword counting. You’ll explore the meaning of words through vector space (embeddings), assess online toxicity using a machine learning API, and analyze latent topical structures using Structural Topic Modeling (STM).

All exercises today use **`presidential_speeches.csv`**, and we strongly encourage you to complete both the **R and Python versions** to strengthen your bilingual coding fluency.

## Word Embeddings

We start by visualizing and interpreting word meaning using pretrained word vectors (GloVe) and some local models.

- **Files:**
  - `Embedding.ipynb`
  - `Embedding.R`

- **You will learn to:**
  - Load pretrained embeddings
  - Find semantically similar words
  - Visualize word relationships (e.g., PCA, cosine similarity)
  - Reflect on what it means for a model to “understand” language

## Google Perspective API: Toxicity Detection

Next, we’ll experiment with Google’s Perspective API to score political speeches for toxicity, both as a single sentence and in bulk.

- **Files:**
  - `Google_Perspective.ipynb`
  - `Google_Perspective.R`

- **You will learn to:**
  - Understand how to invoke API to classify harmful content
  - Apply the API to a test sentence, one speech, and then all speeches
  - Handle character limits and API rate limits
  - See how the API responds across different languages

## Structural Topic Modeling (STM)

Finally, we’ll use STM to infer topics from political speech. We’ll begin with a simple STM implementation, then transition to a more advanced modeling pipeline with extensive preprocessing and diagnostics.

- **Files:**
  - `STM_1.R` (Basic version)
  - `STM_2.R` (Advanced version, do not open until you finish `STM_1.R`)

- **You will learn to:**
  - Clean and tokenize political text
  - Create document-feature matrices with quanteda
  - Search for optimal topic number `K` using model diagnostics
  - Interpret topics using FREX/probability terms
  - Visualize topic prevalence over time and by party

## Reminder: Do Both R and Python Versions

Each method is implemented in both R and Python (where applicable). We strongly recommend working through both so you understand how each ecosystem handles:

- Text objects
- Tokenization and cleaning
- API requests and responses
- Model diagnostics and plotting

## Suggested Order of Execution

1. `Embedding.R` and `Embedding.ipynb`
2. `Google_Perspective.ipynb` and `Google_Perspective.R`
3. `STM_1.R`
4. `STM_2.R`