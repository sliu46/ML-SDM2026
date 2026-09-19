# =====================================================
# Author production over time
# Bubble timeline plot
# =====================================================


# ==========================
# 1. 加载包
# ==========================

library(tidyverse)
library(readxl)
library(ggrepel)
library(scales)
library(viridis)

source("code_R/journal_style.R")


# ==========================
# 2. 读取数据
# ==========================

df <- read_excel(
  "data/processed/Author_Prod_over_Time_bibliometrix.xlsx",
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
    breaks=c(1,2,5,10)
  )+
  
  
  
  # 颜色
  
  scale_color_viridis(
    name="Total\ncitations",
    option="viridis",
    direction=1
  )+

  guides(
    size = guide_legend(
      title.position = "top",
      title.hjust = 0.5,
      keyheight = unit(6, "mm"),
      order = 1
    ),
    color = guide_colorbar(
      title.position = "top",
      title.hjust = 0.5,
      direction = "vertical",
      barwidth = unit(3, "mm"),
      barheight = unit(22, "mm"),
      order = 2
    )
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
  
  
  
  journal_theme() +
  
  
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
        size=9
      ),
    axis.text.x =
      element_text(
        size=9,
        color="black"
      ),
    axis.title =
      element_text(
        size=10,
        face="plain"
      ),
    
    
    legend.position="right",
    legend.direction="vertical",
    legend.box="vertical",
    legend.box.just="center",
    legend.box.spacing=unit(1, "mm"),
    legend.spacing.y=unit(1, "mm"),
    legend.key.width=unit(5, "mm"),
    legend.key.height=unit(6, "mm"),
    legend.margin=margin(0, 0, 0, 0, unit="mm"),
    
    
    legend.title =
      element_text(
        face="plain",
        size=9
      ),
    legend.text =
      element_text(
        size=8
      ),
    
  )



if (interactive()) print(p)



# ==========================
# 6. 高清保存
# ==========================

save_journal_figure(
  plot = p,
  filename_stem = "Author_production_over_time"
)
