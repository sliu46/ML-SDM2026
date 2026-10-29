# =========================
# 1. 加载包
# =========================
library(sf)
library(rnaturalearth)
library(dplyr)
library(ggplot2)
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
# 读取发文量表
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
    to   = as.character(to)
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
edges$to_iso   <- countrycode(edges$to, "country.name", "iso3c")

# =========================
# 7. 合并发文量
# =========================
world <- left_join(world, nodes, by = "iso3")
world$publications[is.na(world$publications)] <- 0

# =========================
# 8. 标准地图：仅投影，不按发文量改变国家面积或形状
# =========================
world_proj <- st_transform(world, 8857)

# =========================
# 9. centroid
# =========================
centroids <- st_point_on_surface(world_proj)

centroid_df <- data.frame(
  iso3 = centroids$iso3,
  x = st_coordinates(centroids)[,1],
  y = st_coordinates(centroids)[,2]
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

# 
edge_lines <- edge_lines %>%
  filter(
    !is.na(x_from), !is.na(y_from),
    !is.na(x_to), !is.na(y_to)
  ) %>%
  filter(
    !(x_from == x_to & y_from == y_to)   # ⭐防止curve报错
  ) %>%
  filter(
    weight > 20                         # 删除0-20强度的连线
  )

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
  
  # 标准国家边界；发文量仅通过填充颜色表示
  geom_sf(
    data = world_proj,
    aes(fill = publications),
    color = "grey40",
    linewidth = 0.2
  ) +
  
  # 合作关系
  geom_curve(
    data = edge_lines,
    aes(
      x = x_from, y = y_from,
      xend = x_to, yend = y_to,
      linewidth = weight_class
    ),
    #color = "#4292C6",
    color = "#D73027",
    alpha = 0.5,
    curvature = 0.2,

  ) +
  
  scale_fill_gradientn(
    colors = viridis::viridis(256, option = "D"),
    name = "Publications",
    trans = "sqrt"
  )+
  
  # 线宽映射
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
    
    ## 图例位于图下方，并横向排列
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
    
    ## 图例标题
    legend.title = element_text(
      size = 9,
      face = "plain",
      colour = "black"
    ),
    
    ## 图例文字
    legend.text = element_text(
      family = journal_font_family,
      size = 8,
      colour = "black"
    )
  )
    
 

# =========================
# 13. 导出 PNG 到当前代码所在文件夹
# =========================
ggsave(
  filename = "F:/PythonItem/bib/third10.23/code/world_coauthorship_standard_map.png",
  plot = p,
  device = "png",
  width = journal_width_mm,
  height = journal_height_mm,
  units = "mm",
  dpi = journal_dpi,
  bg = "white",
  limitsize = FALSE
)

