# =====================================================
# Figure 4. Top 10 Authors' Publication Timeline Chart
#
# Description:
# This script generates the publication timeline of the
# top 10 most productive authors during 2006–2025.
# Bubble size represents the annual number of articles,
# while bubble color indicates the total citation count.
#
# Input:
#   data/Processed/Author_Prod_over_Time_bibliometrix.xlsx
#
# Output:
#   Figures/3.5.1.png
#
# Workflow:
#   1. Read author publication records.
#   2. Calculate the total number of publications for each author.
#   3. Select the top 10 most productive authors.
#   4. Generate the publication timeline.
#   5. Export the figure.
# =====================================================

# ==========================
# 1. 加载包
# ==========================

library(tidyverse)
library(readxl)
library(ggrepel)
library(scales)
library(viridis)


# ==========================
# 2. 读取数据
# ==========================

df <- read_excel(
  "data/Processed/Author_Prod_over_Time_bibliometrix.xlsx",
  skip = 1

  )

# 查看数据
head(df)

# ==========================
# 3. 修改列名
# ==========================

df <- df %>%
  rename(
    Author = `Author`,
    Year = year,
    NP_year = freq,
    TC = TC,
    TCpY = TCpY
  )

# ==========================
# 4. 计算作者总发文量
# 选择Top 10作者
# ==========================

author_order <- df %>%
  group_by(Author) %>%
  summarise(
    Total_Publications = sum(NP_year),
    .groups = "drop"
  ) %>%
  arrange(desc(Total_Publications)) %>%
  slice_head(n = 10)

# 保留Top10作者的数据

df <- df %>%
  filter(
    Author %in% author_order$Author
  )

# 设置Y轴顺序
df <- df %>%
  mutate(
    Author = factor(
      Author,
      levels = rev(author_order$Author)
    )
  )

# ==========================
# 5. 绘图
# ==========================
p <- ggplot(
  df,
  aes(
    x = Year,
    y = Author
  )
)+
  
  # 作者活动时间线
  
  geom_line(
    aes(group=Author),
    color="#D9A6A6",
    linewidth=0.6
  )+
  
  # 气泡
  geom_point(
    aes(
      size = NP_year,
      color = TC
    ),
    alpha = 0.75
  )+
  
  # 气泡大小
  scale_size_continuous(
    name="N. Articles",
    range=c(2,10),
    breaks=c(1,2,3,5,10)
  )+
  
  # 颜色
  scale_color_viridis(
    name="Total citations",
    option="viridis",
    direction=1
  )+
  
  # X轴年份
  scale_x_continuous(
    breaks=seq(
      min(df$Year),
      max(df$Year),
      by=2
    )
  )+
  
  labs(
    x="Year",
    y="Author"
  )+
  
  theme_bw(
    base_size=14
  )+
  
  theme(
    panel.grid.major.y =
      element_line(
        color="grey90"
      ),
    
    panel.grid.minor =
      element_blank(),
    
    panel.border =
      element_blank(),
    
    axis.line =
      element_line(
        color="black"
      ),
    
    axis.text.y =
      element_text(
        face="bold",
        size=11
      ),
    
    legend.position="right",
    
    legend.title =
      element_text(
        face="bold"
      )
    
  )
p
# ==========================
# 6. 高清保存
# ==========================
ggsave(
  "Author_production_over_time.png",
  p,
  width=14,
  height=6,
  units="in",
  dpi=600
)
