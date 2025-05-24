rm(list=ls())
library("here")
# here::i_am("01_Scripts_Critical/02_TM_Critical_Subset.R")
library("tidyverse")
library("quanteda")
library("stm")
library("data.table")
library("textstem")
library("geometry")
library("Rtsne")
library("rsvd")
# devtools::install_github("mikajoh/stmprinter")
library("stmprinter")
library("ggplot2")

dta <- readRDS(file = here("02_Output", "07_DTA.RDS"))
dta_Critical <- readRDS(file = here("02_Output_Critical", "02_dta_Critical.RDS"))
dta_Critical <- dta_Critical$doi
dta <- dta[dta$doi %in% dta_Critical, ]

sum(sapply(strsplit(dta$clean_text, " "), length)) # 3672211 words

# HTML tags and citation
dta$clean_text <- gsub("<.*?>","", dta$clean_text)
dta$clean_text <- gsub("\\s*\\([^\\)]+\\)","", dta$clean_text)
# check dta$clean_text[534]
# Grace's complex paper looks good
# remove non-ASCII characters
Encoding(dta$clean_text) <- "UTF-8"
dta$clean_text <- iconv(dta$clean_text, "UTF-8", "ASCII", sub="")
# create corpus
fullcorpus <- quanteda::corpus(dta$clean_text,
                               docvars = dta[, c("journal",
                                                 "year",
                                                 "volume",
                                                 "issue",
                                                 "page",
                                                 "doi",
                                                 "title",
                                                 "citation")])
summary(fullcorpus)
dta %>% group_by(journal) %>% tally()

# tokenize
toks <- quanteda::tokens(fullcorpus,
                         what = "word",
                         remove_punct = TRUE,
                         remove_symbols = TRUE,
                         remove_numbers = TRUE,
                         remove_url = TRUE,
                         remove_separators = TRUE,
                         split_hyphens = FALSE # compound words, e.g., OPR
)
# devtools::install_github("kbenoit/quanteda.dictionaries")
library("quanteda.dictionaries")
# Change UK English to US English
toks <- quanteda::tokens_lookup(toks,
                                data_dictionary_uk2us,
                                exclusive = FALSE,
                                capkeys = FALSE)
# remove some 2+-gram
toks <- quanteda::tokens_remove(toks, pattern = phrase("public relations")) # remove "public relations"
sum(ntoken(toks)) # 3352945
# create DocumentTermMatrix
fullcorpus.dfm <- quanteda::dfm(toks,
                                tolower = TRUE,
                                # stem = FALSE,
                                remove_punct = TRUE,
                                remove_numbers = TRUE,
                                remove_symbols = TRUE,
                                remove_separators = TRUE,
                                split_hyphens = FALSE, # compound words
                                remove_url = TRUE)
topfeatures(fullcorpus.dfm, n = 500)
fullcorpus.dfm <- quanteda::dfm_remove(fullcorpus.dfm,
                                       c(stopwords("en", source = "stopwords-iso"),
                                         "n", "p", "eg", "ie",
                                         "article", "articles",
                                         "conclusion", "analysis",
                                         "method", "methods", "download",
                                         "literature", "review", "reviews", "also",
                                         "study", "studies", "studying", "studi",
                                         "result", "results",
                                         "table", "figure",
                                         "one", "two", "three", "number"))
# lemmatization using textstem instead of stems
lemmas <- unlist(toks) %>% tolower(.) %>% unique(.)
lemmas <- cbind(words = lemmas,
                lemmas = lemmatize_words(lemmas)) %>% as.data.table(.)
fullcorpus.dfm <- dfm_replace(fullcorpus.dfm,
                              pattern = lemmas$words,
                              replacement = lemmas$lemmas,
                              case_insensitive = TRUE)
topfeatures(fullcorpus.dfm, n = 500)

nfeat(fullcorpus.dfm) # 49458 features
fullcorpus_trimed <- dfm_trim(fullcorpus.dfm,
                              min_docfreq = 0.01,
                              max_docfreq = 0.99,
                              docfreq_type = "prop") # min 1% / max 99%
nfeat(fullcorpus_trimed)
ndoc(fullcorpus_trimed)
# 9145 features in 534 papers
topfeatures(fullcorpus_trimed, n = 500)

# fit stm model
# If init.type="Spectral" you can also set K=0 to use the algorithm of Lee and Mimno (2014)
# to set the number of topics (although unlike the standard spectral initialization this is not deterministic)
# fit.initial <- stm::stm(fullcorpus_trimed,
#                         data = fullcorpus_trimed@docvars,
#                         init.type = "Spectral",
#                         K = 0,
#                         LDAbeta = T, ## defaults to TRUE when there are no content covariates
#                         interactions = F, ## no content covariates, so no interaction required
#                         reportevery = 10, ## displace every 10 iterations
#                         seed = 12345)
# initial model using EM initialization suggests 98 (correlated) topics.
# check few topics
# labelTopics(fit.initial, 98)
# saveRDS(fit.initial, here("02_Output", "08_fit_initial.RDS"))
# fit.initial <- readRDS(here("02_Output", "08_fit_initial.RDS"))

fullcorpus_trimed_stm <- quanteda::convert(fullcorpus_trimed, to = "stm")
saveRDS(fullcorpus_trimed_stm, here("02_Output_Critical", "Subset", "01_fullcorpus_trimed_stm.RDS"))
# fullcorpus_trimed_stm <- readRDS(here("02_Output_Critical", "Subset", "01_fullcorpus_trimed_stm.RDS"))

# Step 1
# Redo model search, this following commands will take 24+ hours
k_model_search_5_100_5 <- searchK(documents = fullcorpus_trimed_stm$documents,
                                    vocab = fullcorpus_trimed_stm$vocab,
                                    data = fullcorpus_trimed_stm$meta,
                                    prevalence=~journal+s(year),
                                    K = seq(from = 5, to = 100, by = 5),
                                    set.seed(12345),
                                    max.em.its = 75, # 75 iterations should be enough, to save time
                                    cores = 1 # Number of CPUs to use for parallel computation, progress will not be shown
)
# Mac be super slow with more cores, not because of CPU load but memory, each R session takes 4GB+ memory
saveRDS(k_model_search_5_100_5, here("02_Output_Critical", "Subset", "02_k_model_search_5_100_5.RDS"))
library("ggplotify")
library("patchwork")
a <- as.ggplot(~plot(k_model_search_5_100_5))
vis <- data.frame("K" = unlist(k_model_search_5_100_5$results$K), 
                  "Coherence" = unlist(k_model_search_5_100_5$results$semcoh),
                  "Exclusivity" = unlist(k_model_search_5_100_5$results$exclus))
b<- ggplot(vis, aes(Coherence, Exclusivity, label = K)) +
  geom_point(size=3) +
  labs(x = "Semantic Coherence", 
       y = "Exclusivity", 
       title = "Comparing exclusivity and semantic coherence"
       # subtitle = "Source: http://fueleconomy.gov"
       ) +
  geom_text(hjust = 0,
            vjust = 2,
            size = 4) +
  theme_bw()
a + b + plot_annotation(tag_levels = 'A')
ggsave(here("02_Output_Critical", "Subset", "02_k_model_search_5_100_5.pdf"),
       last_plot(),
       width = 14,
       height = 8)
# the plot suggests that
# no need to go above 25

# Step 2
k_model_search_2_40_1 <- searchK(documents = fullcorpus_trimed_stm$documents,
                                  vocab = fullcorpus_trimed_stm$vocab,
                                  data = fullcorpus_trimed_stm$meta,
                                  prevalence=~journal+s(year),
                                  K = seq(from = 2, to = 40, by = 1),
                                  set.seed(12345),
                                  max.em.its = 75, # 75 iterations should be enough, to save time
                                  cores = 1 # Number of CPUs to use for parallel computation, progress will not be shown
)
saveRDS(k_model_search_2_40_1, here("02_Output_Critical", "Subset", "02_k_model_search_2_40_1.RDS"))
a <- as.ggplot(~plot(k_model_search_2_40_1))
vis <- data.frame("K" = unlist(k_model_search_2_40_1$results$K), 
                  "Coherence" = unlist(k_model_search_2_40_1$results$semcoh),
                  "Exclusivity" = unlist(k_model_search_2_40_1$results$exclus))
b<- ggplot(vis, aes(Coherence, Exclusivity, label = K)) +
  geom_point(size=3) +
  labs(x = "Semantic Coherence", 
       y = "Exclusivity", 
       title = "Comparing exclusivity and semantic coherence"
       # subtitle = "Source: http://fueleconomy.gov"
  ) +
  geom_text(hjust = 0,
            vjust = 2,
            size = 4) +
  theme_bw()
a + b + plot_annotation(tag_levels = 'A')
ggsave(here("02_Output_Critical", "Subset", "02_k_model_search_2_40_1.pdf"),
       last_plot(),
       width = 14,
       height = 8)
# 5/6/11/14/15/18/19
# Group decided to use 18

# In the meantime, do step 3
for (i in 2:100) {
  a <- stm(documents = fullcorpus_trimed_stm$documents,
           vocab = fullcorpus_trimed_stm$vocab,
           data = fullcorpus_trimed_stm$meta,
           prevalence=~journal+s(year),
           K = i,
           set.seed(12345)
           # max.em.its = 75, # no set max iterations
  )
  code <- paste("saveRDS(a, here('02_Output_Critical', 'Subset', '03_stm', 'stm_", i, ".RDS'))", sep="")
  eval(parse(text=code))
  stem_prob <- data.frame(labelTopics(a, 1:i, n = 20)$prob)
  stem_frex <- data.frame(labelTopics(a, 1:i, n = 20)$frex)
  stm_table <- as.data.frame(matrix(nrow=i*2, ncol=21))
  stm_table[seq(from = 1, to = i*2-1, by = 2), 2:21] <- stem_prob
  stm_table[seq(from = 2, to = i*2, by = 2), 2:21] <- stem_frex
  for (j in 1:i) {
    stm_table[c(2*j-1), 1] <- paste0("Topic ", j, " Prob")
    stm_table[c(2*j), 1] <- paste0("Topic ", j, " Frex")
  }
  code <- paste("write.table(stm_table, here('02_Output_Critical', 'Subset', '03_stm', 'stm_", i, ".csv'), sep = ',', row.names = F, col.names = F)", sep="")
  eval(parse(text=code))
}

# Originating from:
# stm_68 <- stm(documents=fullcorpus_trimed_stm$documents,
#               vocab=fullcorpus_trimed_stm$vocab,
#               K=68,
#               data=fullcorpus_trimed_stm$meta,
#               prevalence=~journal+s(year))
# saveRDS(stm_68, here("02_Output", "09_stm_68.RDS"))
# stm_68_prob <- data.frame(labelTopics(stm_68, 1:68, n = 20)$prob)
# stm_68_frex <- data.frame(labelTopics(stm_68, 1:68, n = 20)$frex)
# stm_68_table <- as.data.frame(matrix(nrow=68*2, ncol=21))
# stm_68_table[seq(from = 1, to = 68*2-1, by = 2), 2:21] <- stm_68_prob
# stm_68_table[seq(from = 2, to = 68*2, by = 2), 2:21] <- stm_68_frex
# for (i in 1:68) {
#   stm_68_table[c(2*i-1), 1] <- paste0("Topic ", i, " Prob")
#   stm_68_table[c(2*i), 1] <- paste0("Topic ", i, " Frex")
# }
# write.table(stm_68_table,
#             here("02_Output", "09_stm_68.csv"),
#             sep = ",",
#             row.names = F, col.names = F)


# Human Read

i <- 11
code <- paste0("a <- readRDS(here('02_Output_Critical', 'Subset', '03_stm', 'stm_", i, ".RDS")
eval(parse(text=code))
# Others
plot(a, 
     type = "summary", 
     xlim = c(0,1), 
     n = 12, 
     labeltype = "prob",
     main = NA, 
     text.cex = 0.8) # save it in Figures
labelTopics(a, 5, n = 20)
findThoughts(a,
             dta$title,
             topics = 11,
             n=10)

# Note on why we did
# dta$clean_text <- gsub("<.*?>","", dta$clean_text)

# mi comes from
# [0] "http://dx.doi.org/10.1016/j.pubrev.2018.12.001"
# [1] "http://dx.doi.org/10.1016/j.pubrev.2022.102254"
# [2] "http://dx.doi.org/10.1016/j.pubrev.2019.03.004"
# [3] "http://dx.doi.org/10.1016/j.pubrev.2016.06.004"
# [4] "http://dx.doi.org/10.1016/j.pubrev.2021.102061"
# [5] "http://dx.doi.org/10.1016/j.pubrev.2020.102006"
# [6] "http://dx.doi.org/10.1016/j.pubrev.2018.12.008"
# [7] "http://dx.doi.org/10.1016/j.pubrev.2013.06.005"
# similar to true, coming from dta$clean_text[c(1637, 1284, 2161, 1387, 1873)]
# "http://dx.doi.org/10.1016/j.pubrev.2018.12.001"'s math equations produced true, mi
# Mhigh<math><msub is=\"true\"><mrow is=\"true\"><mi is=\"true\">M</mi></mrow><mrow is=\"true\"><mi is=\"true\" mathvariant=\"italic\">high</mi></mrow></msub></math>=3.51, SD=0.44, nhigh<math><msub is=\"true\"><mrow is=\"true\"><mi is=\"true\">n</mi></mrow><mrow is=\"true\"><mi is=\"true\" mathvariant=\"italic\">high</mi></mrow></msub></math>=24 vs. Mlow<math><msub is=\"true\"><mrow is=\"true\"><mi is=\"true\">M</mi></mrow><mrow is=\"true\"><mi is=\"true\" mathvariant=\"italic\">low</mi></mrow></msub></math>=3.73, SD=0.31, nlow<math><msub is=\"true\"><mrow is=\"true\"><mi is=\"true\">n</mi></mrow><mrow is=\"true\"><mi is=\"true\" mathvariant=\"italic\">low</mi></mrow></msub></math>=24)
# Fuck me, rerun, forgot to delete HTML tags. You need to add:
# dta$clean_text <- gsub("<.*?>","", dta$clean_text)
