# install Library
install.packages(c("tidyverse", "dplyr", "tm", "wordcloud", "e1071", "gmodels", "caret"))

# import library
library(tidyverse)
library(dplyr)
library(tm)
library(wordcloud)
library(e1071)
library(gmodels)
library(caret)

# set Seed
set.seed(123)

# Import Data with Label
df <- read_csv("data/sentiment/grab-training.csv")

# Convert as factor
df$sentiment <- factor(df$sentiment)

# Check the counts of positive and negative sentiment
table(df$sentiment)

# Random sample indexes
train_index <- sample(1:nrow(df), 0.8 * nrow(df))
test_index <- setdiff(1:nrow(df), train_index)

# Build X_train, y_train, X_test, y_test
df_train <- df[train_index, ]
df_test <- df[test_index, ]

# check the proportion of class variable
prop.table(table(df_train$sentiment))
prop.table(table(df_test$sentiment))

# Create Corpus from both dataframe
train_corpus <- VCorpus(VectorSource(df_train$text))
test_corpus <- VCorpus(VectorSource(df_test$text))

# create a document-term sparse matrix directly for both
train_dtm <- DocumentTermMatrix(train_corpus)
test_dtm <- DocumentTermMatrix(test_corpus)

# create function to convert counts to a factor
convert_counts <- function(x) {
  x <- ifelse(x > 0, "1", "0")
}

# apply() convert_counts() to columns of train/test data
train_dtm_binary <- apply(train_dtm, MARGIN = 2, convert_counts)
test_dtm_binary <- apply(test_dtm, MARGIN = 2, convert_counts)

# Create the model
nb_classifier <- naiveBayes(as.matrix(train_dtm_binary), df_train$sentiment)

# Apply model to predict test dataset
df_test_pred <- predict(nb_classifier, as.matrix(test_dtm_binary))
head(df_test_pred)

# Validation using Confusion Matrix
confusionMatrix(df_test_pred, df_test$sentiment, positive = "1")

# Import New Data for Prediction
df_new <- read_csv("data/sentiment/grab-predict.csv")

# Create a corpus from the sentences
df_new_corpus <- VCorpus(VectorSource(df_new$text))

# create a document-term sparse matrix directly from the corpus
df_new_dtm <- DocumentTermMatrix(df_new_corpus)

# Crate a binary matrix
df_new_dtm_binary <- apply(df_new_dtm, MARGIN = 2, convert_counts)

# Apply Prediction (Positive = 1, Negative = 1)
df_new_pred <- predict(nb_classifier, as.matrix(df_new_dtm_binary))
df_new_pred

# Add to Dataframe
df_new["pred_sentiment"] <- df_new_pred

# Create a result dataframe
df_result <- as.data.frame(table(df_new$pred_sentiment))
df_result$Var1 <- as.character(df_result$Var1)
df_result$Var1[df_result$Var1 == "0"] <- "Negative"
df_result$Var1[df_result$Var1 == "1"] <- "Positive"

# Visualize using ggplot
ggplot(df_result, aes(x = "", y = Freq, fill = Var1)) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar("y", start = 0) +
  labs(fill = "Sentiment") +
  theme_void()
