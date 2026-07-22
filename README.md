# ML-SDM2026
This repository contains datasets and scripts for reproducing the analyses and figures presented in:

"Evolution of machine learning-based species distribution models: technological development, research trends, and future challenges"

[![R](https://img.shields.io/badge/R-4.4+-276DC3)](https://www.r-project.org/)
[![RStudio](https://img.shields.io/badge/RStudio-2026.01.0-blue)](https://posit.co/download/rstudio-desktop/)
[![Python](https://img.shields.io/badge/python-3.10%20%7C%203.11-blue)](https://www.python.org/)
[![Bibliometrix](https://img.shields.io/badge/Bibliometrix-5.2.1-green)](https://www.bibliometrix.org/)
[![VOSviewer](https://img.shields.io/badge/VOSviewer-1.6.20-success)](https://www.vosviewer.com/)
[![HistCite](https://img.shields.io/badge/HistCite-2.1-yellow)](https://www.histcite.com/)

## Abstract
Species distribution models (SDM) have become important tools for biodiversity assessment, ecological prediction, and conservation planning. Recent advances in machine learning have greatly expanded the capability of SDM to analyze complex ecological data. However, the overall development trajectory, knowledge structure, and methodological implications of machine learning-based SDM (ML-SDM) remain insufficiently synthesized. This study provides a comprehensive review of ML-SDM research from 2006 to 2025 by integrating bibliometric analysis with methodology. Using 5,224 articles retrieved from the Web of Science Core Collection, we combined general bibliometric statistics, collaboration analysis, co-citation analysis, bibliographic coupling, temporal keyword evolution, and qualitative synthesis to investigate research trends, methodological development, knowledge accumulation, and future challenges. The results reveal that ML-SDM has undergone a progressive technological evolution rather than a simple transition from traditional machine learning to deep learning. Early studies established the methodological foundation through MaxEnt, Random Forest, and other machine learning algorithms, followed by advances in model evaluation, uncertainty assessment, and ecological applicability. Recent developments increasingly emphasize deep learning, ensemble modelling, remote sensing, and multi-source environmental data, reflecting an expansion from improving predictive accuracy toward modelling increasingly complex ecological information. The development and global dissemination of ML-SDM have been jointly driven by ecological demands, technological advances, expanding environmental data resources, and international collaboration. Co-citation and bibliographic coupling analyses further demonstrate that methodological innovation has accumulated through successive solutions to key modelling challenges rather than through the emergence of individual algorithms. Although SDM based on deep learning substantially expands the capability of ML-SDM for analysing high-dimensional and spatially structured ecological data, it remains a correlative modelling framework and does not replace traditional machine learning approaches. Challenges related to ecological interpretation, uncertainty assessment, spatial transferability, and model transparency continue to limit its practical application.


## Dataset

Literature data were retrieved from Web of Science Core Collection.

Search period:2006-2025

Document type:Article

Search strategy:

    TS = ("Species Distribution Model*" OR "Ecological Niche Model*" OR "Habitat Suitability Model*") AND ("machine learning" OR "MaxEnt" OR "Random Forest" OR "deep learning" OR "Convolutional Neural Network" OR "Graph Neural Network" OR "Multilayer Perceptron" OR "Transformer")

Web of Science records：``` data/WoS_raw_records/ 06-10.txt... ```

### Processed datasets

The processed datasets were generated from the Web of Science Core Collection records using Bibliometrix, HistCite, VOSviewer, and customized Python/R scripts. Each dataset was prepared for specific bibliometric analyses and figure generation.

#### Dataset were exported from the HistCite Pro (version 2.1)

- `yearlyOutput.xlsx`  
  Used for generating: Figures/3.1.png

- `Author_TGCS.csv`  
  Used for generating: Figures/3.5.2.pn

- `Institution_Res.csv`  
  Used for generating: Table 3: Top ten institutions by publications, TLCS, and TGCS

- `Journal_TGCS.csv`  
  Used for generating: Table 4: Top Twenty Journals by TGCS
  


#### Dataset were exported from the Biblioshiny interface of the Bibliometrix R package (version 5.2.1)

- `Most_Relevant_Countries.csv`  
  Used for generating: Figures/3.2.1.png and Figures/A.12.png

- `Author_Prod_over_Time_bibliometrix.xlsx`  
  Used for generating: Figures/3.5.2.png

- `paperMessage.xlsx`  
  Used as the main input dataset for keyword_year_merged.csv

#### Dataset were generated using Python scripts (version 3.10)

- `country_coauthorship_FINAL.csv`
 Used for generating: Figures/3.2.1.png

        Input: data/WoS_raw_records/V06-25(5224).txt       
        
        Run : source("code_python/country_coauthorship.py")

- `keyword_year_merged.csv `
 Used for generating: Figures/3.9.2.png

        Input: data/Processed/paperMassage.xlsx      
        
        Run : source("code_python/keyword_year.py")

----------------------------------------------------------------------------------------

## Reproducing the figures by RStudio (version 2026.01.0)
### Requirements

Install the required R packages before running the scripts.

```r
install.packages(c(
  "tidyverse",
  "ggrepel",
  "viridis",
  "RColorBrewer",
  "scales",
  "readxl",
  "readr",
  "sf",
  "rnaturalearth",
  "dplyr",
  "ggplot2",
  "cartogram",
  "countrycode",
  "RColorBrewer",
  "bibliometrix"
))
```

#### (1) 3.1.pdf：Temporal evolution of ML-SDM research from 2006 to 2025
Input ： 

    data/Processed/
    
    └── yearlyOutput.xlsx

Run : ``` source("code/R/Figure2_temporal_trend.R") ```

Output : ``` Figures/3.1.png ```

This figure illustrates the annual publication output, Total Global Citation Score (TGCS), and Total Local Citation Score (TLCS) from 2006 to 2025.

#### (2) 3.2.1.pdf：lobal distribution of publications and international collaboration networks in ML-SDM research
Input : 

    data/Processed/

    ├── country_coauthorship_FINAL.csv
    
    └── Most_Relevant_Countries.csv

Run : ``` source("code/R/international.R") ```

Output : ``` Figures/3.2.1.png ```

#### (3) 3.5.1.pdf: Top 10 Authors’ Publication Timeline Chart

Input :

    data/Processed/
    
    └── Author_Prod_over_Time_bibliometrix.xlsx

Run : ``` source("code/R/Author_production_overtime.R") ```

Output : ``` Figures/3.5.1.png ```

This figure illustrates the annual publication activity of the top 10 most productive authors from 2006 to 2025. Bubble size represents the number of articles published in each year, and bubble color indicates the total citation count.

#### (4) 3.5.2.pdf: Impact assessment of the top 20 authors based on TLCS and TGCS

Input :

    data/Processed/
    
    └── Author_TGCS.csv

Run : ``` source("code/R/Author_tgcs_tlcs.R") ```

Output : ``` Figures/3.5.2.png ```

This figure illustrates the citation impact of the top 20 authors in ML-SDM research. Bubble size represents the number of publications, while bubble color indicates the composite impact index calculated from standardized TLCS and TGCS values.

#### (5) 3.9.2.pdf: Life cycle evolution of major keywords in ML-SDM research from 2006 to 2025
Input :

    data/Processed/
    
    └── keyword_year_merged.csv

Run : ``` source("code/R/keywordsLife.R") ```

Output : ``` Figures/3.9.2.png ```

This figure illustrates the temporal evolution of 20 representative author keywords from 2006 to 2025. Bubble size represents the annual occurrence frequency of each keyword, while bubble color indicates the publication year.

#### (6) Appendix_1.pdf: Country-level distribution of SCP and MCP in ML-SDM research

Input :

    data/Processed/
    
    └── Most_Relevant_Countries.csv

Run : ``` source("code/R/MCP_SCP.R") ```

Output : ``` Figures/Appendix_1.png ```

This figure illustrates the country-level distribution of single-country publications (SCP) and multiple-country publications (MCP) among the top 20 countries in ML-SDM research. The stacked bars represent publication contributions from domestic and international collaborations.

#### (7) 3.6.1.pdf & 3.6.2.pdf: Three-field collaboration plots of countries, authors, institutions, and journals

Input :

``` data/Processed/WoS_raw_records/V06-25(5224).txt ```

Run :
```r
library('bibliometrix')
biblioshiny()
```
Settings:

    Analysis:Three-Field Plot

        Left Field: Countries (AU_CO)  Number of Items: 10

        Middle Field: Authors (AU)  Number of Items: 10

        Right Field: Affiliations (AU_UN)  Number of Items: 10

Output: Figures/3.6.1.png

Settings:

    Analysis:Three-Field Plot

        Left Field: Countries (AU_CO)  Number of Items: 10

        Middle Field: Authors (AU)  Number of Items: 10

        Right Field: Sources (SO)  Number of Items: 10

Output: Figures/3.6.2.png

This figure illustrates the relationships among countries, authors, institutions, and journals in ML-SDM research using three-field plots generated by the Biblioshiny interface of the Bibliometrix package.

## Reproducing the figures by VoSViewer (version 1.6.20)

#### (1) 3.7.pdf: Co-citation network of cited references generated using VoSViewer

Input :

    data/WoS_raw_records/V06-25(5224).txt

Settings:

    Type of analysis: Co-citation
    
    Unit of analysis: Cited References
    
    Counting method: Full counting
    
    Minimum number of citations of a cited reference: 30
    
    Number of cited references meeting the threshold: 732
    
    Selection: Top 500 references 

    Visualization: Network Visualization

Output : ``` Figures/3.7.png ```

This figure visualizes the co-citation network of cited references in ML-SDM research. Nodes represent cited references, node size indicates citation frequency, link thickness represents co-citation strength, and node colors denote clusters identified automatically by the VoSViewer clustering algorithm.

#### (2) 3.8.pdf: Bibliographical coupling network using VoSViewer

Input :

    data/WoS_raw_records/V06-25(5224).txt

Settings:

    Type of analysis: Bibliographic Coupling

    Unit of analysis: Documents

    Counting method: Full counting

    Minimum number of citations of a document: 50

    Number of documents meeting the threshold: 610

    Selection: Top 500 documents

    Visualization: Overlay Visualization

Output: ``` Figures/3.8.png ```

This figure visualizes the bibliographic coupling network of publications in ML-SDM research. Nodes represent individual publications, node size is proportional to total link strength, links indicate bibliographic coupling relationships, and node colors represent the average publication year in the overlay visualization.

#### (3) 3.9.1.pdf: Co-word network of author keywords visualized using VoSViewer

Input :

    data/WoS_raw_records/
    ├── V06-25(5224).txt
    └── sameWord.txt

Search strategy:

    TS = ("Species Distribution Model*" OR "Ecological Niche Model*" OR "Habitat Suitability Model*") AND ("machine learning" OR "MaxEnt" OR "Random Forest" OR "deep learning" OR "Convolutional Neural Network" OR "Graph Neural Network" OR "Multilayer Perceptron" OR "Transformer")

Settings:

    Type of analysis: Co-occurrence
    
    Unit of analysis: Author Keywords
    
    Counting method: Full counting
    
    Thesaurus file:  data/WoS_raw_records/sameWord.txt
    
    Minimum number of occurrences of a keyword: 5
    
    Number of keywords meeting the threshold: 643
    
    Selection: 500 most relevant keywords
    
    Visualization: Overlay Visualization

Output : ``` Figures/3.9.1.png ```

This figure visualizes the co-occurrence network of author keywords in ML-SDM research. Nodes represent keywords, node size indicates keyword occurrence frequency, links represent co-occurrence relationships, and node colors represent the average publication year of keywords. The thesaurus file (sameWord.txt) was applied to merge synonymous terms and improve keyword consistency before network construction.

#### (4) Figure/3.9.3.pdf: Co-word network of keywords in DL-SDM research

Input :

    data/WoS_raw_records/
    ├── DL-SDM18-15.txt
    └── sameWord.txt

Search strategy:

    TS =("Species Distribution Model*" OR "Ecological Niche Model*" OR "Habitat Suitability Model*")AND("deep learning" OR "Convolutional Neural Network" OR "Graph Neural Network" OR "Multilayer Perceptron" OR "Transformer")

Settings:

    Type of analysis: Co-occurrence
    
    Unit of analysis: Author Keywords
    
    Counting method: Full counting
    
    Minimum number of occurrences of a keyword: 2
    
    Visualization: Overlay Visualization

Output : ``` Figures/3.9.3.png ```

This figure visualizes the co-word network of keywords in DL-SDM research. Nodes represent keywords, node size indicates occurrence frequency, links represent keyword co-occurrence relationships, and node colors indicate the average publication year of associated studies. The overlay visualization highlights the temporal evolution of research topics from earlier studies to recent developments in DL-SDM.
