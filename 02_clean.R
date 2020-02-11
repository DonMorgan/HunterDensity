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

#Combine Resident and non-Resident hunters and calculate average number/year
Hunt$nHunters<-Hunt$RESIDENT.HUNTERS+Hunt$NON.RESIDENT.HUNTERS
Hunt$nDays<-Hunt$RESIDENT.DAYS+Hunt$NON.RESIDENT.DAYS
Hunt$nkills<-Hunt$RESIDENT.KILLS+Hunt$NON.RESIDENT.KILLS

#sum for each WMU and calculate hunter density - all species - per year
NumYears<-length(unique(Hunt$HUNT.YEAR))

#Hunter Data not assigned to a MU but only to a region is a '00' record
#Regional totals are assigned '99' records
#Hunter Data not assgined to a MU or to a Region are 999
#7A and 7B appear to be sub-region totals
#all of these cases are dropped
excludes<-c("100", "199", "200", "299", "300", "399", "400", "499", "500", "599",
           "600", "699", "700", "799", "7A",  "7B",  "800", "899", "999")

#Divide by number of years to get per year
HuntStat<-Hunt %>%
  group_by(WMU) %>%
  dplyr::filter(!(WMU %in% excludes | is.na(WMU))) %>%
  dplyr::summarise(count=n(), TotnHunters=sum(nHunters)/NumYears,
                   TotnDays=sum(nDays)/NumYears, TotnKills=sum(nkills)/NumYears)

#aggregate GBPop since WMUs split between GBPUs, etc resulting in multiple instances of WMU
GBPop1<-GBPop %>%
  group_by(WMU) %>%
  dplyr::summarise(count=n(),AREA_KM2=sum(AREA_KM2),AREA_KM2_BTMwaterIce=sum(AREA_KM2_BTMwaterIce),
                   AREA_KM2_noWaterIce=sum(AREA_KM2_noWaterIce),EST_POP_2018=sum(EST_POP_2018))

#Join Hunt data to GBPop1 data set
HuntWMU<-GBPop1 %>%
  left_join(HuntStat, by='WMU')

#3 units 201 345 701 - have no hunters and thus are set as NA - change to 0
HuntWMU[is.na(HuntWMU)] <- 0

#####################
#data check
#setdiff(GBPop1$WMU, HuntStat$WMU)
#library(mapview)
#mapview(HuntWMU)
#HuntWMU[order(HuntWMU$WMU),]$WMU
#HuntStat[order(HuntStat$WMU),]$WMU
#test<-setdiff(HuntStat$WMU,WMU$WMU) #19records missing from WMU
#test2<-setdiff(WMU$WMU,HuntStat$WMU) #3 records missing from HuntStat


