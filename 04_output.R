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

# Hunter Day Density raster with full WMU area
HuntDDensR<-subs(WMUr,WMUdat, by='WMU',which='HunterDayDensity')
writeRaster(HuntDDensR, filename=file.path(BearRDataDirOut,"HuntDDensR.tif"), format="GTiff", overwrite=TRUE)
#
# Hunter Day Density raster with WMU area less rock, ice, water
HuntDDensNonHabR<-subs(WMUr,WMUdat, by='WMU',which='nHabHunterDayDensity')
writeRaster(HuntDDensNonHabR, filename=file.path(BearRDataDirOut,"HuntDDensNonHabR.tif"), format="GTiff", overwrite=TRUE)
