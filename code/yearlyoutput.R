# ==========================================================
# Bubble temporal evolution plot
# ML-SDM bibliometric analysis
# ==========================================================


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
  "F:/PythonItem/bib/FirstRevire6.29/SearchWords/DataSplit/HistCite/yearlyOutput.csv",
  header = TRUE
)


# 查看数据
head(data)


# 确保变量名称
colnames(data)

# 应包含:
# Year
# Records
# TLCS
# TGCS



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
  
  
  
  # 气泡大小
  #scale_size_continuous(
  #  name="Annual publications",
  #  range=c(4,20),
  #  breaks=c(200,400,600,800)
  #) +
  scale_size_area(
    name="Annual publications",
    max_size=18,
    breaks=c(50,100,200,400,600,800)
  )+
  
  
  
  # ======================
# viridis 配色
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
  "ML_SDM_temporal_bubble_viridis.png",
  p,
  width=14,
  height=8,
  dpi=600
)


p
