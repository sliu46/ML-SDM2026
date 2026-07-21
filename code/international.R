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
# 8. cartogram
# =========================
world_proj <- st_transform(world, 8857)
world_cart <- cartogram_cont(world_proj, "publications", itermax = 5)

# =========================
# 9. centroid
# =========================
centroids <- st_centroid(world_proj)

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
  )

# =========================
# 11. 线条分级
# =========================
edge_lines$weight_class <- cut(
  edge_lines$weight,
  breaks = c(0, 20, 40, 80, 100, 150, Inf),
  labels = c("0-20", "20", "40", "80", "100", "150+"),
  include.lowest = TRUE
)

edge_lines$weight_class[is.na(edge_lines$weight_class)] <- "0-20"

# =========================
# 12. 绘图
# =========================
p <- ggplot() +
  
  # 国家（cartogram）
  geom_sf(
    data = world_cart,
    aes(fill = publications),
    color = "grey40",
    size = 0.2
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
      "20" = 0.2,
      "40" = 0.5,
      "80" = 1.0,
      "100" = 2.0,
      "150+" = 3.0
    ),
    name = "International Collaboration Strength"
  ) +
  
  coord_sf(expand = FALSE) +
  
  labs(
    title = "Global distribution of publications and international collaboration networks in ML-SDM research"
  ) +
  
  theme_minimal() +
  theme(
    panel.grid.major = element_line(color = "grey85", linetype = "dashed"),
    panel.grid.minor = element_line(color = "grey92", linetype = "dotted"),
    axis.text = element_blank(),
    axis.title = element_blank(),
    
    ## 图例位置
    legend.position = "right",
    
    plot.title.position = "plot",

    plot.title = element_text(
        size = 20,
        face = "bold",
        hjust = 0.5
    ),
    
    ## 图例标题
    legend.title = element_text(
      size = 14,
      face = "bold",
      colour = "black"
    ),
    
    ## 图例文字
    legend.text = element_text(
      family = "Times New Roman",
      size = 12,
      colour = "black"
    )
  )
    
 

# =========================
# 13. 导出
# =========================
ggsave(
  filename = "world_coauthorship_final.png",
  plot = p,
  width = 16,
  height = 8,
  dpi = 600
)

