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

source("header.R")

#calculate hunter days density by GBPU days/km2
#Calculate area of each WMU and join to Hunt data set
WMUarea<-data.frame(freq(WMUr, parellel=FALSE))
colnames(WMUarea)<-c('WMU','AreaHa')
#not all WMUs have kills, all WMUs are preserved in merge
WMUdat1<-merge(HuntStat, WMUarea, by='WMU', all.y=TRUE)
#set all NA to 0
WMUdat1[is.na(WMUdat1)] <- 0
#multiply to go from square hectares to square kilometers
WMUdat1$HunterDayDensity<-WMUdat1$TotnDays/WMUdat1$AreaHa*100
#Takes a long time to run subs - perhaps do prior to rasterize? ie do to WMU then fasterize on new column?

# Attache data to shape file
WMUh<-merge(WMU,WMUdat1, by='WMU') #not tested

#data for area with non habitat removed - rock, ice, water
WMUnonHabarea<-data.frame(freq(WMUr_NonHab, parellel=FALSE))
colnames(WMUnonHabarea)<-c('WMU','nHabAreaHa')
WMUdat<-merge(HuntStat, WMUnonHabarea, by='WMU', all.y=TRUE)
WMUdat[is.na(WMUdat)] <- 0
WMUdat$nHabHunterDayDensity<-WMUdat$TotnDays/WMUdat$nHabAreaHa*100

#Join WMUdat and WMUdat1
WMUdata<-WMUdat %>%
  dplyr::select(WMU,nHabAreaHa,nHabHunterDayDensity) %>%
  left_join(WMUdat1, by = 'WMU')

WMUdata<-merge(WMUdat,WMUdat1,by='WMU')

