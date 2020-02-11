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
#

source("header.R")

#Write out vector based results
HuntWMU_dat<-HuntWMU
st_geometry(HuntWMU_dat) <- NULL
WriteXLS(HuntWMU_dat, file.path(dataOutDir,paste('HuntWMU_dat.xls',sep='')))#,SheetNames=names(ThreatLevels))
#Write as geopackage to preserve variable names
st_write(HuntWMU, dsn = file.path(spatialOutDir,'HuntWMU.gpkg'), layer = 'HuntWMU', delete_layer = TRUE)

###############################
#Raster methods
#Write out an excel file of WMUs and summarized data
WriteXLS(WMUdata, file.path(dataOutDir,paste('Hunter_WMUdata.xls',sep='')))#,SheetNames=names(ThreatLevels))
# Hunter Day Density raster with full WMU area
HuntDDensR<-subs(WMUr,WMUdat1, by='WMU',which='HunterDayDensity')
writeRaster(HuntDDensR, filename=file.path(spatialOutDir,"HuntDDensR.tif"), format="GTiff", overwrite=TRUE)
# Write out a WMU shapefile with Hunter Density to 'ShapeFile' directory
ShapeDir<-file.path(spatialOutDir,'ShapeFile')
dir.create(ShapeDir, showWarnings = FALSE)

st_write(WMUh, file.path(ShapeDir,'Hunter_WMU.shp'), delete_layer = TRUE)

filesToZip<-dir(ShapeDir)
zip(file.path(ShapeDir,'HunterWMUshape.zip'),file.path(ShapeDir,filesToZip))
zip(file.path(spatialOutDir,'HunterWMUshape.zip'),file.path(ShapeDir,filesToZip))
#
# Hunter Day Density raster with WMU area less rock, ice, water
HuntDDensNonHabR<-subs(WMUr_NonHab,WMUdat, by='WMU',which='nHabHunterDayDensity')
writeRaster(HuntDDensNonHabR, filename=file.path(spatialOutDir,"HuntDDensNonHabR.tif"), format="GTiff", overwrite=TRUE)



