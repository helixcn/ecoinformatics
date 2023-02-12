library(here)
library(plantlist)
library(openxlsx)
library(exifr)
library(dplyr)

rm(list = ls())
photos <- Sys.glob(paths = paste0(getwd(), '/*'), dirmark = TRUE)
photos <- photos[grepl("jpg", photos)]
photos <- photos[grepl("[\U4E00-\U9FFF\U3000-\U303F]", photos)]

spcn <- unique(gsub("[0-9a-zA-Z/ ,._:]", "", photos))
spcn <- spcn[spcn != ""]

cres <- CTPL(spcn)
write.xlsx(cres, "checklist_species.xlsx")

# Extracting GPS coordinates
old_name0 <- photos[1]
new_name0 <- paste0(gsub("[\U4E00-\U9FFF\U3000-\U303F]", 
                         "", old_name0), "_temp")
file.rename(from = old_name0, to = new_name0)
dat <- read_exif(new_name0)
dat$SourceFile   <-
  ifelse(is.na(dat$SourceFile),   NA, dat$SourceFile)
dat$GPSLongitude <-
  ifelse(is.na(dat$GPSLongitude), NA, dat$GPSLongitude)
dat$GPSLatitude  <-
  ifelse(is.na(dat$GPSLatitude),  NA, dat$GPSLatitude)
dat$GPSAltitude  <-
  ifelse(is.na(dat$GPSAltitude),  NA, dat$GPSAltitude)
dat <-
  subset(dat,
         select = c("SourceFile", "GPSLongitude", 
                    "GPSLatitude", "GPSAltitude"))

file.rename(from = new_name0, to = old_name0)

for (i in 2:length(photos)) {
  old_name <- photos[i]
  new_name <- paste0(gsub("[\U4E00-\U9FFF\U3000-\U303F]", 
                          "", old_name), "_temp")
  
  file.rename(from = old_name, to = new_name)
  dat_temp <- read_exif(new_name)
  
  dat_temp$SourceFile   <-
    ifelse(!is.null(dat_temp$SourceFile),  
           dat_temp$SourceFile,   NA)
  dat_temp$GPSLongitude <-
    ifelse(!is.null(dat_temp$GPSLongitude),  
           dat_temp$GPSLongitude, NA)
  dat_temp$GPSLatitude  <-
    ifelse(!is.null(dat_temp$GPSLatitude),  
           dat_temp$GPSLatitude , NA)
  dat_temp$GPSAltitude  <-
    ifelse(!is.null(dat_temp$GPSAltitude),  
           dat_temp$GPSAltitude , NA)
  sub_dat_temp <-
    subset(dat_temp,
           select = c("SourceFile", "GPSLongitude", 
                      "GPSLatitude", "GPSAltitude"))
  
  dat <- rbind(dat, sub_dat_temp)
  file.rename(from = new_name, to = old_name)
  print(i)
  rm(old_name)
  rm(new_name)
  rm(dat_temp)
}


res_read_exif <- cbind(photos, dat)

write.xlsx(res_read_exif, "photo_coordinates.xlsx", 
           overwrite = TRUE)
