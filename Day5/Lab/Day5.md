# Day 5

Today, we’ll learn about web scraping and API access — skills that are increasingly important for collecting real-world, messy, and dynamic social data.

We’ll walk through scraping static and dynamic content, use Selenium to extract logged-in content, and learn how to interface with the YouTube API. Reddit scraping materials are included as an optional exercise, depending on API availability.

## Static Web Scraping

Open `Scraping.R`

We’ll use rvest to scrape structured content from static websites (e.g., Wikipedia, ESPN, UN data). You’ll learn how to extract content using CSS selectors or XPath.

**Challenge:** The script includes a prompt to scrape information about yourself from your Google Scholar page. Try it on your own first. If you get stuck, consult `Scraping_Google_Scholar.R` for example code.

## Scraping Dynamic and Complicated Content

Open `Selenium.ipynb`.

This notebook introduces Selenium, a browser automation tool that allows us to access content behind login walls, click through tabs, and extract hidden HTML elements.

You’ll practice:
- Logging into a site (e.g., MyU)
- Navigating to the “My Info” section
- Extracting your own phone numbers and addresses

We will also use Selenium to scrape data that was not retrievable by the `rvest` package that we just used in R.

## YouTube API

Open `YouTube.ipynb`.

You’ll learn to use Google’s official YouTube Data API to search for videos, retrieve statistics, and download comments.

We’ll cover:
- Searching for videos related to “University of Minnesota”
- Extracting video stats and comments from a known creator (e.g., MrBeast)
- Understanding how API rate limits and authentication work

## Reddit Scraping (Optional)

Open `Reddit.R` or `Reddit.ipynb`

This section walks you through scraping Reddit posts using the PullPush.io API — an alternative to the now-dead Pushshift. You can collect data by keyword and date range.

PullPush constantly goes under maintenance. You may not be able to retrieve live data during the workshop, but the code is included for later use.