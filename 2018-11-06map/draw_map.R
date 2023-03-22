#### 导入所需要的程序包
library(here)
library(rgdal)
library(tmap)
library(tmaptools)
library(sp)
library(sf)
rm(list = ls())

## 读取地图

# 世界政区图shape文件
# 来源: https://www.naturalearthdata.com/downloads/50m-cultural-vectors/
world <- st_read("ne_50m_admin_0_countries.shp")

# 国界shape文件
country <- st_read("bou1_4l.shp")

# 省界shape文件
province <- st_read("province_polygon.shp")


# 设定投影为WGS84的经纬度投影
st_crs(world) <- "EPSG:4326"
st_crs(country) <- "EPSG:4326"
st_crs(province) <- "EPSG:4326"

# 城市数据
# 读取世界城市人口数据 （假设为采样点），城市人口多少，用点的大小表示
city <- read.csv("simplemaps-worldcities-basic.csv", header = TRUE)
city <- city[sample(1:nrow(city), 300), ] # 随机筛选100个城市

coordinates(city) <- ~ lng + lat
# 转换为spatial dataframe，以便作为tmap的图层使用

# 绘图
# 只显示一部分，所以这里设定了xlim,ylim
tm_shape(world,
         xlim = c(60, 140),
         ylim = c(0, 60)) +
    tm_borders("grey40", lwd = 1.5) +
    # 先加载中国省级行政区（多边形 Polygon）
    tm_shape(province) +
    tm_fill(col = "white") +
    tm_borders("grey60",
               lwd = 0.8) +
    # 再加载国界线 （Polyline）
    tm_shape(country) +
    tm_lines(col = "grey40",
             lwd = 1.5) +
    tm_scale_bar(position = c(0.05, 0.0)) +
    tm_compass(type = "4star",
               position = c("left", "top")) +
    tm_layout(inner.margins = c(0.12, 0.03, 0.08, 0.03)) +
    tm_shape(city) +
    tm_bubbles("pop",
               col = "red",
               scale = .8,
               border.col = "red") +
    tm_legend(legend.position = c(0.05, 0.08),
              legend.stack = "vertical")

sessionInfo()

