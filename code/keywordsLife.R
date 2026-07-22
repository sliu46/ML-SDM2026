# =====================================================
# Figure 10. Life cycle evolution of major keywords in ML-SDM research from 2006 to 2025.
#
# Description:
# This script generates the life cycle evolution of
# 20 representative author keywords in ML-SDM research.
# Bubble size represents the annual occurrence frequency
# of each keyword, while bubble color indicates the
# publication year.
#
# Input:
#   data/Processed/keyword_year_merged.csv
#
# Output:
#   Figures/3.9.2.png
#
# Workflow:
#   1. Read the keyword occurrence dataset.
#   2. Select the 20 representative author keywords.
#   3. Transform the dataset into a long format.
#   4. Remove records with zero annual occurrences.
#   5. Rank keywords according to their total occurrence frequency.
#   6. Generate the keyword life cycle bubble chart.
#   7. Export the figure.
# =====================================================

library(tidyverse)
library(viridis)

#===============================
# 读取数据
#===============================

file_path <- "data/Processed/keyword_year_merged.csv"

df <- read.csv(
  file_path,
  stringsAsFactors = FALSE,
  check.names = FALSE
)

colnames(df)[1] <- "Keyword"

#===============================
# 20个关键词
#===============================

keywords <- c(
  "sdm",
  "maxent",
  "climate change",
  "habitat-suitability",
  "machine learning",
  "random forest",
  "potential distribution",
  "biological invasion",
  "habitat-suitability model",
  "remote sensing",
  "biogeography",
  "conservation plan",
  "protected area",
  "environment variables",
  "gis",
  "global warming",
  "biodiversity",
  "ensemble model",
  "deep learning",
  "citizen science"
)

#===============================
# 数据整理
#===============================

life_data <- df %>%
  filter(Keyword %in% keywords)

life_long <- life_data %>%
  pivot_longer(
    cols = -Keyword,
    names_to = "Year",
    values_to = "Frequency"
  )

life_long$Year <- as.numeric(life_long$Year)

life_long$Frequency[is.na(life_long$Frequency)] <- 0

life_plot <- life_long %>%
  filter(Frequency > 0)

#===============================
# 按总频率排序
#===============================

keyword_order <- life_long %>%
  group_by(Keyword) %>%
  summarise(Total = sum(Frequency), .groups="drop") %>%
  arrange(desc(Total)) %>%
  pull(Keyword)

life_plot$Keyword <- factor(
  life_plot$Keyword,
  levels = rev(keyword_order)
)

#===============================
# 最大频率
#===============================

max_freq <- max(life_plot$Frequency)

print(max_freq)

#===============================
# 绘图
#===============================

p <- ggplot(
  life_plot,
  aes(
    x = Year,
    y = Keyword
  )
) +
  
  ## 生命周期线
  geom_line(
    aes(group = Keyword),
    linewidth = 0.55,
    colour = "grey70",
    alpha = 0.8
  ) +
  
  ## 气泡
  geom_point(
    aes(
      size = Frequency,
      fill = Year
    ),
    shape = 21,
    colour = "grey25",
    stroke = 0.25,
    alpha = 0.9
  ) +
  
  ## 点大小（真实频率）
  scale_size_continuous(
    range = c(1.5, 10),
    breaks = c(1,10,20,50,100,200,300),
    limits = c(1, max_freq),
    name = "Annual frequency"
  ) +
  
  ## 年份颜色
  scale_fill_viridis_c(
    option = "viridis",
    limits = c(2006,2025),
    breaks = c(2006,2010,2015,2020,2025),
    name = "Publication year"
  ) +
  
  scale_x_continuous(
    breaks = seq(2006,2025,3)
  ) +
  
  labs(
    x = "Publication year",
    y = NULL,
    title = "Life cycle evolution of major keywords in SDM research (2006–2025)"
  ) +
  
  theme_bw(base_size = 12) +
  
  theme(
    
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    
    panel.grid.major.x =
      element_line(
        colour = "grey90",
        linewidth = 0.4
      ),
    
    axis.text.y =
      element_text(
        size = 13,
        colour = "black"
      ),
    
    axis.text.x =
      element_text(
        size = 13,
        colour = "black"
      ),
    
    axis.title.x =
      element_text(
        size = 16,
        face = "bold"
      ),
    
    plot.title =
      element_text(
        hjust = 0.5,
        size = 20,
        face = "bold"
      ),
    
    legend.position = "right",
    
    legend.title =
      element_text(
        size = 14,
        face = "bold"
      ),
    
    legend.text =
      element_text(
        size = 12
      )
  )

print(p)

#===============================
# 保存
#===============================

ggsave(
  "Figures/3.9.2.png",
  p,
  width = 14,
  height = 8,
  dpi = 600
)
