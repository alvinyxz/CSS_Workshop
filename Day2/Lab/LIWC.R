# LIWC Analysis Lab Script
# This script explores pre-processed LIWC scores for U.S. presidential speeches

library("tidyverse")
liwc_df <- read.csv("presidential_speeches_LIWC.csv")

# Quick preview of the data
glimpse(liwc_df)
# Check which LIWC variables are included
names(liwc_df)
# Read LIWC paper to go through what these variables mean

# Summarize self-focus ("i") by president
# You can do this one by one
mean(liwc_df$i[liwc_df$President == "Bill Clinton"])
mean(liwc_df$i[liwc_df$President == "Donald Trump"])
# But also, you can use tidyverse (which we are not covering in this workshop, but super useful)
liwc_df %>%
  group_by(President) %>% # group by one column
  summarize(mean_I = mean(i, na.rm = TRUE)) %>% # summarize the "i" column
  arrange(desc(mean_I)) # arrange the results in descending order

# Summarize positive emotion by president
liwc_df %>%
  group_by(President) %>%
  summarize(mean_positive = mean(posemo, na.rm = TRUE)) %>%
  arrange(desc(mean_positive))

# Summarize negative emotion by president
liwc_df %>%
  group_by(President) %>%
  summarize(mean_negative = mean(negemo, na.rm = TRUE)) %>%
  arrange(desc(mean_negative))

# Compare mean positive emotion by party
liwc_df %>%
  group_by(Party) %>%
  summarize(mean_positive = mean(posemo, na.rm = TRUE))

# Compare mean negative emotion by party
liwc_df %>%
  group_by(Party) %>%
  summarize(mean_negative = mean(negemo, na.rm = TRUE))

# Plot positivity and negativity over time
head(liwc_df$date)  # Check the date format, it is in M/D/YYYY format
liwc_df$date <- mdy(liwc_df$date) # mdy() function from lubridate package can easily process M/D/YYYY
# Now what we are trying to plot are three columns: date, posemo, and negemo
# But in R, ggplot requires data in long format: three columns -- date, emotion (being either positive or negative), scores
# so we need to reshape the data
liwc_long <- liwc_df %>%
  select(date, posemo, negemo) %>% # select the three columns
  pivot_longer(cols = c(posemo, negemo), # convert to long format
               names_to = "emotion",
               values_to = "score")
View(liwc_long) # have a look
# Now we can plot the data
ggplot(liwc_long,
       aes(x = date,
           y = score,
           color = emotion)) +
  geom_line(linewidth = 0.5,
            alpha = 0.8) +
  theme_minimal() +
  labs(title = "LIWC Positive and Negative Emotion Over Time",
       x = "Date",
       y = "Emotion Score",
       color = "Emotion") +
  scale_color_manual(values = c("posemo" = "blue",
                                "negemo" = "red"),
                     labels = c("Positive",
                                "Negative"))

# Hmm, did you see that some emotion scores are 0?
# Why? Look at the data (csv), and you will find that some speeches are empty!
# NA means "not available" or "missing"
# It is actually very common to have a messy computational dataset
# For the time being, let's create a new dataset that do not include those speeches
liwc_cleaned <- liwc_df[is.na(liwc_df$speech)==F,]  # filter out rows with empty speech
# let's plot again

liwc_long <- liwc_cleaned %>%
  select(date, posemo, negemo) %>% # select the three columns
  pivot_longer(cols = c(posemo, negemo), # convert to long format
               names_to = "emotion",
               values_to = "score")
# Now we can plot the data
ggplot(liwc_long,
       aes(x = date,
           y = score,
           color = emotion)) +
  geom_line(size = 0.5, alpha = 0.8) +
  theme_minimal() +
  labs(title = "LIWC Positive and Negative Emotion Over Time",
       x = "Date",
       y = "Emotion Score",
       color = "Emotion") +
  scale_color_manual(values = c("posemo" = "blue",
                                "negemo" = "red"),
                     labels = c("Positive",
                                "Negative"))

# We can use smooth lines to better visualize the trends
ggplot(liwc_long,
       aes(x = date,
           y = score,
           color = emotion)) +
  geom_smooth(formula = y ~ x,
              se = TRUE,
              method = "loess",
              span = 0.05) + # you can change span to adjust the smoothness, smaller span means less smooth
  theme_minimal() +
  labs(title = "LIWC Positive and Negative Emotion Over Time (Smoothed)",
       x = "Date",
       y = "Emotion Score",
       color = "Emotion") +
  scale_color_manual(values = c("posemo" = "blue",
                                "negemo" = "red"),
                     labels = c("Positive", "Negative"))

# Optional: explore partisan differences across all LIWC categories

# Step 1: Filter to D/R speeches only
liwc_filtered <- liwc_cleaned %>%
  filter(Party %in% c("Democratic", "Republican"))

# Step 2: Calculate mean LIWC scores for each party
party_means <- liwc_filtered %>%
  group_by(Party) %>%
  summarize(across(WC:OtherP, mean, na.rm = TRUE))
# because names(liwc_filtered) shows that our LIWC scores start from WC (word count) to OtherP (other pronouns), we can use WC:OtherP to select all LIWC columns
# Look at this object
View(party_means)

# Step 3: Extract rows for each party
dem <- party_means %>% filter(Party == "Democratic") %>% select(-Party)
rep <- party_means %>% filter(Party == "Republican") %>% select(-Party)
View(dem)
View(rep)

# Step 4: Calculate difference and organize
options(scipen = 999) # turn off scientific notation for better readability
# you can skip the above line to see how diff_df would look like with scientific notation
diff_df <- tibble(
  category = names(dem),
  Democratic = as.numeric(dem[1, ]),
  Republican = as.numeric(rep[1, ]),
  diff = Democratic - Republican
) %>%
  arrange(desc(abs(diff)))
View(diff_df)
