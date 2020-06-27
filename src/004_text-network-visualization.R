# Install Library
install.packages(c("readr", "tm", "igraph"))

# Import Library
library(readr)
library(tm)
library(igraph)

# Import Data
df <- read_csv("data/processed//clean-tweet.csv")

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

dtm_sparse <- removeSparseTerms(dtm, 0.985)

# Create as Matrix
mat <- as.matrix(dtm_sparse)
f <- sort(rowSums(mat),
          decreasing = TRUE
)

# Covert to Graph Adjacency
q <- mat %*% t(mat)
g <- graph.adjacency(q,
                     weighted = T,
                     mode = "undirected"
)
g <- simplify(g)

a <- as_edgelist(g, names = TRUE)

# Set Label and Degree
V(g)$label <- V(g)$name
V(g)$degree <- degree(g)

# Set Layout
layout <- layout_in_circle(g)

# Visualize
plot(g, layout = layout)

# Convert to Edge List
edgelist <- as_edgelist(g, names = TRUE)

# Create as a dataframe
df <- as.data.frame(edgelist)
colnames(df)[1] <- "source"
colnames(df)[2] <- "target"

# Save as CSV
write_csv(df, "data/processed/text-network.csv")
