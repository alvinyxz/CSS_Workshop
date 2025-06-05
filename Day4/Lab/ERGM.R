# Adopted from
# https://cran.r-project.org/web/packages/ergm/vignettes/ergm.html
# You can read the above vignette for more details

# =============================
# Introduction to ERGMs with statnet
# =============================

# Install these packages if you haven’t before:
# install.packages("ergm")
library("ergm")

# Set seed to make results reproducible
set.seed(0)

# =============================
# 1. Load the example network
# =============================

# Load built-in data: marriage ties among Renaissance Florentine families
data(florentine)  # loads flomarriage and flobusiness
flomarriage  # inspect the network object

# Check the vertex (node) attributes
network.vertex.names(flomarriage)
list.vertex.attributes(flomarriage)

# Plot the network
plot(flomarriage, 
     main = "Florentine Marriage Network",
     label = network.vertex.names(flomarriage))

# =============================
# 2. Visualize node attribute: wealth
# =============================

wealth <- flomarriage %v% "wealth"  # get wealth for each family
plot(flomarriage,
     vertex.cex = wealth / 25,  # make node size proportional to wealth
     label = network.vertex.names(flomarriage),
     main = "Node Size = Wealth")

# =============================
# 3. Fit a simple ERGM: Bernoulli model
# =============================

# This is like saying: "Let’s just model tie probability using one parameter: density"
summary(flomarriage ~ edges)  # check observed number of edges
model1 <- ergm(flomarriage ~ edges)  # fit model
summary(model1)
# Interpret the coefficient:
# A negative edge coefficient means low overall density (few ties)

# =============================
# 4. Add structural effects: triangles
# =============================
# Let’s model clustering by adding triangle term

summary(flomarriage ~ edges + triangle)
model2 <- ergm(flomarriage ~ edges + triangle)
summary(model2)
# The triangle coefficient tells us whether a tie is more/less likely to form to close a triad (friend-of-a-friend)
# The triangle coefficient here is positive: It is more likely for edges to form that would close triangles than edges connecting random pairs of nodes
# However, the coefficient is not statistically significant, indicating that triangles are not a strong predictor

# =============================
# 5. Include node-level covariates: wealth
# =============================

summary(flomarriage ~ edges + nodecov("wealth"))
model3 <- ergm(flomarriage ~ edges + nodecov("wealth"))
summary(model3)
# Interpretation:
# wealth coefficient: positive and significant, which means that
# wealthier families are more likely to have marriage ties

# =============================
# 6. Fit a more complex model: homophily on wealth
# =============================

# This checks whether ties are more likely between similarly wealthy families
model4 <- ergm(flomarriage ~ edges + absdiff("wealth"))
summary(model4)
# Interpretation:
# absdiff("wealth") coefficient: positive and significant, which means that
# families with larger wealth differences are more likely to form marriage ties

# =============================
# 7. What if we include both wealth and homophily?
# =============================
model5 <- ergm(flomarriage ~ edges + nodecov("wealth") + absdiff("wealth"))
summary(model5)
# Interpretation:
# The wealth coefficient: positive but not significant
# The absdiff("wealth") coefficient: positive but not significant
# Both coefficients are not significant, however (the wealth coefficient used to be significant)

# Now you should see the potential issues with ERGM:
# You can include or exclude terms, potentially "p-hacking"
# Similar to regression
