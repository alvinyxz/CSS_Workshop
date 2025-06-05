# ==============================================
# 1. Load necessary packages
# ==============================================
if (!require("igraph")) install.packages("igraph")

# ==============================================
# 2. Define node names and edge list
# ==============================================

# Assign human-readable names to each node
node_names <- c("Alice", "Bob", "Carlos", "Diana", "Eva", "Frank", "Grace", "Hannah",
                "Isaac", "Jack", "Kira", "Liam", "Mona", "Nina", "Oscar", "Priya")

# Create a name mapping: 1 = Alice, 2 = Bob, etc.
name_map <- setNames(node_names, 1:16)

# Edge list: connections between individuals
edges <- data.frame(
  from = name_map[c(1,1,1,1,2,2,2,3,3,4,3,4,7,7,7,7,1,12,13,13,13,14,14,15)],
  to   = name_map[c(2,3,4,5,3,4,5,4,5,5,6,7,8,9,10,11,12,13,14,15,16,15,16,16)]
)

# Take a look at the edge list
print(edges)

# ==============================================
# 3. Create and inspect the graph
# ==============================================
# Create a graph object from the edge list
graph_net <- graph_from_data_frame(edges, directed = FALSE)

# Inspect the graph structure
print(graph_net)
cat("Number of nodes:", vcount(graph_net), "\n")
cat("Number of edges:", ecount(graph_net), "\n")

# ==============================================
# 4. Basic plot of the network
# ==============================================
plot(graph_net,
     vertex.label = V(graph_net)$name,
     vertex.color = "lightblue",
     vertex.size = 20,
     edge.arrow.size = 0.5,
     main = "Basic Network Visualization")

# ==============================================
# 5. Different layout visualizations
# ==============================================
# Force-directed layout
plot(graph_net, layout = layout_with_fr, main = "Fruchterman-Reingold Layout")
# Tree layout
plot(graph_net, layout = layout_as_tree, main = "Tree Layout")
# Circular layout
plot(graph_net, layout = layout_in_circle, main = "Circular Layout")
# Kamada-Kawai layout
plot(graph_net, layout = layout_with_kk, main = "Kamada-Kawai Layout")

# ==============================================
# 6. Add weights and visualize
# ==============================================

# Create a new edge list with weights (tie strength)
edges_weighted <- data.frame(
  from = name_map[c(1,1,1,1,2,2,2,3,3,4,3,4,7,7,7,7,1,12,13,13,13,14,14,15)],
  to   = name_map[c(2,3,4,5,3,4,5,4,5,5,6,7,8,9,10,11,12,13,14,15,16,15,16,16)],
  weight = c(1,3,1,1,1,1,1,1,3,1,1,1,3,5,2,5,1,5,1,1,1,3,1,1)
)

# Create the weighted graph
graph_weighted <- graph_from_data_frame(edges_weighted, directed = FALSE)
# Assign edge width based on weight
E(graph_weighted)$width <- E(graph_weighted)$weight

# Plot with weights
plot(graph_weighted,
     layout = layout_with_fr,
     vertex.label = V(graph_weighted)$name,
     vertex.color = "lightgreen",
     vertex.size = 20,
     edge.width = E(graph_weighted)$width,
     main = "Network with Weighted Edges")

# ==============================================
# 7. Save the network as an image
# ==============================================
png("network_plot.png", width = 3000, height = 3000, unit = "px", res = 500)
plot(graph_weighted,
     layout = layout_with_fr,
     vertex.label = V(graph_weighted)$name,
     vertex.color = "lightgreen",
     vertex.size = 20,
     edge.width = E(graph_weighted)$width,
     main = "Saved Network Plot")
dev.off()
# Have a look at the saved image

# ==============================================
# Use ggraph to create a ggplot2 visualization [Optional]
# ==============================================

if (!require("ggraph")) install.packages("ggraph")
if (!require("tidygraph")) install.packages("tidygraph")

# 5. Make a beautiful plot using ggraph and tidygraph
tg <- as_tbl_graph(graph_weighted) %>%
  mutate(community = as.factor(group_louvain())) %>% # Community detection for coloring
  mutate(size = centrality_degree()) %>% # Calculate node degree for sizing
  activate(edges) %>%
  mutate(weight = weight)  # ensure 'weight' exists

set.seed(123)  # For reproducibility
ggraph(tg, layout = "fr") +
  # layout options: kk, fr, circle, tree, dendrogram
  geom_edge_link(aes(width = weight),  # Tie weight visualized as thickness
                 alpha = 0.9,          # Transparency of edges
                 color = "gray70") +   # Edge color
  geom_node_point(aes(size = size,           # Node size based on degree
                      color = community),    # Color by community
                  alpha = 0.9) +             # Transparency of nodes
  geom_node_label(
    aes(label = name),   # Node labels
    size = 3,            # Label size
    label.size = 0.3,    # Border size around labels
    color = "black",     # Label color
    fill = "#F8F8F8",    # Label background color
    fontface = "bold",   # Bold labels
    alpha = 0.7,         # Transparency of labels
    repel = TRUE         # Repel labels to avoid overlap
  ) +
  scale_edge_width(range = c(0.2, 1)) + # Edge width range
  scale_size(range = c(4, 10)) +        # Node size range
  theme_void() +
  labs(edge_width = "Tie Strength",     # legend settings
       size = "Node Degree",
       color = "Community") +
  theme(
    legend.position = c(0.2, 0.3),   # (x, y) in [0, 1] relative to plot area
    legend.box = "horizontal"        # optional: stack all legends vertically
  )

ggsave("network_plot_ggraph.pdf",
       width = 10,
       height = 7)
# Have a look at the saved image
