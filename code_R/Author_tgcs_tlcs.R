# =====================================================
# Author citation analysis based on TLCS and TGCS
# TLCS-TGCS bubble plot
# =====================================================


# ============================
# 1. 加载包
# ============================

library(tidyverse)
library(readr)
library(ggrepel)
library(scales)
library(viridis)

source("code_R/journal_style.R")


# ============================
# 2. 读取HistCite作者数据
# ============================

tgcs <- read_csv(
  "data/processed/Author_TGCS.csv"
)


# ============================
# 3. 数据整理
# Recs = Publications
# LCS  = TLCS
# GCS  = TGCS
# ============================

author_data <- tgcs %>%
  rename(
    NP = Recs,
    TLCS = LCS,
    TGCS = GCS
  )


# ============================
# 4. 选择同时进入
# TGCS Top20 和 TLCS Top20 的作者
# ============================


# TGCS Top20
top20_tgcs <- author_data %>%
  arrange(desc(TGCS)) %>%
  slice_head(n = 20)


# TLCS Top20
top20_tlcs <- author_data %>%
  arrange(desc(TLCS)) %>%
  slice_head(n = 20)


# ============================
# 5. 获取两个Top20的交集
# 并按照TGCS从高到低排列
# ============================

top20 <- author_data %>%
  filter(
    Author %in% top20_tgcs$Author &
      Author %in% top20_tlcs$Author
  ) %>%
  arrange(desc(TGCS)) %>%
  mutate(
    Order = row_number()
  )


# ============================
# 6. 输出筛选结果
# ============================


# 创建保存目录
output_dir <- "F:/PythonItem/bib/Second8.30/image"

dir.create(
  output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# 保存作者数据表
write_csv(
  top20,
  file.path(
    output_dir,
    "Author_TLCS_TGCS_intersection.csv"
  )
)


# 在控制台显示结果
print(
  top20 %>%
    select(
      Order,
      Author,
      NP,
      TLCS,
      TGCS
    )
)


# 查看最终筛选出的作者数量
cat(
  "\nNumber of authors included:",
  nrow(top20),
  "\n"
)


# ============================
# 7. 绘制气泡图
# ============================

p <- ggplot(
  top20,
  aes(
    x = TGCS,
    y = TLCS,
    size = NP
  )
) +
  
  # ============================
# 气泡
# ============================

geom_point(
  alpha = 0.65,
  color = "#21908C"
) +
  
  # ============================
# 作者标签
# ============================

geom_text_repel(
  aes(label = Author),
  
  size = 3.6,
  family = journal_font_family,
  color = "black",
  
  max.overlaps = Inf,
  
  # 标签距离
  box.padding = 0.7,
  point.padding = 0.4,
  
  # 引线
  segment.color = "grey70",
  segment.size = 0.35,
  
  # 防止文字压点
  force = 2.2
) +
  
  # ============================
# TGCS轴
# ============================

scale_x_log10(
  
  breaks = c(
    2000,
    3000,
    5000,
    10000,
    20000
  ),
  
  labels = scales::comma
) +
  
  # ============================
# TLCS轴
# ============================

scale_y_log10(
  
  breaks = c(
    500,
    1000,
    2000,
    3000,
    5000
  ),
  
  labels = scales::comma
) +
  
  # ============================
# 气泡大小
# ============================

scale_size_continuous(
  
  name = "Publications",
  
  range = c(3.5, 11),
  limits = c(1, 40),
  
  breaks = c(
    5,
    10,
    20,
    30,
    40
  ),
  
  labels = c(
    "5",
    "10",
    "20",
    "30",
    "40"
  )
) +
  
# ============================
# 图形显示范围
# ============================

coord_cartesian(
  
  xlim = c(
    2000,
    25000
  ),
  
  ylim = c(
    500,
    6500
  )
) +
  
  # ============================
# 坐标轴标题
# ============================

labs(
  
  x = "TGCS",
  
  y = "TLCS"
) +
  
  # ============================
# 基础主题
# ============================

journal_theme() +
  
  theme(
    
    # 主网格线
    panel.grid.major = element_line(
      color = "grey85",
      linewidth = 0.5
    ),
    
    # 删除次网格线
    panel.grid.minor = element_blank(),
    
    # 删除外框
    panel.border = element_blank(),
    
    # 坐标轴线
    axis.line = element_line(
      color = "black",
      linewidth = 0.9
    ),
    
    # ============================
    # 图例位置
    # ============================
    
    legend.position = "right",
    
    legend.box.spacing = unit(1, "mm"),
    
    legend.spacing.y = unit(1, "mm"),
    
    legend.key.height = unit(6, "mm"),
    
    legend.key.width = unit(5, "mm"),
    legend.margin = margin(0, 0, 0, 0, unit = "mm"),
    
    # ============================
    # 图边距
    # ============================
    
    plot.margin = margin(
      t = 4,
      r = 4,
      b = 4,
      l = 4,
      unit = "mm"
    ),
    
    # ============================
    # 坐标轴标题字体
    # ============================
    
    axis.title = element_text(
      face = "plain",
      size = 10
    ),
    
    # ============================
    # 坐标轴刻度字体
    # ============================
    
    axis.text = element_text(
      color = "black",
      size = 9
    ),
    
    # ============================
    # 图例标题字体
    # ============================
    
    legend.title = element_text(
      face = "plain",
      size = 8
    ),
    
    # ============================
    # 图例文字字体
    # ============================
    
    legend.text = element_text(
      size = 7
    )
  )


# ============================
# 8. 图例设置
# ============================

p <- p +
  guides(
    
    size = guide_legend(
      
      title = "Publications",
      
      title.position = "top",
      
      keyheight = unit(
        5,
        "mm"
      ),
      
      override.aes = list(
        alpha = 0.7
      )
    )
  )


# ============================
# 9. 显示图片
# ============================

if (interactive()) print(p)


# ============================
# 10. 高清保存
# ============================

save_journal_figure(
  plot = p,
  filename_stem = "Author_TLCS_TGCS_bubble"
)
