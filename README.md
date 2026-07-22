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

### R-Figures/3.5.1.pdf: Top 10 Authors’ Publication Timeline Chart.

Input :

data/Processed/
└── Author_Prod_over_Time_bibliometrix.xlsx

Run : source("code/R/Author_production_overtime.R")

Output : Figures/3.5.1.png

This figure illustrates the annual publication activity of the top 10 most productive authors from 2006 to 2025. Bubble size represents the number of articles published in each year, and bubble color indicates the total citation count.

### R-Figures/3.5.2.pdf: Impact assessment of the top 20 authors based on TLCS and TGCS.

Input :

data/Processed/
└── Author_TGCS.csv

Run : source("code/R/Author_tgcs_tlcs.R")

Output : Figures/3.5.2.png

This figure illustrates the citation impact of the top 20 authors in ML-SDM research. Bubble size represents the number of publications, while bubble color indicates the composite impact index calculated from standardized TLCS and TGCS values.

### R-Figures/3.9.2.pdf: Life cycle evolution of major keywords in ML-SDM research from 2006 to 2025.
Input :

data/Processed/
└── keyword_year_merged.csv

Run : source("code/R/keywordsLife.R")

Output : Figures/3.9.2.png

This figure illustrates the temporal evolution of 20 representative author keywords from 2006 to 2025. Bubble size represents the annual occurrence frequency of each keyword, while bubble color indicates the publication year.



