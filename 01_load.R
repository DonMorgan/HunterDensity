# Copyright 2018 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

#From Tony - YES – it doesn’t matter whether 1 hunter hunted for 20 days or 20 hunters for 1 day, this is the perhaps the best link to Grizzly bear mortality risk, with one possible enhancement: the number of animals they drop also influences that risk, strongly it seems. Meat on the landscape, attracting bears, to places and circumstances near people with guns. It’s too late in the day to bring it to mind, but I’m pretty sure there is research support.

#A mixed index of risk of DAYS and KILLS, combined somehow? Two indices of risk, one that compounds and worsens the other?

source("header.R")

#Rasterize the Province for subsequent masking
ProvRast<-raster(nrows=15744, ncols=17216, xmn=159587.5, xmx=1881187.5,
                 ymn=173787.5, ymx=1748187.5,
                 crs="+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0",
                 res = c(100,100), vals = 0)

BCr_file <- file.path(dataOutDir,"BCr.tif")
if (!file.exists(BCr_file)) {
  BCr <- fasterize(bcmaps::bc_bound_hres(class='sf'),ProvRast)
  writeRaster(BCr, filename=BCr_file, format="GTiff", overwrite=TRUE)
} else {
  BCr <- raster(BCr_file)
}

BTM_file <- file.path("tmp/BTM_Brick")
if (!file.exists(BTM_file)) {
  # Link to BTM file download from BCDC:
  # https://catalogue.data.gov.bc.ca/dataset/baseline-thematic-mapping-present-land-use-version-1-spatial-layer
  #Dowload file manually and put *.zip in this script and place file in the data directory
  BTMZip <- 'BCGW_78757263_1520272242999_7572.zip'
  unzip(file.path(DataDir, BTMZip), exdir = file.path(DataDir, "BTM"))

  # List feature classes in the geodatabase
  BTM_gdb <- list.files(file.path(DataDir, "BTM"), pattern = ".gdb", full.names = TRUE)[1]
  fc_list <- st_layers(BTM_gdb)
  BTM <- read_sf(BTM_gdb, layer = "WHSE_BASEMAPPING_BTM_PRESENT_LAND_USE_V1_SVW")

  # Pull out the BTM layers and rasterize
  #BTM[1,] #look at file header
  NonHab <- BTM[BTM$PRESENT_LAND_USE_LABEL %in% c('Fresh Water','Outside B.C.','Salt Water', 'Glaciers and Snow') ,] %>%
    fasterize(ProvRast, background=NA)

  writeRaster(NonHab, filename=file.path(StrataOutDir,"NonHab.tif"), format="GTiff", overwrite=TRUE)

} else {
  NonHab<-raster(file.path(StrataOutDir,"NonHab.tif"))
}


GB_file <- file.path("tmp/GB_Brick")
if (!file.exists(GB_file)) {
  #Read layers from threats directory #maybe change to generic diretory?
  GB_gdb <- list.files(file.path(BearRDataDir, "Bears"), pattern = ".gdb", full.names = TRUE)[1]
  fc_list <- st_layers(GB_gdb)

#Organize strata layers
  #BEI
  BEI <- read_sf(GB_gdb, layer = "Final_Grizzly_BEI")
  # Make a BEI raster
  BEI_1_2_r <- BEI[BEI$HIGHCAP %in% c(1,2) ,] %>%
    fasterize(ProvRast, background=NA)
  BEI_1_5_r <- BEI[BEI$HIGHCAP %in% c(1,2,3,4,5) ,] %>%
    fasterize(ProvRast, background=NA)
  BEIr <- fasterize(BEI, ProvRast, background=0, field='HIGHCAP')
  #GBPU
  GBPU <- read_sf(GB_gdb, layer = "GBPU_BC_edits_v2_20150601")
  GBPU_lut <- tidyr::replace_na(data.frame(GRIZZLY_BEAR_POP_UNIT_ID=GBPU$GRIZZLY_BEAR_POP_UNIT_ID, POPULATION_NAME=GBPU$POPULATION_NAME, stringsAsFactors = FALSE), list(POPULATION_NAME = 'extirpated'))
  saveRDS(GBPU, file = 'tmp/GBPU')
  saveRDS(GBPU_lut, file = file.path(DataDir,'GBPU_lut'))

  # Make a GBPU raster
  GBPUr <- fasterize(GBPU, ProvRast, field = 'GRIZZLY_BEAR_POP_UNIT_ID', background=NA)
  #saveRDS(GBPUr, file = 'tmp/GBPUr')
  writeRaster(GBPUr, filename=file.path(StrataOutDir,"GBPUr.tif"), format="GTiff", overwrite=TRUE)

  #WMU
  WMU <- read_sf(GB_gdb, layer = "WMU_grizz_Link")

  #Remove hyphen from WILDLIFE_MGMT_UNIT_ID and add 0 for single digit WMUs
  #First peel off the Region number
  #Second place a 0 if the 'character' is blank (ie single digit)
  #Third concatenate
  WMU$WMU<-as.numeric(paste0(substr(WMU$WILDLIFE_MGMT_UNIT_ID, 0, 1), gsub(" ", "0", sprintf("% 2s", substr(WMU$WILDLIFE_MGMT_UNIT_ID, 3, 4)))))

  # Make a WMU raster
  WMUr <- fasterize(WMU, ProvRast, field = 'WMU', background=NA)
  writeRaster(WMUr, filename=file.path(StrataOutDir,"WMUr.tif"), format="GTiff", overwrite=TRUE)

  # Make a WMU raster and remove non habitat - rock, ice, water, ocean
  WMUr_NonHab <- overlay(WMUr, NonHab, fun = function(x, y) {
    x[!is.na(y[])] <- NA
    return(x)
  })
  writeRaster(WMUr_NonHab, filename=file.path(StrataOutDir,"WMUr_NonHab.tif"), format="GTiff", overwrite=TRUE)

  #set GBPUr to NA where BEI is NonHab
  GBPUr_NonHab <- overlay(GBPUr, NonHab, fun = function(x, y) {
    x[!is.na(y[])] <- NA
    return(x)
  })
  writeRaster(GBPUr_NonHab, filename=file.path(StrataOutDir,"GBPUr_NonHab.tif"), format="GTiff", overwrite=TRUE)

  GBPUr_BEI_1_2 <- overlay(GBPUr_NonHab, BEI_1_2_r, fun = function(x, y) {
    x[is.na(y[])] <- NA
    return(x)
  })
  writeRaster(GBPUr_BEI_1_2, filename=file.path(StrataOutDir,"GBPUr_BEI_1_2.tif"), format="GTiff", overwrite=TRUE)

  GBPUr_BEI_1_5 <- overlay(GBPUr_NonHab, BEI_1_5_r, fun = function(x, y) {
    x[is.na(y[])] <- NA
    return(x)
  })
  writeRaster(GBPUr_BEI_1_5, filename=file.path(StrataOutDir,"GBPUr_BEI_1_5.tif"), format="GTiff", overwrite=TRUE)

  #Read in landcover
  LandCover<-raster(file.path(BearRDataDir,"LandCover/land_cover_n_age_2017.tif"))
  LC_lut<-read_csv(file.path(BearRDataDir,'LandCover/LandCover_lut.csv'), col_names=TRUE)
  Forest<-LandCover
  Forest[!(Forest[] > 0)]<-NA
  GBPUr_Forest <- overlay(GBPUr_NonHab, Forest, fun = function(x, y) {
    x[is.na(y[])] <- NA
    return(x)
  })
  writeRaster(GBPUr_Forest, filename=file.path(StrataOutDir,"GBPUr_Forest.tif"), format="GTiff", overwrite=TRUE)

} else {
  NonHab<-raster(file.path(StrataOutDir,"NonHab.tif"))
  GBPUr<-raster(file.path(StrataOutDir,"Strata/GBPUr.tif"))
  WMUr<-raster(file.path(StrataOutDir,"Strata/WMUr.tif"))
  GBPUr_NonHab<-raster(file.path(StrataOutDir,"Strata/GBPUr_NonHab.tif"))
  GBPUr_BEI_1_2<-raster(file.path(StrataOutDir,"Strata/GBPUr_BEI_1_2.tif"))
  GBPUr_BEI_1_5<-raster(file.path(StrataOutDir,"Strata/GBPUr_BEI_1_5.tif"))
  GBPUr_Forest<-raster(file.path(StrataOutDir,"Strata/GBPUr_Forest.tif"))
  GB_Brick <- readRDS(file = GB_file)
}

#Read in hunter data
Hunt <- data.frame(read.xlsx(file.path(DataDir, "BIG GAME HARVEST STATISTICS 1976 - 2017 v1.xlsx"), sheet='BGHS'))
#set NA to 0
Hunt[is.na(Hunt)] <- 0
