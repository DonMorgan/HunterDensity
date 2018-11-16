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

Hunt$nHunters<-Hunt$RESIDENT.HUNTERS+Hunt$NON.RESIDENT.HUNTERS
Hunt$nDays<-Hunt$RESIDENT.DAYS+Hunt$NON.RESIDENT.DAYS


#Data Prep, subset and sum across all species
nhunters<-subset(Hunt, Hunt$Statistic=="nhunters")
ndays<-subset(Hunt, Hunt$Statistic=="ndays")
nkills<-subset(Hunt, Hunt$Statistic=="nkills")
avhunters<-subset(Hunt, Hunt$Statistic=="avhunters")
avdays<-subset(Hunt, Hunt$Statistic=="avdays")
avkills<-subset(Hunt, Hunt$Statistic=="avkills")

nhunters$tot_nhunters <- (nhunters$Black.Bear+nhunters$Cougar+nhunters$Mule_or_Black.Tailed_Deer+nhunters$Wolf+nhunters$White.Tailed_Deer+nhunters$Elk+nhunters$Grizzly_Bear+nhunters$Mountain_Goat+nhunters$Moose+nhunters$Mountain_Sheep+nhunters$Caribou)

ndays$tot_ndays <- (ndays$Black.Bear+ndays$Cougar+ndays$Mule_or_Black.Tailed_Deer+ndays$Wolf+ndays$White.Tailed_Deer+ndays$Elk+ndays$Grizzly_Bear+ndays$Mountain_Goat+ndays$Moose+ndays$Mountain_Sheep+ndays$Caribou)

nkills$tot_nkills <- (nkills$Black.Bear+nkills$Cougar+nkills$Mule_or_Black.Tailed_Deer+nkills$Wolf+nkills$White.Tailed_Deer+nkills$Elk+nkills$Grizzly_Bear+nkills$Mountain_Goat+nkills$Moose+nkills$Mountain_Sheep+nkills$Caribou)
avhunters$tot_avhunters <- (avhunters$Black.Bear+avhunters$Cougar+avhunters$Mule_or_Black.Tailed_Deer+avhunters$Wolf+avhunters$White.Tailed_Deer+avhunters$Elk+avhunters$Grizzly_Bear+avhunters$Mountain_Goat+avhunters$Moose+avhunters$Mountain_Sheep+avhunters$Caribou)
avdays$tot_avdays <- (avdays$Black.Bear+avdays$Cougar+avdays$Mule_or_Black.Tailed_Deer+avdays$Wolf+avdays$White.Tailed_Deer+avdays$Elk+avdays$Grizzly_Bear+avdays$Mountain_Goat+avdays$Moose+avdays$Mountain_Sheep+avdays$Caribou)
avkills$tot_avkills <- (avkills$Black.Bear+avkills$Cougar+avkills$Mule_or_Black.Tailed_Deer+avkills$Wolf+avkills$White.Tailed_Deer+avkills$Elk+avkills$Grizzly_Bear+avkills$Mountain_Goat+avkills$Moose+avkills$Mountain_Sheep+avkills$Caribou)

#Compare the variouse sets on WMU
#hunt_tot<-data.frame(ndays$tot_ndays,nhunters$tot_nhunters,nkills$tot_nkills, avdays$tot_avdays, avhunters$tot_avhunters, avkills$tot_avkills)


hunt_tot<-data.frame(ndays$WMU,ndays$tot_ndays,nhunters$tot_nhunters,nkills$tot_nkills, avdays$tot_avdays, avhunters$tot_avhunters, avkills$tot_avkills)
colnames(hunt_tot)<-c("WMU","ndays","nhunters","nkills","avdays","avhunters","avkills")

hunt_tot$WMU_link<-paste(substr(ndays$WMU,1,1), "-",substr(ndays$WMU,2,3),sep="")

#export data
write.table((hunt_tot), file = paste(filedir,"Hunt_tot.csv",sep=""),append = FALSE, quote = FALSE, row.names = FALSE, col.names = TRUE, sep=",")#sep="\t")

