# ML-SDM2026
This repository contains datasets and scripts for reproducing the analyses and figures presented in:

"Evolution of machine learning-based species distribution models: technological development, research trends, and future challenges"

## Dataset

Literature data were retrieved from Web of Science Core Collection.

Search period:2006-2025

Document type:Article

Search strategy:

TS = ("Species Distribution Model*" OR "Ecological Niche Model*" OR "Habitat Suitability Model*") AND ("machine learning" OR "MaxEnt" OR "Random Forest" OR "deep learning" OR "Convolutional Neural Network" OR "Graph Neural Network" OR "Multilayer Perceptron" OR "Transformer")

## Repository structure

data/
Original and processed datasets

code/
R and Python scripts

figures/
Generated figures

## Reproducing the figures
### Requirements

Install the required R packages before running the scripts.

```r
install.packages(c(
  "tidyverse",
  "ggrepel",
  "viridis",
  "RColorBrewer",
  "scales"
))
```

### R-Figures/3.1.pdf：Temporal evolution of ML-SDM research from 2006 to 2025.
Input ： 

data/Processed/
└── yearlyOutput.xlsx

Run : source("code/R/Figure2_temporal_trend.R")

Output : Figures/3.1.png

This figure illustrates the annual publication output, Total Global Citation Score (TGCS), and Total Local Citation Score (TLCS) from 2006 to 2025.

### R-Figures/3.2.1.pdf：lobal distribution of publications and international collaboration networks in ML-SDM research
Input : 

data/Processed/
├── country_coauthorship_FINAL.csv
└── Most_Relevant_Countries.csv

Run : source("code/R/international.R")

Output : Figures/3.2.1.png




