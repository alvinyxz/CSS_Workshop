# Day 4

Today, we’ll explore how to analyze and visualize social, semantic, and topic networks using R. You’ll get hands-on with ERGM models, create semantic networks from text, and build elegant network visualizations using igraph, tidygraph, and ggraph.

## Slides & Introduction

We’ll start with a quick walkthrough of `Day4_Lab.pdf` to inspire you to think of the possibilities with network analysis in social science research.

## Part 1: Exponential Random Graph Models (ERGM)

Open the file ERGM.R. We’ll build and analyze a small network using the `ergm` package. ERGMs are powerful tools for modeling the structure of social networks while accounting for non-independence between ties.

## Part 2: Semantic Network Construction

Go to this link to download the three files in the folder: https://drive.google.com/drive/folders/1sQ-ATsCkXYERRb3FHKZDYT9HcDgfXQlB?usp=sharing

Open the file Semantic_Network.R. Here, we’ll use co-occurrence of words in government agencies' COVID-19 Facebook posts to build semantic networks. This demonstrates how networks can be used not only to model people or organizations, but also ideas and meaning structures.

You can also read my paper to see how I used this semantic network in my paper. One thing to note is that the three files used in this example `Agency.csv`, `Congress.csv`, and `Hospital.csv` (in this folder) are not the exactly same as the ones used in the paper, because my paper used a larger dataset. However, the code and methodology remain the same.

- Zhou, A., Liu, W., & Yang, A. (2024). Politicization of science in COVID-19 vaccine communication: Comparing US politicians, medical experts, and government agencies. *Political Communication, 41*(4), 649–671. https://doi.org/10.1080/10584609.2023.2201184

## Part 3: Network Visualization

Finally, open Network_Visualization.R, where we’ll make networks interpretable via visualization.