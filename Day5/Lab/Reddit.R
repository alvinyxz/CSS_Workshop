rm(list=ls())
# setwd("/Users/alvinzhou/Dropbox/Affordance Experiment 02 upvotes/03 Reddit HowManyPpl/")
library("jsonlite")
library("tidyverse")
library("igraph")

# Read https://github.com/pushshift/api
# Use this link to find /r/politics subreddit, sorted descending, by score, return submission id
# https://api.pushshift.io/reddit/search/submission/?sort_type=score&sort=desc&subreddit=politics
# Have a look, determine we need: subreddit, id, score, title, full_link, num_comments
# https://api.pushshift.io/reddit/search/submission/?sort_type=score&sort=desc&subreddit=politics&fields=subreddit,id,score,title,full_link,num_comments&size=500
top100_politics_submissions <- fromJSON("https://api.pushshift.io/reddit/search/submission/?sort_type=score&sort=desc&subreddit=politics&fields=subreddit,id,score,title,full_link,num_comments&size=500")
top100_politics_submissions <- top100_politics_submissions$data %>% as.data.frame
head(top100_politics_submissions)

# Although we specified size=500, returned results are capped at 100, we want more
# the last one retrieved (b4agza) has score of 61209 as of 20200823, therefore, do:
# https://api.pushshift.io/reddit/search/submission/?sort_type=score&sort=desc&subreddit=politics&fields=subreddit,id,score,title,full_link,num_comments&size=500&score<61209
top200_politics_submissions <- fromJSON("https://api.pushshift.io/reddit/search/submission/?score=<61208&sort_type=score&sort=desc&subreddit=politics&fields=subreddit,id,score,title,full_link,num_comments&size=500")
top200_politics_submissions <- top200_politics_submissions$data %>% as.data.frame
head(top200_politics_submissions)

# Although we specified size=500, returned results are capped at 100, we want more
# the last one retrieved (dces9j) has score of 55367 as of 20200823, therefore, do:
# https://api.pushshift.io/reddit/search/submission/?&score=<55366&sort_type=score&sort=desc&subreddit=politics&fields=subreddit,id,score,title,full_link,num_comments&size=500
top300_politics_submissions <- fromJSON("https://api.pushshift.io/reddit/search/submission/?&score=<55366&sort_type=score&sort=desc&subreddit=politics&fields=subreddit,id,score,title,full_link,num_comments&size=500")
top300_politics_submissions <- top300_politics_submissions$data %>% as.data.frame
head(top300_politics_submissions)

# Although we specified size=500, returned results are capped at 100, we want more
# the last one retrieved (htjmvz) has score of 51669 as of 20200823, therefore, do:
# https://api.pushshift.io/reddit/search/submission/?&score=<51668&sort_type=score&sort=desc&subreddit=politics&fields=subreddit,id,score,title,full_link,num_comments&size=500
top400_politics_submissions <- fromJSON("https://api.pushshift.io/reddit/search/submission/?&score=<51668&sort_type=score&sort=desc&subreddit=politics&fields=subreddit,id,score,title,full_link,num_comments&size=500")
top400_politics_submissions <- top400_politics_submissions$data %>% as.data.frame
head(top400_politics_submissions)

# Although we specified size=500, returned results are capped at 100, we want more
# the last one retrieved (7s7xtt) has score of 49033 as of 20200823, therefore, do:
# https://api.pushshift.io/reddit/search/submission/?&score=<49032&sort_type=score&sort=desc&subreddit=politics&fields=subreddit,id,score,title,full_link,num_comments&size=500
top500_politics_submissions <- fromJSON("https://api.pushshift.io/reddit/search/submission/?&score=<49032&sort_type=score&sort=desc&subreddit=politics&fields=subreddit,id,score,title,full_link,num_comments&size=500")
top500_politics_submissions <- top500_politics_submissions$data %>% as.data.frame
head(top500_politics_submissions)

top_politics_submissions <- rbind(top100_politics_submissions,
                                  top200_politics_submissions,
                                  top300_politics_submissions,
                                  top400_politics_submissions,
                                  top500_politics_submissions)
sum(duplicated(top_politics_submissions$id)) # no duplicates yay

# Link to see the comments for h7ic8s (btw, to go to that post, you can use https://redd.it/h7ic8s)
# https://api.pushshift.io/reddit/submission/comment_ids/h7ic8s
# The first few comments are ful2hf9,ful2luy,ful2s06
# to view it, use:
# https://api.pushshift.io/reddit/comment/search?ids=ful2hf9,ful2luy,ful2s06

# Select some middle-ground comments to look for nested structures: fum04cs,fum04dt,fum05bs
# https://api.pushshift.io/reddit/comment/search?ids=fum04cs,fum04dt,fum05bs
# Look at the metadata of the comment fum04dt, you only need these fields:
# id (fum04dt): the id of the comment
# link_id (t3_h7ic8s): the id of the submission (t3_ means Link, t1_ means Comment) (see https://redditclient.readthedocs.io/en/latest/reference/)
# parent_id (t1_fulzvj7): the id of the parent comment
# author or author_name: the username and id of the user
# Alvin update on 20200826: But do not include "fields=id,link_id,parent_id,author", because if the account is deleted, it will return error. Just get all fields.

# Use this link to see the nested structure:
# This comment: https://www.reddit.com/r/politics/comments/h7ic8s/over_a_million_people_sign_petition_calling_for/fum04dt/
# Is heavily nested. By reinterating, we can find all its parent parent parent comments:
# https://api.pushshift.io/reddit/comment/search?ids=fum04dt,fulzvj7,fulyijp,fuljagb,fuliz60,fulczjp
# fum04dt -> fulzvj7 -> fulyijp -> fuljagb -> fuliz60 -> fulczjp -> The Actual Post "h7ic8s"

# TEMPORARY SAVE HERE
# saveRDS(top_politics_submissions, file="top_politics_submissions.RDS")

# Alvin did the following to get comment_retrieved through rstudio.cloud because his Internet connection is shit

comment_retrieved <- list() # list to store comments, comment_retrieved[[1]] is the comment data for the first submission

# Alvin divided "i in 1:500" into five sections, because PushShift is unstable AF

for (i in 1:100) {
  comment_id <- fromJSON(paste0("https://api.pushshift.io/reddit/submission/comment_ids/",top_politics_submissions$id[i]))
  comment_id <- comment_id$data %>% as.vector
  # There is a maximum number of characters in a URL
  # So you can't just retrieve all comments in one API draw
  # I manually tried 500 comments and it succeeded.
  how_many_comments <- length(comment_id)
  comment_retrieving <- list() # temporary list to release pressure from API
  if (floor(how_many_comments/500)==0) { # less than 500 comments
    comment_retrieving <- fromJSON(url(paste0("https://api.pushshift.io/reddit/comment/search?ids=",
                                              paste(comment_id[1:how_many_comments],collapse=","))))
    comment_retrieving <- comment_retrieving$data %>% as.data.frame
    comment_retrieved[[i]] <- comment_retrieving
  } else {
    for (j in 1:(floor(how_many_comments/500))) { # have to indicate "url" because fromJSON would mistake our address as a JSON file
      comment_retrieving[[j]] <- fromJSON(url(paste0("https://api.pushshift.io/reddit/comment/search?ids=",
                                                     paste(comment_id[((j-1)*500+1):(j*500)],collapse=","))))
      comment_retrieving[[j]] <- comment_retrieving[[j]]$data %>% as.data.frame
    }
    comment_retrieving[[j+1]] <- fromJSON(url(paste0("https://api.pushshift.io/reddit/comment/search?ids=",
                                                     paste(comment_id[(j*500+1):how_many_comments],collapse=","))))
    comment_retrieving[[j+1]] <- comment_retrieving[[j+1]]$data %>% as.data.frame
    comment_retrieved[[i]] <- bind_rows(comment_retrieving)
  }
}

for (i in 101:200) {
  comment_id <- fromJSON(paste0("https://api.pushshift.io/reddit/submission/comment_ids/",top_politics_submissions$id[i]))
  comment_id <- comment_id$data %>% as.vector
  # There is a maximum number of characters in a URL
  # So you can't just retrieve all comments in one API draw
  # I manually tried 500 comments and it succeeded.
  how_many_comments <- length(comment_id)
  comment_retrieving <- list() # temporary list to release pressure from API
  if (floor(how_many_comments/500)==0) { # less than 500 comments
    comment_retrieving <- fromJSON(url(paste0("https://api.pushshift.io/reddit/comment/search?ids=",
                                              paste(comment_id[1:how_many_comments],collapse=","))))
    comment_retrieving <- comment_retrieving$data %>% as.data.frame
    comment_retrieved[[i]] <- comment_retrieving
  } else {
    for (j in 1:(floor(how_many_comments/500))) { # have to indicate "url" because fromJSON would mistake our address as a JSON file
      comment_retrieving[[j]] <- fromJSON(url(paste0("https://api.pushshift.io/reddit/comment/search?ids=",
                                                     paste(comment_id[((j-1)*500+1):(j*500)],collapse=","))))
      comment_retrieving[[j]] <- comment_retrieving[[j]]$data %>% as.data.frame
    }
    comment_retrieving[[j+1]] <- fromJSON(url(paste0("https://api.pushshift.io/reddit/comment/search?ids=",
                                                     paste(comment_id[(j*500+1):how_many_comments],collapse=","))))
    comment_retrieving[[j+1]] <- comment_retrieving[[j+1]]$data %>% as.data.frame
    comment_retrieved[[i]] <- bind_rows(comment_retrieving)
  }
}

for (i in 201:300) {
  comment_id <- fromJSON(paste0("https://api.pushshift.io/reddit/submission/comment_ids/",top_politics_submissions$id[i]))
  comment_id <- comment_id$data %>% as.vector
  # There is a maximum number of characters in a URL
  # So you can't just retrieve all comments in one API draw
  # I manually tried 500 comments and it succeeded.
  how_many_comments <- length(comment_id)
  comment_retrieving <- list() # temporary list to release pressure from API
  if (floor(how_many_comments/500)==0) { # less than 500 comments
    comment_retrieving <- fromJSON(url(paste0("https://api.pushshift.io/reddit/comment/search?ids=",
                                              paste(comment_id[1:how_many_comments],collapse=","))))
    comment_retrieving <- comment_retrieving$data %>% as.data.frame
    comment_retrieved[[i]] <- comment_retrieving
  } else {
    for (j in 1:(floor(how_many_comments/500))) { # have to indicate "url" because fromJSON would mistake our address as a JSON file
      comment_retrieving[[j]] <- fromJSON(url(paste0("https://api.pushshift.io/reddit/comment/search?ids=",
                                                     paste(comment_id[((j-1)*500+1):(j*500)],collapse=","))))
      comment_retrieving[[j]] <- comment_retrieving[[j]]$data %>% as.data.frame
    }
    comment_retrieving[[j+1]] <- fromJSON(url(paste0("https://api.pushshift.io/reddit/comment/search?ids=",
                                                     paste(comment_id[(j*500+1):how_many_comments],collapse=","))))
    comment_retrieving[[j+1]] <- comment_retrieving[[j+1]]$data %>% as.data.frame
    comment_retrieved[[i]] <- bind_rows(comment_retrieving)
  }
}

for (i in 301:400) {
  comment_id <- fromJSON(paste0("https://api.pushshift.io/reddit/submission/comment_ids/",top_politics_submissions$id[i]))
  comment_id <- comment_id$data %>% as.vector
  # There is a maximum number of characters in a URL
  # So you can't just retrieve all comments in one API draw
  # I manually tried 500 comments and it succeeded.
  how_many_comments <- length(comment_id)
  comment_retrieving <- list() # temporary list to release pressure from API
  if (floor(how_many_comments/500)==0) { # less than 500 comments
    comment_retrieving <- fromJSON(url(paste0("https://api.pushshift.io/reddit/comment/search?ids=",
                                              paste(comment_id[1:how_many_comments],collapse=","))))
    comment_retrieving <- comment_retrieving$data %>% as.data.frame
    comment_retrieved[[i]] <- comment_retrieving
  } else {
    for (j in 1:(floor(how_many_comments/500))) { # have to indicate "url" because fromJSON would mistake our address as a JSON file
      comment_retrieving[[j]] <- fromJSON(url(paste0("https://api.pushshift.io/reddit/comment/search?ids=",
                                                     paste(comment_id[((j-1)*500+1):(j*500)],collapse=","))))
      comment_retrieving[[j]] <- comment_retrieving[[j]]$data %>% as.data.frame
    }
    comment_retrieving[[j+1]] <- fromJSON(url(paste0("https://api.pushshift.io/reddit/comment/search?ids=",
                                                     paste(comment_id[(j*500+1):how_many_comments],collapse=","))))
    comment_retrieving[[j+1]] <- comment_retrieving[[j+1]]$data %>% as.data.frame
    comment_retrieved[[i]] <- bind_rows(comment_retrieving)
  }
}

for (i in 401:500) {
  comment_id <- fromJSON(paste0("https://api.pushshift.io/reddit/submission/comment_ids/",top_politics_submissions$id[i]))
  comment_id <- comment_id$data %>% as.vector
  # There is a maximum number of characters in a URL
  # So you can't just retrieve all comments in one API draw
  # I manually tried 500 comments and it succeeded.
  how_many_comments <- length(comment_id)
  comment_retrieving <- list() # temporary list to release pressure from API
  if (floor(how_many_comments/500)==0) { # less than 500 comments
    comment_retrieving <- fromJSON(url(paste0("https://api.pushshift.io/reddit/comment/search?ids=",
                                              paste(comment_id[1:how_many_comments],collapse=","))))
    comment_retrieving <- comment_retrieving$data %>% as.data.frame
    comment_retrieved[[i]] <- comment_retrieving
  } else {
    for (j in 1:(floor(how_many_comments/500))) { # have to indicate "url" because fromJSON would mistake our address as a JSON file
      comment_retrieving[[j]] <- fromJSON(url(paste0("https://api.pushshift.io/reddit/comment/search?ids=",
                                                     paste(comment_id[((j-1)*500+1):(j*500)],collapse=","))))
      comment_retrieving[[j]] <- comment_retrieving[[j]]$data %>% as.data.frame
    }
    comment_retrieving[[j+1]] <- fromJSON(url(paste0("https://api.pushshift.io/reddit/comment/search?ids=",
                                                     paste(comment_id[(j*500+1):how_many_comments],collapse=","))))
    comment_retrieving[[j+1]] <- comment_retrieving[[j+1]]$data %>% as.data.frame
    comment_retrieved[[i]] <- bind_rows(comment_retrieving)
  }
}

# TEMPORARY SAVE HERE
# saveRDS(comment_retrieved, file="comment_retrieved.RDS")
# Or, read from the file created by Rstuidio.cloud
# comment_retrieved <- readRDS("comment_retrieved.RDS")

comment_retrieved[[1]]
comment_retrieved[[101]]
comment_retrieved[[201]]
comment_retrieved[[301]]
comment_retrieved[[401]]
# Looks good

comments_all_together <- bind_rows(comment_retrieved)
nrow(comments_all_together) # 2899109 comments
sum(comments_all_together$parent_id %in% unique(comments_all_together$link_id)) # 503669 mother comments

# Let's add the "t1_" back to comments (the $id column) to make it easier to understand
# All $id should be comments and belong to the "t1_" class
for (i in 1:500) {
  comment_retrieved[[i]]$id <- paste0("t1_",comment_retrieved[[i]]$id)
}

# How many people involved in the same parent comment

how_many_authors_involved <- list()

for (i in 1:500) {
  submissionid <- comment_retrieved[[i]]$link_id[1]
  
  edgelist <-
    comment_retrieved[[i]] %>%
    select("id", "parent_id") %>%
    rename("from" = "id", # node from
           "to" = "parent_id") # node to
  g <- graph_from_data_frame(edgelist, directed=T)
  g <- delete_vertices(g, submissionid)
  
  nodelist <- 
    comment_retrieved[[i]] %>%
    select("id", "author") # some id doesn't have author any more, maybe deleted accounts
  
  # Then, the network g should have N components, N is equal to the number of first-level comments
  # How many components are there?
  components <- components(g)
  number_of_components <- components$no # this is the number of components (or, first-level comments)
  number_of_authors <- vector()
  for (j in 1:number_of_components) {
    g_take_one_network <- induced.subgraph(g, V(g)[which(components$membership==j)])
    author_in_the_thread <- nodelist$author[which(nodelist$id %in% V(g_take_one_network)$name)]
    number_of_authors[j] <- length(unique(author_in_the_thread[!is.na(author_in_the_thread)]))
  }
  how_many_authors_involved[[i]] <- number_of_authors
}

# TEMPORARY SAVE HERE
# saveRDS(how_many_authors_involved, file="how_many_authors_involved")

medium_how_many_authors_involved <- lapply(how_many_authors_involved, median)
medium_how_many_authors_involved # Ugh

how_many_authors_involved_unlisted <- unlist(how_many_authors_involved)
table(how_many_authors_involved_unlisted)
summary(how_many_authors_involved_unlisted)
median(how_many_authors_involved_unlisted[!how_many_authors_involved_unlisted %in% 1]) # 3
mean(how_many_authors_involved_unlisted[!how_many_authors_involved_unlisted %in% 1]) # 9.61
