# ================================================
# Reddit Data Collection using PullPush API
# ================================================

# Load required libraries
if (!require("httr")) install.packages("httr")
if (!require("jsonlite")) install.packages("jsonlite")
if (!require("dplyr")) install.packages("dplyr")
if (!require("readr")) install.packages("readr")

# ================================================
# Set keyword and time range
# ================================================

keyword <- "university"
now <- as.integer(Sys.time())
one_day_ago <- now - 86400  # 86400 seconds = 1 day

# ================================================
# Make API request
# ================================================

response <- GET("https://api.pullpush.io/reddit/search/submission/",
                query = list(
                  q = keyword,
                  after = one_day_ago,
                  before = now,
                  sort = "asc",
                  sort_type = "created_utc",
                  size = 100
                ))

# ================================================
# Save raw response text to object
# ================================================

raw_text <- content(response, "text", encoding = "UTF-8")
# View raw JSON text (optional)
cat(substr(raw_text, 1, 1000))  # Preview first 1000 characters

# ================================================
# Parse JSON to dataframe
# ================================================

parsed <- fromJSON(raw_text)
posts <- parsed$data
# Check structure
glimpse(posts)

# ================================================
# Clean up and select important fields
# ================================================

df <- posts %>%
  filter(!(selftext %in% c("[removed]", "[deleted]"))) %>%
  transmute(
    Id = id,
    Title = title,
    Author = author,
    Content = selftext,
    Timestamp = as.POSIXct(created_utc, origin = "1970-01-01", tz = "UTC"),
    Url = paste0("https://www.reddit.com", permalink),
    Upvotes = ups,
    Downvotes = downs,
    Comments = num_comments,
    Keyword = keyword
  )

# ================================================
# Save to CSV
# ================================================
write_csv(df, "reddit_posts_today.csv")
