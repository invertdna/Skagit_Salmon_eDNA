### Matching qPCR results with seine information.

library(dplyr)
library(mvtnorm)
library(data.table)

base.dir <- "/Users/ole.shelton/GitHub/Skagit_Salmon_eDNA"
setwd(base.dir)

# Load catch information from seines
source("./Analysis/catch analysis/parse catch data.R")

# Load up water samples and information from qPCR
setwd(paste0(base.dir,"/Analysis"))
source("0_load_project.R")
#source("qpcr_load.R")

data_dir <- "../Data/"

### PROCESS WATER SAMPLES#############################################################
water_file <- file.path(data_dir, "water_samples.csv")
water <- fread(water_file)
# Add a POSIX compliant date-time variable
#water$datetime <- lubridate::ymd_hms(paste(water$date, maketime(water$time)), 
#                                    tz = "America/Los_Angeles")

# add event ID and site abbreviation
sites <- load_sites("../Data/sites.csv", gps.req = FALSE)
water[, site_abbr := sites$Abbr[match(water$site_name, sites$site_name)]]
water[, event_id := paste(site_abbr, gsub("^20|-", "", date), sep = "-")]

water$day   <- as.numeric(substr(as.character(water$date),9,10))
water$month <- as.numeric(substr(as.character(water$date),6,7))
water$year  <- as.numeric(substr(as.character(water$date),1,4))

#######################################################################################
# Read in the qPCR results from Piper. Conducted July 2018.

dat <- fread(file.path(data_dir,"/qpcr_piper/all_qpcr_data_piper.csv"))
dat.id <-  fread(file.path(data_dir,"/qpcr_piper/all_qpcr_ids_piper.csv"))

dat <- as.data.frame(dat)
dat.id <- as.data.frame(dat.id)
# Pad sample IDs with leading zero to enable merging.
dat.id$lab_label <- as.character(dat.id$sample)
dat.id$lab_label[nchar(dat.id$lab_label)==1] <- paste0("00",dat.id$lab_label[nchar(dat.id$lab_label)==1])
dat.id$lab_label[nchar(dat.id$lab_label)==2] <- paste0("0",dat.id$lab_label[nchar(dat.id$lab_label)==2])

# merge the data with the lab_labels
dat <- full_join(dat,dat.id,by=c("qpcr_date","Position")) 
dat <- dat %>% select(qpcr_date,Position,Detector,Task,Ct,Quantity,Flag,lab_label,comments)
dat <- dat %>% mutate(species = Detector,species = replace(species, Detector=="ch1269x", "coho"),species = replace(species, Detector=="chi1269y", "chinook"))

# merge in data with actual site names and sample dates
dat.standard <- dat %>% filter(lab_label == "")
dat.samp <- dat %>% filter(lab_label !="") %>% left_join(.,water %>% select(year,month,day,site_name,lab_label) %>% as.data.frame(),by="lab_label")

























sort(unique(dat$template_name))
sort(unique(water$lab_label))
names(water)
names(dat)

### Plots of QPCR results alone.
##############################################################
## --- Plots of raw data and calculation of the standard curve
##############################################################

dat$qbc <- dat$QuantBackCalc
dat$qbc[dat$qbc == 0] <- NA
dat$log.qbc <- log(dat$qbc)

A <- ggplot(dat %>% filter(Task=="Standard"),aes(x=log.qbc,y=Ct,color=Task)) +
    geom_point()+
    geom_smooth(method="lm",formula = y~(x))+
    scale_x_continuous()

mod <- lm(Ct~log.qbc,data=dat %>% filter(Task=="Standard"))
summary(mod)

COEF      <- mod$coefficients
SIGMA.cov <- vcov(mod)
SIGMA.res <- summary(mod)$sigma

N.sim <- 1e5
SIM     <-  data.frame(rmvnorm(N.sim,COEF,SIGMA.cov))
colnames(SIM) <- c("Int","Slope")
SIM$tau <- rnorm(N.sim,0,sqrt(SIGMA.res^2 / SIM$Slope^2)) 
colnames(SIM) <- c("Int","Slope","tau")

qbc.pred.all <- t(dat$Ct %*% t(1/SIM$Slope)) - (SIM$Int / SIM$Slope) + SIM$tau
quant <- t(apply(qbc.pred.all,2,quantile,probs=c(0.025,0.05,0.25,0.75,0.95,0.975),na.rm=T))

colnames(quant) <- c("X.025","X.05","X.25","X.75","X.95","X.975")
qbc.pred <- data.frame(Mean=colMeans(qbc.pred.all), 
                      Median=apply(qbc.pred.all,2,median), 
                      SD = apply(qbc.pred.all,2,sd),
                      quant)
#qpc.pred.exp <- exp(qbc.pred %>% dplyr::select(c-SD))

# Merge in the identifier variables
qbc.pred <- data.frame(cbind(dat %>% select(Task,Ct,Quantity,template_name,template_conc,QuantBackCalc),qbc.pred))

qbc.samp <-  left_join(qbc.pred %>% filter(Task=="Unknown") %>% as.data.frame(),
                       water %>% select(year,month,day,site_name,lab_label) %>% as.data.frame(),
                       by=c("template_name"="lab_label"))
qbc.samp <- qbc.samp %>% mutate(exp.Mean=exp(Mean),exp.Mean= replace(exp.Mean, is.na(exp.Mean)==T,0))

#### START 

out.among.water <- qbc.samp %>% group_by(site_name,year,month,template_name) %>% 
                    summarize(n.pcr.rep = length(template_name), 
                              #mean.pcr = mean(Mean),sd.among.pcr = sd(Mean),se.mean.pcr = sd.among.pcr / sqrt(n.pcr.rep), 
                              exp.mean.pcr=mean(exp.Mean),sd.exp.among.pcr = sd(exp.Mean),se.exp.mean.pcr = sd.exp.among.pcr / sqrt(n.pcr.rep)) %>% 
                    arrange(site_name,year,month) %>% 
                    filter(year ==2017) %>%
                    as.data.frame()
out.among.water$exp.mean.pcr[is.na(out.among.water$exp.mean.pcr)==T] <- 0

out.among.site.by.time <- out.among.water %>% group_by(site_name,year,month) %>% 
                        summarize(N.rep.water = length(month),Mean = mean(exp.mean.pcr), SD = sd(exp.mean.pcr), SE = SD / N.rep.water)

out.by.time <- out.among.site.by.time %>% group_by(year,month) %>% 
  summarize(N.site = length(site_name),SD = sd(Mean),Mean = mean(Mean), SE = SD / N.site)

out.by.site <- out.among.site.by.time %>% group_by(year,site_name) %>% 
  summarize(N.month = length(site_name),SD = sd(Mean),Mean = mean(Mean), SE = SD / N.month)



# out.among.site <- out.among.water %>% group_by(site_name,year,month) %>% 
#                         summarize(n.pcr.rep = length(mean.pcr, mean.pcr = mean(Mean),sd.among.pcr = sd(Mean),
#             se.mean.pcr = sd.among.pcr / sqrt(n.pcr.rep) , sd.within.pcr = mean(SD))

var.plot <- ggplot() +
              geom_boxplot(data=out.among.water,aes(y=sd.exp.among.pcr,x=1)) +
              geom_jitter(data=out.among.water,aes(y=sd.exp.among.pcr,x=1),width=0.2,color="red",alpha=0.5) +
              geom_boxplot(data=out.among.site.by.time,aes(y=SD,x=2)) +
              geom_jitter(data=out.among.site.by.time,aes(y=SD,x=2),width=0.2,color="red",alpha=0.5) +
              geom_boxplot(data=out.by.time,aes(y=SD,x=3)) +
              geom_jitter(data=out.by.time,aes(y=SD,x=3),width=0.2,color="red",alpha=0.5) +   
              geom_boxplot(data=out.by.site,aes(y=SD,x=4)) +
              geom_jitter(data=out.by.site,aes(y=SD,x=4),width=0.2,color="red",alpha=0.5) +            
              #scale_y_continuous(limits=c(0,10)) + 
              scale_x_continuous(breaks = c(1,2,3,4),labels=c("PCR","Within Site","Among Site","Among Month") )+
              labs(y="Standard Deviation",x="")+
              theme_bw()
var.plot


pcr.index.by.site <- ggplot() +
        geom_jitter(data=out.among.water,aes(y=exp.mean.pcr,x=month),width=0.1,alpha=0.5,color="red") +
        geom_line(data=out.among.site.by.time,aes(y=Mean,x=month),color="black")+
        #geom_errorbar(aes(ymin=mean.pcr-se.mean.pcr,ymax=mean.pcr+se.mean.pcr))+
        facet_wrap(~site_name) +
        labs(x="Month",y="DNA concentration") +
        theme_bw()

pcr.index <- ggplot() +
        geom_jitter(data=out.among.water,aes(y=exp.mean.pcr,x=month,color=site_name),width=0.1,alpha=0.5) +
        geom_line(data=out.among.site.by.time,aes(y=Mean,x=month,color=site_name))+
        geom_line(data=out.by.time,aes(y=Mean,x=month),color="black",size=2) +      
        labs(x="Month",y="DNA concentration") +
        theme_bw()

mean.v.sd <- list()
mean.v.sd[[1]] <- ggplot(out.among.water %>% filter(year ==2017),aes(x=exp.mean.pcr,y=sd.exp.among.pcr)) +
  geom_point(aes(color=site_name),alpha=0.8) +
  labs(x="Mean [Chinook DNA concentration]",y="Among water sample SD \n [log(Chinook DNA concentration)]") +
  theme_bw()  
  #geom_errorbar(aes(ymin=mean.pcr-se.mean.pcr,ymax=mean.pcr+se.mean.pcr))+
  #facet_wrap(~site_name)

mean.v.sd[[2]] <- ggplot(out.among.site.by.time %>% filter(year ==2017),aes(x=Mean,y=SD)) +
  geom_point(aes(color=site_name),alpha=0.8) +
  labs(x="Within Site Mean [Chinook DNA concentration]",y="Within Site SD \n [Chinook DNA concentration]") +
  lims(y=c(0,6.25))+
  theme_bw()  
mean.v.sd[[2]]

mean.v.sd[[3]] <- ggplot(out.by.site %>% filter(year ==2017),aes(x=Mean,y=SD)) +
  geom_point(aes(color=site_name),alpha=0.8) +
  labs(x="Among Site Mean [Chinook DNA concentration]",y="Among Site SD \n [Chinook DNA concentration]") +
  lims(y=c(0,max(out.by.site$SD)),x=c(0,max(out.by.site$Mean)))+
  theme_bw()  
mean.v.sd[[3]]

mean.v.sd[[4]] <- ggplot(out.by.time %>% mutate(month=factor(month)),aes(x=Mean,y=SD)) +
  geom_point(aes(color=month),alpha=0.8) +
  labs(x="Among Month Mean [Chinook DNA concentration]",y="Among Month SD \n [Chinook DNA concentration]") +
  lims(y=c(0,max(out.by.time$SD)),x=c(0,max(out.by.time$Mean)))+
  theme_bw()  
mean.v.sd[[4]]

##############################################################################
##############################################################################
##### Merge qPCR and Catch results
##############################################################################
##############################################################################

############ These are the relevant data.frames from "parse catch data.r"
# dat.set - individual sets observed 
# dat.site.avg - average of two sets done at a particular spot
# dat.skagit.avg - among site average for a particular date
# dat.site.avg   -  among date average for a particular site


############  These are the relevant data.frames from the above section
# out.among.water -
# out.among.site.by.time -
# out.by.site - 
# out.by.time

#################################################################
# rename things ease of comparisons
catch.set          <- dat.set
catch.site.by.time <- dat.site.by.time.avg
catch.by.time      <- dat.skagit.avg
catch.by.site      <- dat.site.avg

pcr.water        <- out.among.water
pcr.site.by.time <- out.among.site.by.time
pcr.by.time      <- out.by.time
pcr.by.site      <- out.by.site

#3 Create consensus site name set
catch.set$site.merge <- as.character(catch.set$Site)
catch.site.by.time$site.merge <- as.character(catch.site.by.time$Site)
catch.by.site$site.merge <- as.character(catch.by.site$Site)

pcr.water$site.merge <- as.character(pcr.water$site_name)
pcr.site.by.time$site.merge <- as.character(pcr.site.by.time$site_name)
pcr.by.site$site.merge <- as.character(pcr.by.site$site_name)

catch.set <- catch.set %>% mutate(site.merge= replace(site.merge,grepl("Turner",site.merge),"Turners")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Hoypus",site.merge),"Hoypus")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Straw",site.merge),"Strawberry")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Goat",site.merge),"Goat")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Dugualla",site.merge),"Dugualla")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Lone",site.merge),"Lone Tree")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Mariner",site.merge),"Mariners")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Brown",site.merge),"Brown")) 
catch.site.by.time <- catch.site.by.time %>% mutate(site.merge= replace(site.merge,grepl("Turner",site.merge),"Turners")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Hoypus",site.merge),"Hoypus")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Straw",site.merge),"Strawberry")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Goat",site.merge),"Goat")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Dugualla",site.merge),"Dugualla")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Lone",site.merge),"Lone Tree")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Mariner",site.merge),"Mariners")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Brown",site.merge),"Brown")) 
catch.by.site <- catch.by.site %>% mutate(site.merge= replace(site.merge,grepl("Turner",site.merge),"Turners")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Hoypus",site.merge),"Hoypus")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Straw",site.merge),"Strawberry")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Goat",site.merge),"Goat")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Dugualla",site.merge),"Dugualla")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Lone",site.merge),"Lone Tree")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Mariner",site.merge),"Mariners")) %>%
                          mutate(site.merge= replace(site.merge,grepl("Brown",site.merge),"Brown")) 

pcr.water <- pcr.water %>% mutate(site.merge= replace(site.merge,grepl("Turner",site.merge),"Turners")) %>%
  mutate(site.merge= replace(site.merge,grepl("Hoypus",site.merge),"Hoypus")) %>%
  mutate(site.merge= replace(site.merge,grepl("Straw",site.merge),"Strawberry")) %>%
  mutate(site.merge= replace(site.merge,grepl("Goat",site.merge),"Goat")) %>%
  mutate(site.merge= replace(site.merge,grepl("Dugualla",site.merge),"Dugualla")) %>%
  mutate(site.merge= replace(site.merge,grepl("Lone",site.merge),"Lone Tree")) %>%
  mutate(site.merge= replace(site.merge,grepl("Mariner",site.merge),"Mariners")) %>%
  mutate(site.merge= replace(site.merge,grepl("Brown",site.merge),"Brown")) 
pcr.site.by.time <- pcr.site.by.time %>% mutate(site.merge= replace(site.merge,grepl("Turner",site.merge),"Turners")) %>%
  mutate(site.merge= replace(site.merge,grepl("Hoypus",site.merge),"Hoypus")) %>%
  mutate(site.merge= replace(site.merge,grepl("Straw",site.merge),"Strawberry")) %>%
  mutate(site.merge= replace(site.merge,grepl("Goat",site.merge),"Goat")) %>%
  mutate(site.merge= replace(site.merge,grepl("Dugualla",site.merge),"Dugualla")) %>%
  mutate(site.merge= replace(site.merge,grepl("Lone",site.merge),"Lone Tree")) %>%
  mutate(site.merge= replace(site.merge,grepl("Mariner",site.merge),"Mariners")) %>%
  mutate(site.merge= replace(site.merge,grepl("Brown",site.merge),"Brown")) 
pcr.by.site <- pcr.by.site %>% mutate(site.merge= replace(site.merge,grepl("Turner",site.merge),"Turners")) %>%
  mutate(site.merge= replace(site.merge,grepl("Hoypus",site.merge),"Hoypus")) %>%
  mutate(site.merge= replace(site.merge,grepl("Straw",site.merge),"Strawberry")) %>%
  mutate(site.merge= replace(site.merge,grepl("Goat",site.merge),"Goat")) %>%
  mutate(site.merge= replace(site.merge,grepl("Dugualla",site.merge),"Dugualla")) %>%
  mutate(site.merge= replace(site.merge,grepl("Lone",site.merge),"Lone Tree")) %>%
  mutate(site.merge= replace(site.merge,grepl("Mariner",site.merge),"Mariners")) %>%
  mutate(site.merge= replace(site.merge,grepl("Brown",site.merge),"Brown")) 

############### Finish naming conventions.


## Merge together sets and water samples.
compare.site.by.time <- left_join(pcr.site.by.time %>% mutate(pcr.Mean =Mean,pcr.SD=SD,pcr.SE=SE) %>% as.data.frame() %>%
                                      select(year,month,pcr.Mean,pcr.SD,pcr.SE,site.merge),
                                  catch.site.by.time %>% mutate(catch.Mean = avg,catch.SD=SD) %>% filter(species.comb=="CK") %>%
                                      select(year,month,catch.Mean,catch.SD,site.merge))

s.by.t <- list()  
s.by.t[[1]] <- ggplot(compare.site.by.time,aes(x=catch.Mean,y=pcr.Mean,color=site.merge)) +
        geom_point() +
        geom_errorbar(aes(ymin=pcr.Mean-pcr.SD,ymax=pcr.Mean+pcr.SD),alpha=0.7,width=0.5) +
        geom_errorbarh(aes(xmin=catch.Mean - catch.SD,xmax=catch.Mean+catch.SD),alpha=0.7,height=0.5) +
        labs(y="DNA Concentration",x="Beach Seine Catch",color="Site") +
        theme_bw()

s.by.t[[2]]<- ggplot(compare.site.by.time,aes(x=catch.Mean,y=pcr.Mean)) +
  geom_point() +
  geom_errorbar(aes(ymin=pcr.Mean-pcr.SD,ymax=pcr.Mean+pcr.SD),alpha=0.7,width=0.5) +
  geom_errorbarh(aes(xmin=catch.Mean - catch.SD,xmax=catch.Mean+catch.SD),alpha=0.7,height=0.5) +
  labs(y="DNA Concentration",x="Beach Seine Catch") +
  theme_bw()+
  facet_wrap(~site.merge,scales = "free")
s.by.t[[2]]

######## Merge pcr and catch by sample month
compare.by.time <- left_join(pcr.by.time %>% mutate(pcr.Mean =Mean,pcr.SD=SD,pcr.SE=SE,N.pcr=N.site) %>% as.data.frame() %>%
                                    select(year,month,N.pcr,pcr.Mean,pcr.SD,pcr.SE),
                                  catch.by.time %>% mutate(catch.Mean = AVG,catch.SD=SD,catch.SE=SE,N.catch=N.catch) %>% filter(species.comb=="CK") %>%
                                    select(year,month,N.catch,catch.Mean,catch.SD,catch.SE))

compare.time <- ggplot(compare.by.time %>% mutate(month=as.factor(month)),aes(x=catch.Mean,y=pcr.Mean,color=month)) +
  geom_point() +
  geom_errorbar(aes(ymin=pcr.Mean-pcr.SE,ymax=pcr.Mean+pcr.SE),alpha=0.7,width=0.5) +
  geom_errorbarh(aes(xmin=catch.Mean - catch.SE,xmax=catch.Mean+catch.SE),alpha=0.7,height=0.5) +
  labs(x="Beach Seine Catch", y= "DNA concentration") +
  theme_bw()
compare.time

cor.test(compare.by.time$pcr.Mean,compare.by.time$catch.Mean)

######## Merge pcr and catch by sample site
compare.by.site <- left_join(pcr.by.site %>% mutate(pcr.Mean =Mean,pcr.SD=SD,pcr.SE=SE,N.pcr=N.month) %>% as.data.frame() %>%
                               select(year,site.merge,N.pcr,pcr.Mean,pcr.SD,pcr.SE),
                             catch.by.site %>% mutate(catch.Mean = AVG,catch.SD=SD,catch.SE=SE,N.catch=N.catch) %>% filter(species.comb=="CK") %>%
                               select(year,site.merge,N.catch,catch.Mean,catch.SD,catch.SE))

compare.site <- ggplot(compare.by.site ,aes(x=catch.Mean,y=pcr.Mean,color=site.merge)) +
  geom_point() +
  geom_errorbar(aes(ymin=pcr.Mean-pcr.SE,ymax=pcr.Mean+pcr.SE),alpha=0.7,width=0.5) +
  geom_errorbarh(aes(xmin=catch.Mean - catch.SE,xmax=catch.Mean+catch.SE),alpha=0.7,height=0.5) +
  lims(x=c(0,max(compare.by.site$catch.Mean+compare.by.site$catch.SE)),y=c(0,max(compare.by.site$pcr.Mean+compare.by.site$pcr.SE)))+
  theme_bw()
compare.site

cor.test(compare.by.site$pcr.Mean,compare.by.site$catch.Mean)

####################################################################
## Plot Index of Abundance for both PCR and Catch
####################################################################

compare.index <- compare.by.time %>% mutate(pcr.ref = pcr.Mean[month==2],
                                              pcr.index = pcr.Mean/pcr.ref,
                                              pcr.index.sd=sqrt(pcr.SD^2 / pcr.ref^2),
                                              pcr.index.se=pcr.index.sd/sqrt(N.pcr),
                                              catch.ref= catch.Mean[month==2],
                                              catch.index = catch.Mean/catch.ref,
                                              catch.index.sd=sqrt(catch.SD^2 / catch.ref^2),
                                              catch.index.se=catch.index.sd/sqrt(N.catch)
                                              )

index.standardization <- ggplot(compare.index) +
    geom_line(aes(y=pcr.index,x=month,color="qPCR"),size=1.5) +
    geom_ribbon(aes(x=month,ymin=pcr.index-pcr.index.se,ymax=pcr.index+pcr.index.se),fill="red",alpha=0.3) +
    geom_line(aes(y=catch.index,x=month,color ="Seine"),size=1.5) +
    geom_ribbon(aes(x=month,ymin=catch.index-catch.index.se,ymax=catch.index+catch.index.se),fill="black",alpha=0.3) +
    geom_hline(yintercept = 1,linetype=2) +
    scale_color_manual(values=c("red","black")) +

    labs(y="Index", x="Month",color="Gear type")+
    theme_bw()
  



























# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# new <- data.frame(log.qbc = dat$log.qbc)
# new.pred <- predict(mod,new,interval="prediction",se.fit=T)
# new.fit <- data.frame(fit = new.pred$fit[,"fit"], se.fit =new.pred$se.fit)
# 
# dat <- cbind(dat,new.fit) %>% as.data.frame()
# 
# 
# #######################################################################################
# ## -- Summarize the qPCR results relative to the available water samples.
# #######################################################################################
# 
# # Key points. Grouping variable in "lab_label" in the water sample file ("water") and "template_name" in the qPCR file.
# 
# dat.summ <- dat %>% dplyr::select(template_name,template_rep) %>% group_by(template_name) %>% summarize(n.rep=length(template_name))
# samp.run <- left_join(water,dat.summ,by=c("lab_label"="template_name"))
# 
# temp <- samp.run %>% filter(is.na(n.rep)==F) %>% group_by(site_name, date) %>% summarize(samp = length(n.rep)) %>%
#           dcast(.,date~site_name,value.var=c("samp")) %>% as.data.frame()
# 
# samp.run %>% filter(site_name %in% c("Mariners Bluff","Brown Point","Dugualla Bluff")) %>% select(date,site_name,n.rep,lab_label)
# 
