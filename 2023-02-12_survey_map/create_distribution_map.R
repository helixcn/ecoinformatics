library(here)
library(tmap)
library(tmaptools)
library(sf)
library(readxl)
library(showtext)
library(plantlist)
showtext_auto()

# 查看gpx文件中有哪些图层
st_layers("Track_2023-01-13 091746.gpx") 

# 读取gpx文件的tracks图层
survey_gpx <- st_read("Track_2023-01-13 091746.gpx", layer='tracks')

# 所要获取环境底图的范围
map_boundary <- st_bbox(survey_gpx, crs = st_crs(4326))

# 定义函数，用于在显示航迹四周扩展部分边界
expand_bbox <- function(x, buffer_zone = 0.1){
  x_range <- x$xmax - x$xmin
  y_range <- x$ymax - x$ymin
  xmin <- x$xmin - x_range*buffer_zone
  ymin <- x$ymin - y_range*buffer_zone
  xmax <- x$xmax + x_range*buffer_zone
  ymax <- x$ymax + y_range*buffer_zone
  res <- c(xmin, ymin, xmax, ymax)
  names(res) <- c("xmin","ymin","xmax","ymax")
  return(res)
}

# 在每边上都增加0.1 x,y的范围
map_boundary2 <- expand_bbox(map_boundary)

# 读取从照片exif读取的经纬度等数据
occurrence <- read_excel("photo_coordinates.xlsx")

# 若无longitude，该记录则删除，以方便转换为 simple features
occurrence <- occurrence[!is.na(occurrence[,"GPSLongitude"]), ]

# 只保留中文名，（照片的文件名已改为植物物种名）
spcn <- unique(gsub("[0-9a-zA-Z/ ,._:]", "", occurrence$photos))

# 增加scientific_name一列（学名，无命名人）
occurrence$scientific_name <-  CTPL(spcn)[,'SPECIES']

# 将中文名添加到occurrence数据框中
occurrence$spcn <-  spcn

# 将occurrence转换为occurrence_dat
occurrence_dat <-
    st_as_sf(
        occurrence,
        coords = c("GPSLongitude", "GPSLatitude"),
        crs = st_crs(4326)
    )

type = c(
  "osm",
  # "osm-bw", # NA
  # "maptoolkit-topo",# NA
  # "waze", NA
  "bing",
  # "stamen-toner", NA
  # "stamen-terrain", NA
  "stamen-watercolor",
  # "osm-german", NA
  # "osm-wanderreitkarte", NA
  # "mapbox", NA
  # "esri", NA
  # "esri-topo", NA
  # "nps", Na
  # "apple-iphoto", NA
  # "skobbler", NA
  # "hillshade", NA
  "opencyclemap",
  "osm-transport",
  "osm-public-transport"
  # "osm-bbike", NA
  # "osm-bbike-german" NA
)

for (i in 1:length(type)) {
  print(type[i])
  osm_map <- read_osm(map_boundary2, type = type[i])
  
  map_en <- tm_shape(osm_map) +
    tm_rgb() +
    tm_shape(survey_gpx) +
    tm_lines(col = "blue") +
    tm_shape(occurrence_dat) +
    tm_dots(
      title = "Species",
      col = "scientific_name",
      # species
      border.lwd = 2,
      size = 2,
      shape = 1
    ) +
    tm_compass(position = c("right", "top")) +
    tm_scale_bar(position = c("right", "bottom")) +
    tm_layout(
      legend.position = c("left", "bottom"),
      title = 'Distribution of selected plant species',
      title.position = c('left', 'top'),
      legend.bg.color = "white"
    ) +
    tm_xlab("Longitude") +
    tm_ylab("Latitude")
  
  map_en
  tmap_save(map_en, paste0("survey_map_en_", type[i], ".jpg"))
  
  ####
  map_cn <- tm_shape(osm_map) +
    tm_rgb() +
    tm_shape(survey_gpx) +
    tm_lines(col = "blue") +
    tm_shape(occurrence_dat) +
    tm_dots(
      title = "物种",
      col = "spcn",
      # species in Chinese
      border.lwd = 2,
      size = 2,
      shape = 1
    ) +
    tm_compass(position = c("right", "top")) +
    tm_scale_bar(position = c("right", "bottom")) +
    tm_layout(
      legend.position = c("left", "bottom"),
      title = '目标种的分布',
      title.position = c('left', 'top'),
      legend.bg.color = "white"
    ) +
    tm_xlab("Longitude") +
    tm_ylab("Latitude")
  
  map_cn
  tmap_save(map_cn, paste0("survey_map_cn_", type[i], ".jpg"))
}
