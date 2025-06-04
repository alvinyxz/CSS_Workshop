library("igraph")

# Load edge list
edges <- read.csv("Network_Demo_3.csv")
# Create weighted undirected graph
g <- graph_from_data_frame(edges, directed = FALSE)

# Quick base R plot
plot(g,
     edge.width = E(g)$weight,
     vertex.size = 20,
     vertex.label.color = "black",
     main = "Mock Friendship Network with Weighted Edges")

# -------------------------------
# Node-level metrics
# -------------------------------

print("Unweighted Degree Centrality:")
print(degree(g))

print("Weighted Degree Centrality (Strength):")
print(strength(g, weights = E(g)$weight))

print("Betweenness Centrality (weighted):")
print(betweenness(g, weights = E(g)$weight))

print("Closeness Centrality (weighted):")
print(closeness(g, weights = 1 / E(g)$weight))

print("Eigenvector Centrality:")
print(eigen_centrality(g, weights = E(g)$weight)$vector)

print("PageRank:")
print(page_rank(g, weights = E(g)$weight)$vector)

print("Burt’s Constraint:")
print(constraint(g))

print("Local Clustering Coefficient:")
print(transitivity(g, type = "local", isolates = "zero"))

print("K-core Index:")
print(coreness(g))

# -------------------------------
# Graph-level metrics
# -------------------------------

print("Graph Density:")
print(edge_density(g))

print("Average Path Length (unweighted):")
print(mean_distance(g, directed = FALSE))

print("Average Path Length (weighted):")
print(mean_distance(g, directed = FALSE, weights = 1 / E(g)$weight))

print("Global Clustering Coefficient:")
print(transitivity(g, type = "global"))

cl <- cluster_louvain(g, weights = E(g)$weight)
# Louvain is a popular community detection algorithm
# There are other methods like Infomap, Walktrap, etc.
membership_vector <- membership(cl)
print("Community Memberships:")
split(names(membership_vector), membership_vector)

print("Modularity (Louvain):")
print(modularity(cl))
# Higher modularity means more segregated into communities
# denser connections within communities & sparser connections between them

print("Number of Communities Detected:")
print(length(cl))

# -------------------------------
# ggraph Plot (Optional)
# -------------------------------

library("ggraph")
library("tidygraph")
library("ggplot2")
tg <- as_tbl_graph(g) %>%
  mutate(community = factor(membership(cl)),
         degree = centrality_degree(),
         eigencent = centrality_eigen(weights = weight))

set.seed(123)  # For reproducibility
ggraph(tg, layout = "kk") +
  # You can use other layouts like "fr", "drl", "stress", "circle", "tree", "sphere"
  geom_edge_link(
    aes(width = weight),
    alpha = 0.8,
    color = "gray70"
  ) +
  geom_node_point(
    aes(color = community,
        size = degree),
    alpha = 1
  ) +
  geom_node_label(
    aes(label = name),
    size = 3,
    label.size = 0.5,
    color = "black",
    fill = "#F8F8F8",
    fontface = "bold",
    alpha = 0.85,
    repel = TRUE
  ) +
  scale_edge_width(range = c(0.3, 1.5)) +
  scale_size(range = c(5, 10)) +
  theme_void() +
  ggtitle("Friendship Network (Size = Degree, Color = Community)") +
  theme(
    plot.title = element_text(hjust = 0.5),
    legend.position = c(0.7, 0.15),
    legend.box = "vertical"
  ) +
  guides(
    edge_width = guide_legend(title = "Edge Weight", direction = "horizontal"),
    color = guide_legend(title = "Community", direction = "horizontal"),
    size = guide_legend(title = "Degree", direction = "horizontal")
  )

# Optional: Save the plot
ggsave("Network_Demo_3_1.pdf", width = 8, height = 8)

# You can also plot the graph with node size indicating eigenvector centrality
set.seed(123)  # For reproducibility
ggraph(tg, layout = "kk") +
  geom_edge_link(
    aes(width = weight),
    alpha = 0.8,
    color = "gray70"
  ) +
  geom_node_point(
    aes(color = community,
        size = eigencent),
    alpha = 1
  ) +
  geom_node_label(
    aes(label = name),
    size = 3,
    label.size = 0.5,
    color = "black",
    fill = "#F8F8F8",
    fontface = "bold",
    alpha = 0.85,
    repel = TRUE
  ) +
  scale_edge_width(range = c(0.3, 1.5)) +
  scale_size(range = c(5, 10)) +
  theme_void() +
  ggtitle("Friendship Network (Size = Eigenvector Centrality, Color = Community)") +
  theme(
    plot.title = element_text(hjust = 0.5),
    legend.position = c(0.7, 0.15),
    legend.box = "vertical"
  ) +
  guides(
    edge_width = guide_legend(title = "Edge Weight", direction = "horizontal"),
    color = guide_legend(title = "Community", direction = "horizontal"),
    size = guide_legend(title = "Eigenvector Centrality", direction = "horizontal")
  )

# Optional: Save the plot
ggsave("Network_Demo_3_2.pdf", width = 8, height = 8)
