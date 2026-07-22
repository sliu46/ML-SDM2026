# =====================================================
# Figure 3.1. Temporal evolution of ML-SDM research
# from 2006 to 2025
#
# Description:
# This script generates a temporal bubble plot showing
# the annual development of ML-SDM research from 2006
# to 2025.
#
# The x-axis represents publication year.
# The y-axis represents Total Global Citation Score
# (TGCS).
# Bubble size indicates annual publication output,
# and bubble color represents Total Local Citation
# Score (TLCS).
#
# Input:
#   data/Processed/yearlyOutput.csv
#
# Output:
#   Figures/3.1.png
#
# Workflow:
#   1. Load required R packages for data processing
#      and visualization.
#   2. Read annual bibliometric statistics.
#   3. Standardize variables including publication
#      year, annual records, TLCS, and TGCS.
#   4. Generate the bubble temporal evolution plot.
#   5. Map annual publication output to bubble size
#      and TLCS values to bubble color.
#   6. Add TGCS temporal trend line and year labels.
#   7. Export the final figure.
#
# =====================================================

# --------------------------
# 1. 加载包
# --------------------------

library(tidyverse)
library(scales)
library(ggrepel)
library(RColorBrewer)
library(viridis)

# --------------------------
# 2. 读取数据
# --------------------------
data <- read.csv(
  "data/Processed/yearlyOutput.csv",
  header = TRUE
)

# 查看数据
head(data)

# 确保变量名称
colnames(data)

# --------------------------
# 3. 数据处理
# --------------------------
data <- data %>%
  mutate(
    Year = as.numeric(Publication.Year),
    Records = as.numeric(Recs),
    TLCS = as.numeric(LCS),
    TGCS = as.numeric(GCS)
  )

# ==========================
# 3. 绘图
# ==========================

p <- ggplot(
  data,
  aes(
    x = Year,
    y = TGCS,
    size = Records,
    color = TLCS
  )
) +
  
  geom_line(
    aes(group=1),
    #method="loess",
    #se=FALSE,
    linewidth=1.2,
    color="grey40",
    linetype="dashed",
    show.legend = FALSE
  )+
  
  # TGCS参考线
  geom_hline(
    yintercept = c(2500,5000,7500,10000,12500,15000,17500),
    color="grey80",
    linewidth=0.4,
    linetype="dashed"
  )+
  
  # 气泡
  geom_point(
    alpha=0.75,
    stroke=0.8
  ) +
  
  # 年份标签
  geom_text_repel(
    aes(label=Year),
    size=4,
    fontface="bold",
    max.overlaps=30,
    box.padding=0.35,
    point.padding=0.2
  ) +
  
  scale_size_area(
    name="Annual publications",
    max_size=18,
    breaks=c(50,100,200,400,600,800)
  )+
  
# ======================
# viridis 
# ======================

scale_color_viridis(
  option="viridis",
  direction=1,
  name="TLCS"
) +
  
  scale_x_continuous(
    breaks=data$Year,
    expand=c(0.03,0.03)
  ) +
  
  scale_y_continuous(
    breaks = seq(0, 17500, by = 2500),
    labels = scales::comma,
    expand = expansion(mult = c(0.05,0.05))
  ) +
  
  labs(
    x="Publication year",
    y="Total Global Citation Score (TGCS)",
    subtitle=
      "The size of the bubbles represents the annual publications; the color changes indicate TLCS;
the dotted line reflects TGCS."
  ) +
  
  theme_classic(
    base_size=16
  ) +
  
  theme(
    
    plot.title =
      element_text(
        size=20,
        face="bold"
      ),
    
    plot.subtitle =
      element_text(
        size=14
      ),
    
    axis.title =
      element_text(
        size=16,
        face="bold"
      ),
    
    axis.text =
      element_text(
        size=14,
        color="black"
      ),
    
    legend.title =
      element_text(
        size=14,
        face="bold"
      ),
    
    legend.text =
      element_text(
        size=12,
      ),
    
    legend.position="right"
    
  )

# ==========================
# 4. 输出
# ==========================
ggsave(
  "Figures/3.1.png",
  p,
  width=14,
  height=8,
  dpi=600
)


p
