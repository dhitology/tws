# Install Library
install.packages(c("tidyverse", "tidytext", "topicmodels", "tm"))

# Import library
library(tidyverse)
library(tidytext)
library(topicmodels)
library(tm)

# Import Data
df <- read_csv("data/processed/clean-tweet.csv")

# Create Function
tm_lda <- function(input_text, plot = T, topic = 2) {
  corpus <- Corpus(VectorSource(input_text))
  dtm <- DocumentTermMatrix(corpus)
  
  unique_indexes <- unique(dtm$i)
  dtm <- dtm[unique_indexes, ]
  
  lda <- LDA(dtm, k = topic, control = list(seed = 1234))
  topics <- tidy(lda, matrix = "beta")
  
  top_terms <- topics %>%
    group_by(topic) %>%
    top_n(10, beta) %>%
    ungroup() %>%
    arrange(topic, -beta)
  
  if (plot == T) {
    top_terms %>%
      mutate(term = reorder(term, beta)) %>%
      ggplot(aes(term, beta, fill = factor(topic))) +
      geom_col(show.legend = FALSE) +
      facet_wrap(~topic, scales = "free") +
      labs(x = NULL, y = "Beta") +
      coord_flip()
  } else {
    return(top_terms)
  }
}

# Create a Document Term Matrix
df_corpus <- Corpus(VectorSource(df$text))
df_dtm <- DocumentTermMatrix(df_corpus)

# Covert to Tidy
df_tidy <- tidy(df_dtm)

# custom stop word
stop_words <- tibble(word = c("indonesia", "iolpoker", "langsung", "terbesar", 
                              "situs", "sampe", "nya", "gua", "dgn", "org", "banget", 
                              "bandar", "hip", "whatsapp", "tunggu", "terpercaya", "omaha",
                              "michelle", "kontak", "idnpoker", "dominoqq", "com", "ceme", "bonus", "agen" ))

# remove stopwords
df_tidyclean <- df_tidy %>%
  anti_join(stop_words, by = c("term" = "word"))

# Reconstruct
df_fix <- df_tidyclean %>%
  group_by(document) %>%
  mutate(term = toString(rep(term, count))) %>%
  select(document, term) %>%
  unique()

# Show Topics
tm_lda(df_fix$term, topic = 2)

