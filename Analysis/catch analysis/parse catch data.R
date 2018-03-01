### This is an exploratory analysis for the catch data from beach seines and fyke traps sampled in the Skagit river in 2017
### Data is from the Skagit River Coop surveys.

library(dplyr)
library(reshape2)
library(ggplot2)
library(viridis)

base.dir <- "/Users/ole.shelton/Github/Skagit_Salmon_eDNA"
data.dir <- "/Users/ole.shelton/Github/Skagit_Salmon_eDNA/Data/catch_data/raw 2017 data from SRSC"
plot.dir <- "/Users/ole.shelton/Github/Skagit_Salmon_eDNA/Plots"

setwd(data.dir)

catch.dat  <- read.csv(file="Skagit eDNA catch data 2017.csv")
length.dat <- read.csv(file="Skagit eDNA length data 2017.csv")

# parse dates 
catch.dat$time <- strptime(catch.dat$Date,"%m/%d/%y")
catch.dat$julian <- round(as.numeric(difftime(catch.dat$time,strptime("1/1/17","%m/%d/%y"),units="days")),0)

### ANALYZE THE CATCH DATA FIRST
# Pull out abiotic variables.
NOM <- colnames(catch.dat)
THESE <-  c(  grep("Avg.",NOM),
                grep("Max.Water",NOM),
                grep("SetArea",NOM))

abiotic.seine.dat <- catch.dat %>% select("Site","Site.Type.1","Site.Type.2","year","month","time","julian",THESE)

# Identify a set of species to work with
catch.dat <- catch.dat %>% select(-THESE,-grep("density",colnames(catch.dat)),-grep("catch",colnames(catch.dat)))
these  <- c(grep("STURGEON",colnames(catch.dat)),grep("time",colnames(catch.dat)))
M.vars <- colnames(catch.dat)[these[1]:(these[2]-1)]

dat.long <- melt(catch.dat,measure.vars = M.vars,variable.name="species")
dat.long <- dat.long %>% select(-time)
dat.long.sum <- dat.long %>% group_by(species) %>% summarise(SUM = sum(value)) %>% as.data.frame()

# filter out species that were never observed
dat.long.sum <- dat.long.sum %>% filter(SUM >0) %>% arrange(SUM)
SP <- dat.long.sum$species ## list of species that have at least one observation

# 
dat.long.trim <- dat.long %>% filter(species %in% SP) %>% mutate(species.comb = species)
dat.long.trim$species.comb <- as.character(dat.long.trim$species.comb)

### Combine multiple types of salmonids of the same age.
dat.long.trim <- dat.long.trim %>% #mutate(species.comb = if_else(grepl("LANCE",dat.long.trim$species.comb),"LANCE",species.comb)) %>%
                    mutate(species.comb = if_else(grepl("^CK.0",dat.long.trim$species.comb),"CK",species.comb)) %>%
                    mutate(species.comb = if_else(grepl("^CK.1",dat.long.trim$species.comb),"CK",species.comb)) %>%
                    mutate(species.comb = if_else(grepl("^CO.0",dat.long.trim$species.comb),"CO",species.comb)) %>%
                    mutate(species.comb = if_else(grepl("^CO.1",dat.long.trim$species.comb),"CO",species.comb)) %>%
                    mutate(species.comb = if_else(grepl("^CH.",dat.long.trim$species.comb),"CH",species.comb)) %>%
                    mutate(species.comb = if_else(grepl("^CT.",dat.long.trim$species.comb),"CT",species.comb)) #%>%
                    #mutate(species.comb = if_else(grepl("SMELT",dat.long.trim$species.comb),"SMELT",species.comb)) %>%
                    #mutate(species.comb = if_else(grepl("HERR",dat.long.trim$species.comb),"HERR",species.comb)) %>%
  
dat.long.trim <- dat.long.trim %>% filter(!grepl("Random",Site))
dat.long.trim$Site <- factor(dat.long.trim$Site,
                             c("Turners Spit N",
                               "Hoypus Pt E",
                               "Lone Tree Pt",
                               "Dugualla Bluff",
                               "Goat Is",
                               "Strawberry Pt N",
                               "Mariners Bluff", 
                               "Brown Point (X)")) 

dat.set <- dat.long.trim %>% group_by(Site,year,month,julian,Set.Number,species.comb) %>% summarise(total = sum(value)) %>% as.data.frame()
dat.site.avg <- dat.set %>% group_by(Site,year,month,julian,species.comb) %>% summarise(avg = mean(total)) %>% as.data.frame()
dat.skagit.avg <- dat.site.avg %>% group_by(year,month,species.comb) %>% summarise(AVG = mean(avg),SD =sd(avg),CV=SD/AVG) %>% as.data.frame()


## Exploratory Plots
sp.list <- c("CK","CH","CO","HERR.a","HERR.pl","LANCE.a","SMELT.a","SMELT.pl","SHINER","SNAKE","STAG","STICKL","STARRY")
sp.nom <- c("Chinook salmon (age 0)","Chum salmon","Coho salmon (age 1 except 1 individ age 0)","Herring (adult)","Herring (post-larval)",
            "Sand Lance (adult)","Smelt (adult)","Smelt (post-larval)","Shiner Perch","Snake prickleback","Staghorn sculpin","Stickleback","Starry flounder")
A <- list()  
B <- list()  

for(i in 1:length(sp.list)){
  A[[i]] <- ggplot() +
              geom_point(data=dat.set %>% filter(species.comb==sp.list[i]),aes(y=total,x=month),alpha=0.7) +
              geom_line(data=dat.site.avg %>% filter(species.comb==sp.list[i]),aes(y=avg,x=month)) +
              facet_wrap(~Site,nrow=2) +
              labs(y = paste(sp.nom[i],"Count"),x="Month") +
              ggtitle(sp.nom[i])+
              theme_bw()
  B[[i]] <- ggplot() +
              geom_point(data=dat.set %>% filter(species.comb==sp.list[i]),aes(y=total,x=month,color=Site),alpha=0.7) +
              geom_line(data=dat.site.avg %>% filter(species.comb==sp.list[i]),aes(y=avg,x=month,color=Site)) +
              geom_line(data=dat.skagit.avg %>% filter(species.comb==sp.list[i]), aes(y=AVG,x=month),color="black",lwd=1.5) +
                  labs(y = paste(sp.nom[i],"Count"),x="Month") +
              ggtitle(sp.nom[i])+          
              theme_bw()
}

setwd(plot.dir)
pdf("Beach seince catch time series 2017.pdf",onefile=T,width=7,height=6)
for(i in 1:length(sp.list)){
  print(A[[i]])
  print(B[[i]])
}
dev.off()

############################################################
## Tile plots of occurrence and abundance
############################################################


dat.set.sum <- dat.set %>% group_by(species.comb) %>% summarise(SUM = sum(total)) %>% as.data.frame() %>% arrange(SUM)
dat.skagit.avg$species.comb <-factor(dat.skagit.avg$species.comb,levels=dat.set.sum$species.comb)


all.sp.count <-  ggplot(data=dat.skagit.avg) +
      geom_tile(aes(fill=AVG,x=month,y=species.comb)) +
      scale_fill_gradientn(colors = viridis(32),trans="log10",breaks=c(0.01,0.1,1,10,20,50,100,250)) +
      labs(ylab="Species",xlab="Month") + 
      ggtitle("All species among site average count")

all.sp.sd <-  ggplot(data=dat.skagit.avg) +
  geom_tile(aes(fill=SD,x=month,y=species.comb)) +
  scale_fill_gradientn(colors = viridis(32),trans="log10") +
  labs(ylab="Species",xlab="Month") + 
  ggtitle("All species among site SD count")

all.sp.cv <-  ggplot(data=dat.skagit.avg) +
      geom_tile(aes(fill=CV,x=month,y=species.comb)) +
      scale_fill_gradientn(colors = viridis(32),breaks=seq(0,3,0.5)) +
      labs(ylab="Species",xlab="Month") + 
      ggtitle("All species among site CV count")

### Do tile plot of occurrence >0 at each site

dat.site.occur <- dat.site.avg %>% mutate(zero.one=ifelse(avg>0,1,0)) %>% group_by(month,species.comb) %>% 
                  summarise(occur=sum(zero.one),n.obs=length(Site),frac.occur=occur/n.obs)
dat.site.occur$species.comb <-factor(dat.site.occur$species.comb,levels=dat.set.sum$species.comb)

all.sp.occur <- ggplot(data=dat.site.occur) +
                  geom_tile(aes(fill=frac.occur,x=month,y=species.comb)) +
                  scale_fill_gradientn(colors = viridis(32),breaks=round(seq(0.0,1,length.out=8),2)) +
                  labs(ylab="Species",xlab="Month") + 
                  ggtitle("All species occurrence (fraction of sites sampled with species)")





setwd(plot.dir)
pdf("Beach seince catch tile plots 2017.pdf",onefile=T,width=8,height=10)
  print(all.sp.count)
  print(all.sp.sd)
  print(all.sp.cv)
  print(all.sp.occur)
dev.off()






