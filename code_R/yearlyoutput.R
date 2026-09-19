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

source("code_R/journal_style.R")


# --------------------------
# 2. 读取数据
# --------------------------

data <- read.csv(
  "data/processed/yearlyOutput.csv",
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
    aes(size = Records),
    alpha=0.75,
    stroke=0.8
  ) +
  
  
  
  # 年份标签
  geom_text_repel(
    aes(label=Year),
    size=3.2,
    family=journal_font_family,
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
    max_size=12,
    limits=c(0, max(data$Records, na.rm=TRUE)),
    breaks=c(50,100,200,400,600)
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
    breaks=seq(min(data$Year), max(data$Year), by=2),
    expand=c(0.03,0.03)
  ) +
  
  
  
  scale_y_continuous(
    breaks = seq(0, 17500, by = 2500),
    labels = scales::comma,
    expand = expansion(mult = c(0.05,0.05))
  ) +
  
  
  
  labs(
    x="Publication year",
    y="Total Global Citation Score (TGCS)"
  ) +
  guides(
    color = guide_colorbar(
      title.position = "top",
      title.hjust = 0.5,
      direction = "horizontal",
      barwidth = unit(30, "mm"),
      barheight = unit(2.5, "mm"),
      order = 1
    ),
    size = guide_legend(
      title.position = "top",
      title.hjust = 0.5,
      direction = "horizontal",
      nrow = 1,
      byrow = TRUE,
      keywidth = unit(11, "mm"),
      keyheight = unit(11, "mm"),
      override.aes = list(
        color = "grey40",
        alpha = 0.75
      ),
      order = 2
    )
  ) +
  
  
  
  journal_theme(
    theme_classic(
      base_size = journal_base_size,
      base_family = journal_font_family
    )
  ) +
  
  
  theme(
    
    plot.title =
      element_text(
        size=11,
        face="bold"
      ),
    
    
    plot.subtitle =
      element_text(
        size=9
      ),
    
    
    axis.title =
      element_text(
        size=10,
        face="plain"
      ),
    
    
    axis.text =
      element_text(
        size=9,
        color="black"
      ),
    
    
    legend.title =
      element_text(
        size=8,
        face="plain"
      ),
    
    legend.text =
      element_text(
        size=7,
      ),
    
    
    legend.position="bottom",
    legend.direction="horizontal",
    legend.box="horizontal",
    legend.box.just="center",
    legend.box.spacing=unit(1, "mm"),
    legend.spacing.x=unit(1, "mm"),
    legend.key.width=unit(6, "mm"),
    legend.key.height=unit(3, "mm"),
    legend.margin=margin(0, 0, 0, 0, unit="mm")
    
  )



# ==========================
# 4. 输出
# ==========================


save_journal_figure(
  plot = p,
  filename_stem = "ML_SDM_temporal_bubble"
)


if (interactive()) print(p)
