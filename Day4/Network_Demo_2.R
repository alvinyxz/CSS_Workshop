library("igraph")

# Create weighted edges
edges <- data.frame(
  from = c("A", "B", "A", "B"),
  to   = c("B", "C", "D", "E"),
  weight = c(5, 1, 1, 1)
)

# Create graph
g <- graph_from_data_frame(edges, directed = FALSE)

# Plot the network (optional)
plot(g,
     edge.width = E(g)$weight * 2,
     edge.label = E(g)$weight,
     vertex.size = 30,
     vertex.label.color = "black",
     main = "Toy Network with Weighted Edges")

# Unweighted Degree Centrality
Degree_unweighted <- degree(g)
print("Unweighted Degree Centrality:")
print(Degree_unweighted)

# Weighted Degree Centrality (strength)
Degree_weighted <- strength(g, weights = E(g)$weight)
print("Weighted Degree Centrality (Strength):")
print(Degree_weighted)

# Weighted Betweenness
Betweenness_weighted <- betweenness(g, weights = E(g)$weight)
print("Weighted Betweenness:")
print(Betweenness_weighted)

# Weighted Closeness (treat higher weight as shorter path => inverse)
Closeness_weighted <- closeness(g, weights = 1 / E(g)$weight)
print("Weighted Closeness:")
print(Closeness_weighted)

# Eigenvector Centrality (weighted)
Eigenvector <- eigen_centrality(g, weights = E(g)$weight)$vector
print("Eigenvector Centrality:")
print(Eigenvector)

# PageRank (weighted)
PageRank <- page_rank(g, weights = E(g)$weight)$vector
print("PageRank:")
print(PageRank)

# Burt's Constraint
Constraint <- constraint(g, weights = E(g)$weight)
print("Burt’s Constraint:")
print(Constraint)

# Local Clustering Coefficient (same value for unweighted or weighted)
LocalClustering <- transitivity(g, type = "local", isolates = "zero")
print("Local Clustering Coefficient:")
print(LocalClustering)

# K-core Index (same value for unweighted or weighted)
Kcore <- coreness(g)
print("K-core Index:")
print(Kcore)

# Combine everything into a data frame
results <- data.frame(
  Degree_unweighted,
  Degree_weighted,
  Betweenness_weighted,
  Closeness_weighted,
  Eigenvector,
  PageRank,
  Constraint,
  LocalClustering,
  Kcore
)

print("All Metrics Combined:")
print(results)
