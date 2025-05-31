library("igraph")

# Choose one of the two methods below to create/import a graph

# 1. Create the graph in R
# A—B—C
# |  |
# D  E
edges <- c("A", "B",
           "B", "C",
           "A", "D",
           "B", "E")
g <- make_graph(edges, directed = FALSE)

# 2. Or you can import a graph from a CSV file
edges <- read.csv("Network_Demo_1.csv")
g <- graph_from_data_frame(edges, directed = FALSE)

# Plot the graph
plot(g,
     vertex.label.color = "black",
     vertex.size = 30,
     main = "Toy Network")

# Calculate degree
Degree <- degree(g)
print("Degree centrality:")
print(Degree)

# Calculate betweenness
Betweenness <- betweenness(g)
print("Betweenness centrality:")
print(Betweenness)

# Calculate closeness
Closeness <- closeness(g)
print("Closeness centrality:")
print(Closeness)

# Eigenvector Centrality
Eigenvector <- eigen_centrality(g)$vector
print("Eigenvector centrality:")
print(Eigenvector)

# PageRank
PageRank <- page_rank(g)$vector
print("PageRank:")
print(PageRank)

# Burt's Constraint
Constraint <- constraint(g)
print("Burt's Constraint:")
print(Constraint)

# Local Clustering Coefficient
LocalClustering <- transitivity(g, type = "local", isolates = "zero")
print("Local Clustering Coefficient:")
print(LocalClustering)
# Think about why it is all zero?

# K-core / Coreness
Kcore <- coreness(g)
print("K-core index:")
print(Kcore)
# Think about why it is all one?

# Compile all metrics into a data frame
metrics <- data.frame(
  Degree,
  Betweenness,
  Closeness,
  Eigenvector,
  PageRank,
  Constraint,
  LocalClustering,
  Kcore
)
print("All node-level metrics:")
print(metrics)

# Optional: visualize with centrality size
plot(g, vertex.size = Degree*10 + 20, main = "Node size = Degree Centrality")
plot(g, vertex.size = Betweenness*10 + 20, main = "Node size = Betweenness Centrality")
plot(g, vertex.size = Closeness*10 + 20, main = "Node size = Closeness Centrality")
