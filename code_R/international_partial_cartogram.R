# =========================
# 1. 加载包
# =========================
library(sf)
library(rnaturalearth)
library(dplyr)
library(ggplot2)
library(cartogram)
library(countrycode)
library(scales)

source("F:/PythonItem/bib/Second8.30/image/code/journal_style.R")

# =========================
# 2. 读取矩阵
# =========================
mat <- read.csv(
  "F:/PythonItem/bib/FirstRevire6.29/SearchWords/DataSplit/country_coauthorship_FINAL.csv",
  row.names = 1,
  check.names = FALSE
)

pub_df <- read.csv(
  "F:/PythonItem/bib/FirstRevire6.29/SearchWords/DataSplit/Most_Relevant_Countries.csv",
  skip = 1
)

# =========================
# 3. edges + 阈值 + 去重核心
# =========================
edges <- as.data.frame(as.table(as.matrix(mat)))
colnames(edges) <- c("from", "to", "weight")

edges <- edges %>%
  mutate(
    from = as.character(from),
    to = as.character(to)
  ) %>%
  filter(from != to, weight > 5)

# 无向边
edges <- edges %>%
  mutate(
    pair1 = pmin(from, to),
    pair2 = pmax(from, to)
  ) %>%
  group_by(pair1, pair2) %>%
  summarise(weight = sum(weight), .groups = "drop") %>%
  rename(from = pair1, to = pair2)

# =========================
# 4. 节点
# =========================
nodes <- data.frame(
  country = pub_df$Country,
  publications = as.numeric(pub_df$Articles)
)

# =========================
# 5. 世界地图
# =========================
world <- ne_countries(scale = "medium", returnclass = "sf")

# =========================
# 6. ISO3统一
# =========================
world$iso3 <- countrycode(world$name_long, "country.name", "iso3c")
nodes$iso3 <- countrycode(nodes$country, "country.name", "iso3c")

edges$from_iso <- countrycode(edges$from, "country.name", "iso3c")
edges$to_iso <- countrycode(edges$to, "country.name", "iso3c")

# =========================
# 7. 合并发文量
# =========================
world <- left_join(world, nodes, by = "iso3")
world$publications[is.na(world$publications)] <- 0

# =========================
# 8. 部分连续 cartogram
# =========================
world_proj <- st_transform(world, 8857)

# 原始面积比例
original_area <- as.numeric(st_area(world_proj))
area_share <- original_area / sum(original_area)

# 发文量比例；+1 保证所有国家的权重严格大于 0
publication_share <- (world_proj$publications + 1) /
  sum(world_proj$publications + 1)

# 变形强度：0 = 不变形，1 = 完全按发文量分配面积
# 0.10 对当前数据产生轻度且可见的面积变化。
lambda <- 0.10

# 在对数尺度上由原始面积向发文量目标面积移动。
target_share <- area_share^(1 - lambda) * publication_share^lambda
target_share <- target_share / sum(target_share)

world_proj$cart_weight <- target_share * sum(original_area)

world_cart <- cartogram_cont(
  world_proj,
  "cart_weight",
  itermax = 10
)

# 输出面积变化诊断，确认 cartogram 确实发生变形。
cart_area_ratio <- as.numeric(st_area(world_cart)) / original_area
print(
  quantile(
    cart_area_ratio,
    probs = c(0, 0.05, 0.25, 0.5, 0.75, 0.95, 1),
    na.rm = TRUE
  )
)

# =========================
# 9. centroid
# =========================
centroids <- st_point_on_surface(world_cart)

centroid_df <- data.frame(
  iso3 = centroids$iso3,
  x = st_coordinates(centroids)[, 1],
  y = st_coordinates(centroids)[, 2]
)

centroid_df <- centroid_df[!duplicated(centroid_df$iso3), ]

# =========================
# 10. 构建边
# =========================
edge_lines <- edges %>%
  left_join(centroid_df, by = c("from_iso" = "iso3")) %>%
  rename(x_from = x, y_from = y)

edge_lines <- edge_lines %>%
  left_join(centroid_df, by = c("to_iso" = "iso3")) %>%
  rename(x_to = x, y_to = y)

edge_lines <- edge_lines %>%
  filter(
    !is.na(x_from), !is.na(y_from),
    !is.na(x_to), !is.na(y_to)
  ) %>%
  filter(!(x_from == x_to & y_from == y_to)) %>%
  filter(weight > 20)

# =========================
# 11. 线条分级
# =========================
edge_lines$weight_class <- cut(
  edge_lines$weight,
  breaks = c(20, 40, 80, 100, 150, Inf),
  labels = c("20-40", "40-80", "80-100", "100-150", "150+"),
  include.lowest = FALSE
)

# =========================
# 12. 绘图
# =========================
p <- ggplot() +
  geom_sf(
    data = world_cart,
    aes(fill = publications),
    color = "grey40",
    linewidth = 0.2
  ) +
  geom_curve(
    data = edge_lines,
    aes(
      x = x_from,
      y = y_from,
      xend = x_to,
      yend = y_to,
      linewidth = weight_class
    ),
    color = "#D73027",
    alpha = 0.5,
    curvature = 0.2
  ) +
  scale_fill_gradientn(
    colors = viridis::viridis(256, option = "D"),
    name = "Publications",
    trans = "sqrt"
  ) +
  scale_linewidth_manual(
    values = c(
      "20-40" = 0.2,
      "40-80" = 0.5,
      "80-100" = 1.0,
      "100-150" = 2.0,
      "150+" = 3.0
    ),
    name = "International Collaboration Strength"
  ) +
  guides(
    fill = guide_colorbar(
      title.position = "top",
      title.hjust = 0.5,
      direction = "horizontal",
      barwidth = unit(42, "mm"),
      barheight = unit(3, "mm"),
      order = 1
    ),
    linewidth = guide_legend(
      title.position = "top",
      title.hjust = 0.5,
      direction = "horizontal",
      nrow = 1,
      byrow = TRUE,
      order = 2
    )
  ) +
  coord_sf(expand = FALSE) +
  journal_theme(
    theme_minimal(
      base_size = journal_base_size,
      base_family = journal_font_family
    )
  ) +
  theme(
    panel.grid.major = element_line(color = "grey85", linetype = "dashed"),
    panel.grid.minor = element_line(color = "grey92", linetype = "dotted"),
    axis.text = element_blank(),
    axis.title = element_blank(),
    legend.position = "bottom",
    legend.direction = "horizontal",
    legend.box = "horizontal",
    legend.box.just = "center",
    legend.box.spacing = unit(2, "mm"),
    legend.spacing.x = unit(2, "mm"),
    legend.key.width = unit(9, "mm"),
    legend.key.height = unit(3, "mm"),
    plot.title.position = "plot",
    plot.title = element_text(
      size = 11,
      face = "bold",
      hjust = 0.5
    ),
    legend.title = element_text(
      size = 9,
      face = "plain",
      colour = "black"
    ),
    legend.text = element_text(
      family = journal_font_family,
      size = 8,
      colour = "black"
    )
  )

# =========================
# 13. 导出
# =========================
save_journal_figure(
  plot = p,
  filename_stem = "world_coauthorship_partial_cartogram"
)
