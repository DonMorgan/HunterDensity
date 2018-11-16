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


#sum number of kills by WMU
#paste(killData$Region_code,killData$MU,sep='-')
killData$noKills<-1
agg.mean <- aggregate(noKills ~ MU, killData, FUN="mean")
agg.count <- aggregate(noKills ~ MU, killData, FUN="length")
aggcount <- agg.count$noKills
agg <- cbind(aggcount, agg.mean)

#unique(data.frame(ndays$WMU))
#unique(data.frame(agg.count$MU))

#data exploration.................
#plot distribution of the nkills and ndays, log transform to normalize since skewed

pdf(file=paste(filedir,"NormTest_ndays.pdf",sep=""))
qqnorm(hunt_tot$ndays)
qqline(hunt_tot$ndays, col=2)
title(main = "Normal Test ndays", line=-2)
dev.off()

pdf(file=paste(filedir,"Hist_ndays.pdf",sep=""))
histogram(hunt_tot$ndays, col='grey',main = 'ndays')
dev.off()

x<-log(hunt_tot$ndays)
y<-log(hunt_tot$nkills)
z<-log(hunt_tot$nhunters)
xtext<-'log(ndays)'
ytext<-'log(nkills)'
ztext<-'log(nhunters)'

pdf(file=paste(filedir,"Hist",xtext,".pdf",sep=""))
histogram(x, col='grey',main = xtext)
dev.off()

boxplot(x, col = "grey", main = xtext)

pdf(file=paste(filedir,"Hist",ytext,".pdf",sep=""))
histogram(y, col='grey',main = ytext)
dev.off()

boxplot(y, col = "grey", main = ytext)

pdf(file=paste(filedir,"Hist",ztext,".pdf",sep=""))
histogram(z, col='grey',main = ztext)
dev.off()

boxplot(z, col = "grey", main = ztext)

pdf(file=paste(filedir,"NormTestLog(ndays).pdf",sep=""))
qqnorm(x)
qqline(x, col=2)
title(main = "Normal Test log(ndays)", line=-2)
dev.off()


pdf(file=paste(filedir,"plot",xtext,"&",ytext,".pdf",sep=""))
plot(x ~y,xlab=xtext,ylab=ytext)
dev.off()

pdf(file=paste(filedir,"plot",ytext,"&",ztext,".pdf",sep=""))
plot(y ~z,xlab=ytext,ylab=ztext)
dev.off()

#correlation test between ndays and nkills
sink(paste(filedir,"RegNdaysNkills",".txt",sep=""), append=TRUE, split=TRUE)
x<-log(hunt_tot$ndays)
y<-log(hunt_tot$nkills)
xtext<-'log(ndays)'
ytext<-'log(nkills)'
print
print(paste("Spearman Rank Correlation ",xtext," & ",ytext,sep=''))
cor.test(x, y, method = "spearman")
xlb <- paste("Ranks of (", xtext, ")")
ylb <- paste("Ranks of (", ytext, ")")
pdf(file=paste(filedir,"SpearNdaysNkills",".pdf",sep=""))
plot(rank(y) ~ rank(x), pch = 21, bg = 2, xlab = xlb, ylab = ylb)
title(main = "Input to Spearman's test")
dev.off()

#regression of nhunters and nkills
pdf(file=paste(filedir,"RegNdaysNkills",".pdf",sep=""))

plot(y ~ x, pch = 21, bg = 2, xlab = xtext, ylab = ytext)
mod <- lm(y ~ x)
abline(mod, lwd = 2)
#simple 95% confidence intervals for the plot
ci<-predict(mod, interval="confidence", level=0.95)
lines(x, ci[,2], col='red', lty=2)
lines(x, ci[,3], col='green', lty=2)
title(main = "Regression with 95% CI")
dev.off()
print
print(paste("Regression Analysis of ",xtext," & ",ytext,sep=''))
summary(mod)
sink()

qqnorm(hunt_tot$ndays)
qqline(hunt_tot$ndays, col=2)


rcorr(as.matrix(hunt_tot))

summary(hunt_tot)
sapply(hunt_tot, sd)
xtabs()



