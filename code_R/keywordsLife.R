############################################################
# Keyword Life Cycle Analysis
# SDM research 2006-2025
############################################################

library(tidyverse)
library(viridis)

source("F:/PythonItem/bib/Second8.30/image/code/journal_style.R")

#===============================
# 读取数据
#===============================

file_path <- "F:/PythonItem/bib/FirstRevire6.29/SearchWords/DataSplit/R/keyword/keyword_year_merged.csv"

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
    cols = matches("^[0-9]{4}$"),
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
    range = c(1.5, 8),
    breaks = c(1,10,50,100,300),
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
    y = NULL
  ) +
  guides(
    fill = guide_colorbar(
      title.position = "top",
      title.hjust = 0,
      direction = "vertical",
      barwidth = unit(3, "mm"),
      barheight = unit(22, "mm"),
      order = 1
    ),
    size = guide_legend(
      title.position = "top",
      title.hjust = 0,
      direction = "vertical",
      ncol = 1,
      byrow = TRUE,
      order = 2
    )
  ) +
  
  journal_theme() +
  
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
        size = 9,
        colour = "black"
      ),
    
    axis.text.x =
      element_text(
        size = 9,
        colour = "black"
      ),
    
    axis.title.x =
      element_text(
        size = 10,
        face = "plain"
      ),
    
    plot.title =
      element_text(
        hjust = 0.5,
        size = 11,
        face = "bold"
      ),
    
    legend.position = "right",
    legend.direction = "vertical",
    legend.box = "vertical",
    legend.box.just = "left",
    legend.box.spacing = unit(1, "mm"),
    legend.spacing.y = unit(1, "mm"),
    legend.key.width = unit(5, "mm"),
    legend.key.height = unit(4.5, "mm"),
    
    legend.title =
      element_text(
        size = 8,
        face = "plain"
      ),
    
    legend.text =
      element_text(
        size = 7
      )
  )

if (interactive()) print(p)

#===============================
# 保存
#===============================

save_journal_figure(
  plot = p,
  filename_stem = "SDM_keyword_life_cycle"
)
