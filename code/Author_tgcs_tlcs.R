# =====================================================
# Author impact analysis based on TLCS and TGCS
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


# ============================
# 2. 读取HistCite作者数据
# ============================

tgcs <- read_csv(
  "F:/PythonItem/bib/FirstRevire6.29/SearchWords/DataSplit/HistCite/Author_TGCS.csv"
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
# 4. 综合影响力指数
# Impact = Z(TLCS)+Z(TGCS)
# ============================

author_rank <- author_data %>%
  mutate(
    
    TLCS_Z = as.numeric(scale(TLCS)),
    
    TGCS_Z = as.numeric(scale(TGCS))
    
  ) %>%
  
  mutate(
    
    Impact = TLCS_Z + TGCS_Z
    
  ) %>%
  
  arrange(desc(Impact))



# ============================
# 5. 选择Top20作者
# ============================

top20 <- author_rank %>%
  slice_head(n=20)


# 输出Top20结果

write_csv(
  top20,
  "Author_TLCS_TGCS_Top20.csv"
)


print(
  top20 %>%
    select(
      Author,
      NP,
      TLCS,
      TGCS,
      Impact
    )
)



# ============================
# 6. 设置标签作者
# 只显示Impact最高10位
# ============================

label_data <- top20 %>%
  arrange(desc(Impact)) %>%
  slice(1:10)



# ============================
# 7. 绘制气泡图
# ============================

# =====================================================
# 绘制双指标气泡图（全部作者标注）
# =====================================================

p <- ggplot(
  top20,
  aes(
    x = TGCS,
    y = TLCS,
    size = NP,
    color = Impact
  )
)+
  
  
  # 气泡透明度调整
  geom_point(
    alpha = 0.55
  )+
  
  
  
  # 全部作者标注
  geom_text_repel(
    aes(label = Author),
    size = 3.8,
    max.overlaps = Inf,
    
    # 标签距离
    box.padding = 0.6,
    point.padding = 0.35,
    
    # 引线
    segment.color = "grey70",
    segment.size = 0.3,
    
    # 防止文字压点
    force = 2
  )+
  
  
  
  # TGCS轴
  scale_x_log10(
    breaks=c(
      2000,
      3000,
      5000,
      10000,
      20000
    ),
    labels=scales::comma
  )+
  
  
  
  # TLCS轴
  scale_y_log10(
    breaks=c(
      500,
      1000,
      2000,
      3000,
      5000
    ),
    labels=scales::comma
  )+
  
  
  
  # 气泡大小
  # 气泡大小（真实发文量）
  scale_size_continuous(
    name="Publications",
    range=c(3,11),
    breaks=c(5,10,20,40),
    labels=c(
      "5",
      "10",
      "20",
      "40"
    )
  )+
  
  
  
  # viridis颜色
  scale_color_viridis_c(
    option="viridis",
    name="Impact index"
  )+
  
  
  
  # 范围
  coord_cartesian(
    xlim=c(2000,25000),
    ylim=c(500,6500)
  )+
  
  
  
  labs(
    x="TGCS (Global Citation Score)",
    y="TLCS (Local Citation Score)"
  )+
  
  
  
  theme_bw(
    base_size = 15
  )+
  theme(
    
    panel.grid.major = element_line(
      color="grey85",
      linewidth=0.4
    ),
    
    panel.grid.minor = element_blank(),
    
    panel.border = element_blank(),
    
    axis.line = element_line(
      color="black",
      linewidth=0.8
    )
  )+
  
  
  theme(
    
    panel.grid.major = element_line(
      color="grey85",
      linewidth=0.4
    ),
    
    panel.grid.minor = element_blank(),
    
    panel.border = element_blank(),
    
    axis.line = element_line(
      color="black",
      linewidth=0.8
    ),
    
    
    # 图例设置
    legend.position="right",
    
    legend.box.spacing = unit(0.3,"cm"),
    
    legend.spacing.y = unit(0.3,"cm"),
    
    legend.key.height = unit(0.8,"cm"),
    
    legend.key.width = unit(0.5,"cm"),
    
    
    # 不要给右侧留太大空间
    plot.margin = margin(
      t=20,
      r=40,
      b=20,
      l=20
    ),
    
    
    axis.title =
      element_text(
        face="bold",
        size=16
      ),
    
    axis.text =
      element_text(
        color="black",
        size=14
      ),
    
    
    legend.title =
      element_text(
        face="bold",
        size=14
      ),
    
    legend.text =
      element_text(
        size=12
      )
    
  )


p

p <- p +
  guides(
    
    size = guide_legend(
      title="Publications",
      title.position="top",
      keyheight=unit(0.5,"cm"),
      override.aes=list(
        alpha=0.7
      )
    ),
    
    
    color = guide_colorbar(
      title="Impact index",
      title.position="top",
      barheight=unit(2.8,"cm"),
      barwidth=unit(0.35,"cm")
    )
    
  )

# =====================================================
# 8. 高清保存
# =====================================================


# 保存路径

out_path <- 
  "F:/PythonItem/bib/FirstRevire6.29/SearchWords/DataSplit/HistCite/Author_TLCS_TGCS_bubble"



# TIFF（论文推荐）

ggsave(
  paste0(out_path,".tiff"),
  plot=p,
  width=9,
  height=6,
  units="in",
  dpi=600,
  compression="lzw"
)



# PNG备用

ggsave(
  paste0(out_path,".png"),
  plot=p,
  width=9,
  height=6,
  units="in",
  dpi=600
)
