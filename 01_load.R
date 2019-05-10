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

#Read WMU raster from the GB_Data directory - WMUs are from DataBC
WMUr<-raster(file.path(StrataDir,"WMUr.tif"))
WMUr_NonHab<-raster(file.path(StrataDir,"WMUr_NonHab.tif"))
WMU<-st_read(file.path(GBspatialDir,'WMU.shp'))

#Read in hunter data from the repo's data directory - data only available by request
#select the last 5 years of data
Hunt <-
  data.frame(read.xlsx(file.path(DataDir, "BIG GAME HARVEST STATISTICS 1976 - 2017 v1.xlsx"), sheet='BGHS')) %>%
  dplyr::filter(HUNT.YEAR > 2012)

#set NA to 0
Hunt[is.na(Hunt)] <- 0
