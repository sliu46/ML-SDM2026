# =====================================================
# Figure A.12. Country-level distribution of SCP and MCP
# publications in ML-SDM research
#
# Description:
# This script generates a stacked bar chart showing the
# distribution of single-country publications (SCP) and
# multiple-country publications (MCP) among the top 20
# countries in ML-SDM research.
#
# Countries are ranked according to total publication
# output (SCP + MCP). SCP represents publications
# produced by authors from the same country, while MCP
# represents publications involving international
# collaboration.
#
# Input:
#   data/Processed/Most_Relevant_Countries.csv
#
# Output: Figures/Appendix_1.png
#
# Workflow:
#   1. Load required R packages.
#   2. Read country-level bibliometric statistics.
#   3. Extract country, SCP, MCP, and publication counts.
#   4. Calculate total publications (SCP + MCP).
#   5. Select the top 20 countries according to total output.
#   6. Reshape SCP and MCP data into long format.
#   7. Generate a stacked horizontal bar chart.
#   8. Export the final figure.
#
# =====================================================
# =========================
# 1. 加载包
# =========================
library(tidyverse)

# =========================
# 2. 读取数据
# =========================
df <- read.csv(
  "data/Processed/Most_Relevant_Countries.csv",
  skip = 1
  )
# 查看列名（确保结构）
str(df)
# =========================
# 3. 保留关键变量
# =========================
df <- df %>%
  select(Country, SCP, MCP, Articles)
# =========================
# 4. 计算总量 + 选Top20
# =========================
df_top20 <- df %>%
  mutate(Total = SCP + MCP) %>%
  arrange(desc(Total)) %>%
  slice(1:20)
# =========================
# 5. 转长格式
# =========================
df_long <- df_top20 %>%
  pivot_longer(
    cols = c(SCP, MCP),
    names_to = "Type",
    values_to = "Documents"
  )
# =========================
# 6. 国家排序（Top10从大到小）
# =========================
df_long$Country <- factor(
  df_long$Country,
  levels = df_top20$Country
)
# =========================
# 7. 配色
# =========================
pal <- c(
  "SCP" = "#22A785",
  "MCP" = "#424086"
)
# =========================
# 8. 画图
# =========================
p <- ggplot(df_long, aes(x = Documents, y = Country, fill = Type)) +
  geom_bar(stat = "identity", width = 0.7) +
  scale_fill_manual(values = pal) +
  labs(
    x = "Number of Documents",
    y = "Country",
    fill = "Collaboration"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    axis.title = element_text(face = "bold"),
    legend.position = "right"
  )

# =========================
# 9. 导出高清图
# =========================
ggsave(
  "Figures/Appendix_1.png",
  plot = p,
  width = 9,
  height = 6,
  dpi = 600
)

p
