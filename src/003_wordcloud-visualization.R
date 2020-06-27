# Install Library
install.packages(c("readr", "tm", "wordcloud", "RColorBrewer"))

# Import Library
library(readr)
library(tm)
library(wordcloud)
library(RColorBrewer)

# Import Data
df <- read_csv("data/processed/clean-tweet.csv")


# Create Corpus
corpus <- Corpus(VectorSource(df$text))
corpus <- tm_map(
  corpus,
  removeWords,
  c("dan", "kenapa", "nya", "gua", 
    "iya", "terkena", "akhirnyaaa", 
    "too", "dis", "eeeeaaaa", "langsung", 
    "semoga", "aka", "jaga", "insekyur", 
    "lho", "iolpoker", "polisiku", "pusink", "deh",
    "here", "kamuu", "arahan", "sekalih", "hereeee", "rindonesia",
    "ciletuhpalabuhanratu", "berdamai", "bercanda", "menerjemahkan",
    "now", "sekallih")
)

# Create Document Term Matrix
dtm <- TermDocumentMatrix(corpus,
                          control = list(weighting = weightTfIdf)
)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
head(d, 10)


# Wordcloud Visualization
wc <- wordcloud(
  words = d$word,
  min.freq = 4,
  max.words= 24,
  freq = d$freq,
  random.order = FALSE,
  colors = brewer.pal(8, "Dark2")
)

