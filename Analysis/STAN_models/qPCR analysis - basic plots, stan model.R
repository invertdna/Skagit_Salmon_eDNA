### Fitting qPCR statistical model
rm(list=ls())
library(dplyr)
library(mvtnorm)
library(data.table)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())


base.dir <- "/Users/ole.shelton/GitHub/Skagit_Salmon_eDNA"
plot.dir <- "./Figures/Exploratory"
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
dat <- dat %>% dplyr::select(qpcr_date,Position,Detector,Task,Ct,Quantity,density,Flag,lab_label,comments)

dat <- dat %>% mutate(species = Detector,species = replace(species, Detector=="ch1269x", "coho"),species = replace(species, Detector=="chi1269y", "chinook"))
# merge in data with actual site names and sample dates
dat.standard <- dat %>% filter(lab_label == "",is.na(density)==F,species!="")
dat.samp <- dat %>% filter(lab_label !="") %>% left_join(.,water %>% dplyr::select(year,month,day,site_name,lab_label) %>% as.data.frame(),by="lab_label")

#### Make basic diagnostic plots for standards
head(dat.standard)

chin.dens <- c(1.7e-1,1.7e-2,1.7e-3,1.7e-4,1.7e-5,1.7e-6,1.7e-07,
               2.32e-1,2.32e-2,2.32e-3,2.32e-4,2.32e-5,2.32e-6)
coho.dens <- c(1.5e-1,1.5e-2,1.5e-3,1.5e-4,1.5e-5,1.5e-6,1.5e-07,
               1.08,1.08e-1,1.08e-2,1.08e-3,1.08e-4,1.08e-5,1.08e-6)

dat.stand.chin <- dat.standard %>% filter(species=="chinook") %>% 
                    filter(density %in% chin.dens) %>%
                    mutate(Ct=replace(Ct,Ct=="Undetermined","")) %>%
                    mutate(pres=1,pres=replace(pres,Ct=="",0))
dat.stand.chin$Ct <- as.numeric(as.character(dat.stand.chin$Ct))

dat.stand.coho <- dat.standard %>% filter(species=="coho") %>% 
                    filter(density %in% coho.dens) %>%
                    mutate(Ct=replace(Ct,Ct=="Undetermined","")) %>%
                    mutate(pres=1,pres=replace(pres,Ct=="",0))
dat.stand.coho$Ct <- as.numeric(as.character(dat.stand.coho$Ct))

chin.stand.plot <- ggplot(dat.stand.chin) +
  geom_point(aes(x=density,y=Ct,shape=as.factor(qpcr_date)),alpha=0.75) +
  scale_x_log10() +
  theme_bw()
chin.stand.plot

chin.stand.plot.pres <- ggplot(dat.stand.chin) +
  geom_jitter(aes(x=density,y=pres,shape=as.factor(qpcr_date)),alpha=0.75,width=0,height=0.05) +
  scale_x_log10() +
  theme_bw()
chin.stand.plot.pres

coho.stand.plot <- ggplot(dat.stand.coho) +
  geom_point(aes(x=density,y=Ct,color=as.factor(qpcr_date)),alpha=0.5) +
  scale_x_log10()
coho.stand.plot

coho.stand.plot.pres <- ggplot(dat.stand.coho) +
  geom_jitter(aes(x=density,y=pres,color=as.factor(qpcr_date)),alpha=0.5,width=0,height=0.05) +
  scale_x_log10()
coho.stand.plot.pres

### Make adjustments to dat.samp to cull observations from 2016, drop missing data, and add presence absence data 
dat.samp <- dat.samp %>% filter(year==2017) %>% mutate(Ct=replace(Ct,Ct=="Undetermined",NA)) %>%
              mutate(pres=1,pres=replace(pres,is.na(Ct)==T,0))

#### Checks to make sure the right samples were run
check <- dat.samp %>% filter(species=="chinook") %>% group_by(site_name,year,month) %>% 
          summarize(N=length(unique(lab_label))) %>% arrange(site_name,year,month) %>% as.data.frame()

check2 <- dat.samp %>% filter(species=="chinook") %>% group_by(site_name,year,month,lab_label) %>% 
  summarize(N=length(unique(lab_label))) %>% arrange(year,month,site_name,lab_label) %>% as.data.frame()

#check
#################################################################
#################################################################
# Construct the indices and helper files to make running the statistical model easy.
#################################################################
#################################################################
SITES  <- data.frame(site_name=sort(unique(dat.samp$site_name)),site_idx=1:length(unique(dat.samp$site_name)))
N_site <- max(SITES$site_idx)
MONTH  <- data.frame(month=sort(unique(dat.samp$month)),month_idx=1:length(unique(dat.samp$month)))
N_month <- nrow(MONTH)
BOTTLES <- data.frame(lab_label=sort(unique(dat.samp$lab_label)),bottle_idx=1:length(unique(dat.samp$lab_label)))
N_bottle <- nrow(BOTTLES)

bottles_labels <- dat.samp %>% dplyr::select(year,month,lab_label,site_name) %>% 
                      group_by(lab_label,year,month,site_name) %>% summarise(x=length(lab_label)) %>%
                      as.data.frame()
BOTTLES <- left_join(BOTTLES, bottles_labels %>% dplyr::select(year,month,lab_label,site_name)           )

PCR     <- data.frame(qpcr_date=sort(unique(dat.samp$qpcr_date)),pcr_idx=1:length(unique(dat.samp$qpcr_date)))
N_pcr   <- nrow(PCR)

SITE_MONTH <- dat.samp %>% group_by(site_name,month) %>% summarise(n_obs = length(site_name)) %>% dplyr::select(-n_obs) %>% as.data.frame()
SITE_MONTH$site_month_idx <- 1:nrow(SITE_MONTH)
SITE_MONTH_BOTTLES <- full_join(BOTTLES,SITE_MONTH)

SITE_MONTH <- full_join(SITE_MONTH,SITES,by="site_name")
SITE_MONTH <- full_join(SITE_MONTH,MONTH,by="month")
N_site_month <- nrow(SITE_MONTH)



### Combine the indices
dat.samp <- left_join(dat.samp,SITES,by="site_name") %>% 
            left_join(.,MONTH,by="month") %>%
            #left_join(.,BOTTLES,by="lab_label") %>%
            left_join(.,PCR,by="qpcr_date") %>%
            left_join(.,SITE_MONTH_BOTTLES,by=c("site_name","month","lab_label"))

#### Pull out samples that were used in multiple qpcrs
A<- dat.samp %>% filter(species=="chinook") %>% group_by(lab_label,qpcr_date,year.x,month,site_name) %>% summarize(length(qpcr_date))
duplicate.pcr.2017<-A %>% group_by(lab_label,year.x) %>% summarize(n.pcr=length(lab_label)) %>% filter(n.pcr > 1,year.x==2017) %>% as.data.frame()

dup.pcr.raw <- dat.samp %>% filter(lab_label %in% duplicate.pcr.2017$lab_label)

dup.pcr.raw <- dup.pcr.raw %>% filter(species=="chinook") %>% 
  dplyr::select(species, site_name,qpcr_date,lab_label,Ct,site_month_idx) %>%
  arrange(lab_label) 

##### MAKE FILES THAT ARE EASY TO ROLL INTO STAN.
dat.samp.chin.bin <- dat.samp %>% filter(species=="chinook")
dat.samp.coho.bin <- dat.samp %>% filter(species=="coho")
dat.samp.chin.count <- dat.samp %>% filter(pres==1, dat.samp$species=="chinook")
dat.samp.coho.count <- dat.samp %>% filter(pres==1, dat.samp$species=="coho")

dat.stand.chin.bin <- left_join(dat.stand.chin,PCR,by="qpcr_date")
dat.stand.coho.bin <- left_join(dat.stand.coho,PCR,by="qpcr_date")
dat.stand.chin.count <- dat.stand.chin.bin %>% filter(pres==1)
dat.stand.coho.count <- dat.stand.coho.bin %>% filter(pres==1)

SPECIES <- "chinook"
if(SPECIES == "chinook"){
  N_obs_bin   <- nrow(dat.stand.chin.bin)
  N_obs_count <- nrow(dat.stand.chin.count)
}
if(SPECIES == "coho"){
  N_obs_bin   <- nrow(dat.stand.coho.bin)
  N_obs_count <- nrow(dat.stand.coho.count)
}


##### How many bottles and sites-month combinations have >0 counts for the qPCR?
n.zeros.bottle <- dat.samp.chin.bin %>% group_by(site_name,year.x,month,lab_label,site_month_idx) %>% 
            summarize(n.tot = length(pres),n.obs = sum(pres)) %>% mutate(frac = n.obs/n.tot) %>% as.data.frame()
n.zeros.site.month <- n.zeros.bottle %>% group_by(site_name,year.x,month,site_month_idx) %>% 
            summarize(N.bot = length(lab_label),N.tot = sum(n.tot),N.pos=sum(n.obs)) %>% as.data.frame()
length(which(n.zeros.site.month$N.obs==0))


counter <- SITE_MONTH %>% group_by(month_idx) %>% summarize(counter= length(month)) %>% arrange(month_idx) %>% as.data.frame()
##################################################################
#### MAKE DATA FOR STAN
##################################################################
OFFSET = -4.5 # Value to imrpove Fitting in STAN


stan_data = list(
    # Chinook
    "bin_stand"   = dat.stand.chin.bin$pres,
    "count_stand" = dat.stand.chin.count$Ct,
    "D_bin_stand" = log10(dat.stand.chin.bin$density),
    "D_count_stand" = log10(dat.stand.chin.count$density),
    
    "bin_samp"    = dat.samp.chin.bin$pres,
    "count_samp"  = as.numeric(dat.samp.chin.count$Ct),
    # Coho
    # "bin_stand"   = dat.stand.coho.bin$pres,
    # "count_stand" = dat.stand.coho.count$Ct,
    # "bin_samp"    = dat.samp.coho.bin$pres,
    # "count_samp"  = dat.samp.coho.count$Ct,
    
    # Indices and counters
    "N_site"   = N_site,   # Number of Sites
    "N_month"  = N_month,  # Number of months observed
    "N_bottle" = N_bottle, # Number of individual bottles observed.
    "N_pcr"    = N_pcr,    # Number of PCR plates
    "N_site_month" = N_site_month,
    "N_bin_stand"   = length(dat.stand.chin.bin$pres),
    "N_count_stand" = length(dat.stand.chin.count$Ct),
    "N_bin_samp"   = length(dat.samp.chin.bin$pres),
    "N_count_samp" = length(dat.samp.chin.count$Ct),
    
    # Indices for Standards
    "pcr_stand_bin_idx"   = dat.stand.chin.bin$pcr_idx,
    "pcr_stand_count_idx" = dat.stand.chin.count$pcr_idx,
    "pcr_samp_bin_idx"   = dat.samp.chin.bin$pcr_idx,
    "pcr_samp_count_idx" = dat.samp.chin.count$pcr_idx,
    
    # Indices for site-months and bottles
    "site_month_idx" = SITE_MONTH_BOTTLES$site_month_idx,
    "bottle_idx"     = SITE_MONTH_BOTTLES$bottle_idx,
    
    # Index used in calculating Monthly abundance index over space
    "gamma_idx" = SITE_MONTH$month_idx,
    #"counter" =  counter$counter,
    
    # Indices for Samples
    "site_bin_idx"   = dat.samp.chin.bin$site_idx,
    "site_count_idx" = dat.samp.chin.count$site_idx,
    "month_bin_idx"    = dat.samp.chin.bin$month_idx,
    "month_count_idx"  = dat.samp.chin.count$month_idx,
    "bottle_bin_idx"   = dat.samp.chin.bin$bottle_idx,
    "bottle_count_idx" = dat.samp.chin.count$bottle_idx,
    "site_month_bin_idx"   = dat.samp.chin.bin$site_month_idx,
    "site_month_count_idx" = dat.samp.chin.count$site_month_idx,
    
    #Offset of density for improving fitting characteristics
    "OFFSET" = OFFSET
)


 stan_pars = c(
   "beta_0", # intercept for standards
   "beta_1", # slope for standards
   "phi_0",  # logit intercept for standards
   "phi_1",  # logit slope for standard,
   
   # "beta_0_bar",
   # "beta_0_sd",
   # "beta_1_bar",
   # "beta_1_sd",

   # "phi_0_bar",
   # "phi_0_sd",
   # "phi_1_bar",
   # "phi_1_sd",
     
   "gamma",  # site-month combinations for log-densities
   "delta",  # random effect for each bottle around the site-month mean.
   
   "D",     # Latent variable for Log-Density in each bottle-site-time
   
   "sigma_stand_int", # variability among standards regression.
   #"sigma_stand_slope", # variability among standards regression.
   #"sigma_stand_slope2", # variability among standards regression.
   
      # "sigma_stand_int_bar", # variability among standards regression.
   # "sigma_stand_slope_bar", # variability among standards regression.
   # "sigma_stand_int_sd", # variability among standards regression.
   # "sigma_stand_slope_sd", # variability among standards regression.
   
   "sigma_pcr",     # variability among samples, given individual bottle, site, and month 
   "tau_bottle"   # variability among bottles, given site, and month
   
   # "geom_month_index",
   # "arith_month_index"
)   
    
### INTIAL VALUES

 stan_init_f1 <- function(n.chain,N_bottle,N_pcr,N_site_month){ 
   A <- list()
   for(i in 1:n.chain){
     A[[i]] <- list(
       
       sigma_stand_int = runif(1,0.01,2),
       #sigma_stand_slope = runif(1,-1,-0.1),
       # beta_0_bar = runif(1,20,40),
       # beta_1_bar = rnorm(1,-3,1),
       beta_0 = runif(N_pcr,20,30),
       beta_1 = rnorm(N_pcr,-3,1),
       
       # phi_0_bar = runif(1,10,25),
       # phi_1_bar = rnorm(1,5,1),
       phi_0  = runif(N_pcr,0,20),
       phi_1  = rnorm(N_pcr,5,1),
       D      = rnorm(N_site_month,-4,1),
       gamma  = rnorm(N_site_month,-4,1),
       sigma_pcr = runif(1,0.01,0.4),
       tau_bottle = runif(1,0.01,0.2)
     )
   }
   return(A)
 }
 
 #################################################################### 
 #################################################################### 
 ##### STAN
 #################################################################### 
 #################################################################### 
 N_CHAIN = 5
 Warm = 5000
 Iter = 10000
 Treedepth = 11
 Adapt_delta = 0.80
 
 stanMod = stan(file = './STAN_models/qPCR_piper.stan',data = stan_data, 
                verbose = FALSE, chains = N_CHAIN, thin = 5, 
                warmup = Warm, iter = Warm + Iter, 
                control = list(max_treedepth=Treedepth,adapt_delta=Adapt_delta,metric="diag_e"),
                pars = stan_pars,
                boost_lib = NULL,
               # sample_file = "./STAN_models/Output files/test.csv",
                init = stan_init_f1(n.chain=N_CHAIN,
                                     N_bottle=N_bottle,
                                     N_pcr= N_pcr,
                                     N_site_month = N_site_month
                                    ))
 
 #################################################################### 
 #################################################################### 
 #################################################################### 
    
 pars <- rstan::extract(stanMod, permuted = TRUE)
 # get_adaptation_info(stanMod)
 samp_params <- get_sampler_params(stanMod)
 #samp_params 
 stanMod_summary <- summary(stanMod)$summary
 round(stanMod_summary,2)
 
 base_params <- c(
 "beta_0",
 "beta_1",
  "phi_0",
  "phi_1",
 
 # "beta_0_bar",
 # "beta_0_sd",
 #  "beta_1_bar",
 #  "beta_1_sd",
 
 # "phi_0_bar",
 # "phi_0_sd",
 # "phi_1_bar",
 # "phi_1_sd",

 "sigma_stand_int", # variability among standard regression.
 #"sigma_stand_slope", # variability among standards regression.
 #"sigma_stand_slope2", # variability among standards regression.
 "sigma_pcr",     # variability among samples, given individual bottle, site, and month 
 "tau_bottle"   # variability among bottles, given site, and month
) 
 
##### MAKE SOME DIAGNOSTIC PLOTS

 print(traceplot(stanMod,pars=c("lp__",base_params),inc_warmup=FALSE))
 
 #pairs(stanMod, pars = c(base_params), log = FALSE, las = 1)
 
B1 <- apply(pars$beta_0,2,mean)
B2 <- apply(pars$beta_1,2,mean)

P0 <- apply(pars$phi_0,2,mean)
P1 <- apply(pars$phi_1,2,mean)

V0 <-  mean(pars$sigma_stand_int)
V1 <- mean(pars$sigma_stand_slope)
#V2 <- mean(pars$sigma_stand_slope2)

# Plot regression against Standard
 X <- seq(-7,0,length.out=1000) - OFFSET
 Y <- t(B1 + B2 %*% t(X ))
 
 STAND.REG <- data.frame(X=X,Y=Y)
 STAND.REG <- melt(STAND.REG,id.vars="X",value.name="Y")
 
 x.lim=c(min(X),max(X))
 y.lim=c(20,40)
 for(i in 1:ncol(Y)){
  plot(Y[,i]~X,xlim=x.lim,ylim=y.lim,type="l",col=2)
  par(new=T)
 }
 plot(dat.stand.chin.count$Ct~log10(dat.stand.chin.count$density),xlim=x.lim,ylim=y.lim)

 chin.stand.plot <- ggplot(dat.stand.chin) +
   geom_point(aes(x=log(density,10)- OFFSET ,y=Ct,shape=as.factor(qpcr_date)),alpha=0.75) +
   theme_bw()
 chin.stand.plot <- chin.stand.plot +
    geom_line(data=STAND.REG,aes(x=X,y=Y,color=variable))
 chin.stand.plot
 
 # Plot occurrence of standard
 Y <- t(P0 + P1 %*% t(X ))
 LOGIT <- data.frame(X=X,Y=plogis(Y))
 LOGIT <- melt(LOGIT,id.vars="X",value.name="Y")
 
 chin.stand.plot.pres <- ggplot(dat.stand.chin) +
   geom_jitter(aes(x=log(density,10)-OFFSET,y=pres,shape=as.factor(qpcr_date)),alpha=0.75,width=0,height=0.05) +
   geom_line(data=LOGIT,aes(y=Y,x=X,color=variable)) +
   theme_bw()
 chin.stand.plot.pres
 
 
 # Plot variance against Standard
 X <- seq(-6,0,length.out=1000) -OFFSET
 Y <- exp(V0 + V1 * X )
  #Y <- exp(V0 + V1 * X + V2 *X^2)

 x.lim=c(min(X),max(X))
 y.lim = c(0,4)
  plot(Y~X,xlim=x.lim,ylim=y.lim)
  par(new=T)
  plot(sqrt(Y)~X,xlim=x.lim,ylim=y.lim,col=2)
 
  setwd(base.dir)
  setwd(plot.dir)
  pdf("PCR diagnostics.pdf",width=8,height=7)
    print(chin.stand.plot)  
    print(chin.stand.plot.pres)
  dev.off()
  
  ################################################################################################
  ################################################################################################
  ################################################################################################
  ################################################################################################
  ##### Extract data of interest, save to file for use elsewhere
  ################################################################################################
  ################################################################################################
  ################################################################################################
  ################################################################################################
  
  site.month.out <- data.frame(site_month_idx= 1:ncol(pars$gamma), Mean=apply(pars$gamma,2,mean),
                               Sd=apply(pars$gamma,2,sd),
                               data.frame(t(apply(pars$gamma,2,quantile,probs=c(0.025,0.05,0.10,0.25,0.5,0.75,0.9,0.95,0.975)))))
  bottles.out     <- data.frame(bottle_idx=BOTTLES$bottle_idx, Mean = apply(pars$D,2,mean),
                                Sd=apply(pars$D,2,sd),
                                data.frame(t(apply(pars$D,2,quantile,probs=c(0.025,0.05,0.10,0.25,0.5,0.75,0.9,0.95,0.975)))))

  SITE_MONTH_summary <- left_join(SITE_MONTH,site.month.out,by="site_month_idx") %>% group_by(site_name,month) %>%
                            summarize(MEAN = mean(Mean),SD = mean(Sd),
                                      q.025= mean(X2.5.),
                                      q.05 = mean(X5.),
                                      q.10 = mean(X10.),
                                      q.25 = mean(X25.),
                                      Median=  mean(X50.),
                                      q.75 = mean(X75.),
                                      q.90 = mean(X90.),
                                      q.95 = mean(X95.),
                                      q.975= mean(X97.5.))
  BOTTLES_summary    <- left_join(BOTTLES,bottles.out, by= "bottle_idx")  %>%
                              rename( q.025= X2.5.,
                                      q.05 = X5.,
                                      q.10 = X10.,
                                      q.25 = X25.,
                                      Median=  X50.,
                                      q.75 = X75.,
                                      q.90 = X90.,
                                      q.95 = X95.,
                                      q.975= X97.5.) 
  
  ####
  sd.of.count <- data.frame(
                        id = c("among.standard","among.pcr"),
                        log.sd.est = c(mean(pars$sigma_stand_int), mean(pars$sigma_pcr)),
                        log.sd.uncert = c(sd(pars$sigma_stand_int), sd(pars$sigma_pcr))
                        )
  
  sd.among.time.given.site <- SITE_MONTH_summary %>% group_by(site_name) %>% summarise(SD=sd(MEAN)) 
  sd.among.site.given.time <- SITE_MONTH_summary %>% group_by(month) %>% summarise(SD=sd(MEAN)) 
  sd.among.bottles         <- BOTTLES_summary %>% group_by(site_name,month) %>% summarise(N=length(Mean),SD=sd(Mean))
  
  sd.bottle.model          <- data.frame(SD=mean(pars$tau_bottle))
  
  # Using the math of random variables to calculate the expected variability among samples due to sample processing and PCR replicates.
  Y <- seq(30,40,length.out=1000)
  b_0 <- apply(pars$beta_0,2,mean)
  b_1 <- apply(pars$beta_1,2,mean)
  stand.var <- mean(pars$sigma_stand_int)
  pcr.var  <- mean(pars$sigma_pcr)
  tot.var <- mean(pars$sigma_stand_int^2 + pars$sigma_pcr^2)
  
  
    ### FIX TO REFLECT SAMPLING UNCERTAINTY.
  X.mean <- (Y - b_0) / b_1
  X.sd.stand <- sqrt(pars$sigma_stand_int / rowMeans(pars$beta_1)^2)
  X.sd.pcr   <- sqrt(pars$sigma_pcr / rowMeans(pars$beta_1)^2)
  X.sd.tot   <- sqrt((pars$sigma_stand_int^2 + pars$sigma_pcr^2) / rowMeans(pars$beta_1^2))
  
  sd.among.pcr.samp <- X.sd.pcr
  sd.among.pcr.stand <- X.sd.stand
  sd.among.pcr <- X.sd.tot
  
  
  #########################################
  
  Output.qpcr <- list(stanMod = stanMod, stanMod_summary = stanMod_summary,samp = pars, samp_params=samp_params,
                 dat.samp=dat.samp, 
                 dat.samp.chin.bin = dat.samp.chin.bin, 
                 dat.samp.coho.bin = dat.samp.coho.bin, 
                 dat.samp.chin.count = dat.samp.chin.count,
                 dat.samp.coho.count = dat.samp.coho.count,
                 dat.stand.chin.bin =dat.stand.chin.bin, 
                 dat.stand.coho.bin = dat.stand.coho.bin, 
                 dat.stand.chin.count = dat.stand.chin.count,
                 dat.stand.coho.count = dat.stand.coho.count,
                 OFFSET = OFFSET,
                 base_params =base_params,
                 SITE_MONTH = SITE_MONTH, SITE_MONTH_summary = SITE_MONTH_summary,
                 BOTTLES = BOTTLES, BOTTLES_summary = BOTTLES_summary,
                 N_site   = N_site,   # Number of Sites
                 N_month  = N_month,  # Number of months observed
                 N_bottle = N_bottle, # Number of individual bottles observed.
                 N_pcr    = N_pcr,    # Number of PCR plates
                 N_site_month = N_site_month,
                 sd.among.pcr.stand = sd.among.pcr.stand,
                 sd.among.pcr.samp = sd.among.pcr.samp,
                 sd.among.pcr = sd.among.pcr,
                 sd.among.bottles = sd.among.bottles,
                 sd.among.bottles.model = sd.bottle.model,
                 sd.among.site.given.time = sd.among.site.given.time,
                 sd.among.time.given.site = sd.among.time.given.site
                 )
 
  setwd(base.dir)
  setwd("./Analysis/STAN_models/Output files/Model Fits")
  save(Output.qpcr,file="qPCR Skagit 2017 Fitted.RData")
  
  
  
  
  
  
  
  # ggplot(SITE_MONTH_summary) +
  #     geom_point(aes(y=MEAN,x=month)) +
  #     geom_errorbar(aes(ymax=q.975,ymin=q.025,,x=month),width=0.25) +
  #     facet_wrap(~site_name)
  
  
  
  
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
#   "among.bottle"
#   , mean(pars$tau_bottle)
#   sd(pars$tau_bottle)
#   
#   
#   
#   
#   
#  
# sort(unique(dat$template_name))
# sort(unique(water$lab_label))
# names(water)
# names(dat)
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
# 
# 
# ### Plots of QPCR results alone.
# ##############################################################
# ## --- Plots of raw data and calculation of the standard curve
# ##############################################################
# 
# dat$qbc <- dat$QuantBackCalc
# dat$qbc[dat$qbc == 0] <- NA
# dat$log.qbc <- log(dat$qbc)
# 
# A <- ggplot(dat %>% filter(Task=="Standard"),aes(x=log.qbc,y=Ct,color=Task)) +
#     geom_point()+
#     geom_smooth(method="lm",formula = y~(x))+
#     scale_x_continuous()
# 
# mod <- lm(Ct~log.qbc,data=dat %>% filter(Task=="Standard"))
# summary(mod)
# 
# COEF      <- mod$coefficients
# SIGMA.cov <- vcov(mod)
# SIGMA.res <- summary(mod)$sigma
# 
# N.sim <- 1e5
# SIM     <-  data.frame(rmvnorm(N.sim,COEF,SIGMA.cov))
# colnames(SIM) <- c("Int","Slope")
# SIM$tau <- rnorm(N.sim,0,sqrt(SIGMA.res^2 / SIM$Slope^2)) 
# colnames(SIM) <- c("Int","Slope","tau")
# 
# qbc.pred.all <- t(dat$Ct %*% t(1/SIM$Slope)) - (SIM$Int / SIM$Slope) + SIM$tau
# quant <- t(apply(qbc.pred.all,2,quantile,probs=c(0.025,0.05,0.25,0.75,0.95,0.975),na.rm=T))
# 
# colnames(quant) <- c("X.025","X.05","X.25","X.75","X.95","X.975")
# qbc.pred <- data.frame(Mean=colMeans(qbc.pred.all), 
#                       Median=apply(qbc.pred.all,2,median), 
#                       SD = apply(qbc.pred.all,2,sd),
#                       quant)
# #qpc.pred.exp <- exp(qbc.pred %>% dplyr::select(c-SD))
# 
# # Merge in the identifier variables
# qbc.pred <- data.frame(cbind(dat %>% select(Task,Ct,Quantity,template_name,template_conc,QuantBackCalc),qbc.pred))
# 
# qbc.samp <-  left_join(qbc.pred %>% filter(Task=="Unknown") %>% as.data.frame(),
#                        water %>% select(year,month,day,site_name,lab_label) %>% as.data.frame(),
#                        by=c("template_name"="lab_label"))
# qbc.samp <- qbc.samp %>% mutate(exp.Mean=exp(Mean),exp.Mean= replace(exp.Mean, is.na(exp.Mean)==T,0))
# 
# #### START 
# 
# out.among.water <- qbc.samp %>% group_by(site_name,year,month,template_name) %>% 
#                     summarize(n.pcr.rep = length(template_name), 
#                               #mean.pcr = mean(Mean),sd.among.pcr = sd(Mean),se.mean.pcr = sd.among.pcr / sqrt(n.pcr.rep), 
#                               exp.mean.pcr=mean(exp.Mean),sd.exp.among.pcr = sd(exp.Mean),se.exp.mean.pcr = sd.exp.among.pcr / sqrt(n.pcr.rep)) %>% 
#                     arrange(site_name,year,month) %>% 
#                     filter(year ==2017) %>%
#                     as.data.frame()
# out.among.water$exp.mean.pcr[is.na(out.among.water$exp.mean.pcr)==T] <- 0
# 
# out.among.site.by.time <- out.among.water %>% group_by(site_name,year,month) %>% 
#                         summarize(N.rep.water = length(month),Mean = mean(exp.mean.pcr), SD = sd(exp.mean.pcr), SE = SD / N.rep.water)
# 
# out.by.time <- out.among.site.by.time %>% group_by(year,month) %>% 
#   summarize(N.site = length(site_name),SD = sd(Mean),Mean = mean(Mean), SE = SD / N.site)
# 
# out.by.site <- out.among.site.by.time %>% group_by(year,site_name) %>% 
#   summarize(N.month = length(site_name),SD = sd(Mean),Mean = mean(Mean), SE = SD / N.month)
# 
# 
# 
# # out.among.site <- out.among.water %>% group_by(site_name,year,month) %>% 
# #                         summarize(n.pcr.rep = length(mean.pcr, mean.pcr = mean(Mean),sd.among.pcr = sd(Mean),
# #             se.mean.pcr = sd.among.pcr / sqrt(n.pcr.rep) , sd.within.pcr = mean(SD))
# 
# var.plot <- ggplot() +
#               geom_boxplot(data=out.among.water,aes(y=sd.exp.among.pcr,x=1)) +
#               geom_jitter(data=out.among.water,aes(y=sd.exp.among.pcr,x=1),width=0.2,color="red",alpha=0.5) +
#               geom_boxplot(data=out.among.site.by.time,aes(y=SD,x=2)) +
#               geom_jitter(data=out.among.site.by.time,aes(y=SD,x=2),width=0.2,color="red",alpha=0.5) +
#               geom_boxplot(data=out.by.time,aes(y=SD,x=3)) +
#               geom_jitter(data=out.by.time,aes(y=SD,x=3),width=0.2,color="red",alpha=0.5) +   
#               geom_boxplot(data=out.by.site,aes(y=SD,x=4)) +
#               geom_jitter(data=out.by.site,aes(y=SD,x=4),width=0.2,color="red",alpha=0.5) +            
#               #scale_y_continuous(limits=c(0,10)) + 
#               scale_x_continuous(breaks = c(1,2,3,4),labels=c("PCR","Within Site","Among Site","Among Month") )+
#               labs(y="Standard Deviation",x="")+
#               theme_bw()
# var.plot
# 
# 
# pcr.index.by.site <- ggplot() +
#         geom_jitter(data=out.among.water,aes(y=exp.mean.pcr,x=month),width=0.1,alpha=0.5,color="red") +
#         geom_line(data=out.among.site.by.time,aes(y=Mean,x=month),color="black")+
#         #geom_errorbar(aes(ymin=mean.pcr-se.mean.pcr,ymax=mean.pcr+se.mean.pcr))+
#         facet_wrap(~site_name) +
#         labs(x="Month",y="DNA concentration") +
#         theme_bw()
# 
# pcr.index <- ggplot() +
#         geom_jitter(data=out.among.water,aes(y=exp.mean.pcr,x=month,color=site_name),width=0.1,alpha=0.5) +
#         geom_line(data=out.among.site.by.time,aes(y=Mean,x=month,color=site_name))+
#         geom_line(data=out.by.time,aes(y=Mean,x=month),color="black",size=2) +      
#         labs(x="Month",y="DNA concentration") +
#         theme_bw()
# 
# mean.v.sd <- list()
# mean.v.sd[[1]] <- ggplot(out.among.water %>% filter(year ==2017),aes(x=exp.mean.pcr,y=sd.exp.among.pcr)) +
#   geom_point(aes(color=site_name),alpha=0.8) +
#   labs(x="Mean [Chinook DNA concentration]",y="Among water sample SD \n [log(Chinook DNA concentration)]") +
#   theme_bw()  
#   #geom_errorbar(aes(ymin=mean.pcr-se.mean.pcr,ymax=mean.pcr+se.mean.pcr))+
#   #facet_wrap(~site_name)
# 
# mean.v.sd[[2]] <- ggplot(out.among.site.by.time %>% filter(year ==2017),aes(x=Mean,y=SD)) +
#   geom_point(aes(color=site_name),alpha=0.8) +
#   labs(x="Within Site Mean [Chinook DNA concentration]",y="Within Site SD \n [Chinook DNA concentration]") +
#   lims(y=c(0,6.25))+
#   theme_bw()  
# mean.v.sd[[2]]
# 
# mean.v.sd[[3]] <- ggplot(out.by.site %>% filter(year ==2017),aes(x=Mean,y=SD)) +
#   geom_point(aes(color=site_name),alpha=0.8) +
#   labs(x="Among Site Mean [Chinook DNA concentration]",y="Among Site SD \n [Chinook DNA concentration]") +
#   lims(y=c(0,max(out.by.site$SD)),x=c(0,max(out.by.site$Mean)))+
#   theme_bw()  
# mean.v.sd[[3]]
# 
# mean.v.sd[[4]] <- ggplot(out.by.time %>% mutate(month=factor(month)),aes(x=Mean,y=SD)) +
#   geom_point(aes(color=month),alpha=0.8) +
#   labs(x="Among Month Mean [Chinook DNA concentration]",y="Among Month SD \n [Chinook DNA concentration]") +
#   lims(y=c(0,max(out.by.time$SD)),x=c(0,max(out.by.time$Mean)))+
#   theme_bw()  
# mean.v.sd[[4]]
# 
# ##############################################################################
# ##############################################################################
# ##### Merge qPCR and Catch results
# ##############################################################################
# ##############################################################################
# 
# ############ These are the relevant data.frames from "parse catch data.r"
# # dat.set - individual sets observed 
# # dat.site.avg - average of two sets done at a particular spot
# # dat.skagit.avg - among site average for a particular date
# # dat.site.avg   -  among date average for a particular site
# 
# 
# ############  These are the relevant data.frames from the above section
# # out.among.water -
# # out.among.site.by.time -
# # out.by.site - 
# # out.by.time
# 
# #################################################################
# # rename things ease of comparisons
# catch.set          <- dat.set
# catch.site.by.time <- dat.site.by.time.avg
# catch.by.time      <- dat.skagit.avg
# catch.by.site      <- dat.site.avg
# 
# pcr.water        <- out.among.water
# pcr.site.by.time <- out.among.site.by.time
# pcr.by.time      <- out.by.time
# pcr.by.site      <- out.by.site
# 
# #3 Create consensus site name set
# catch.set$site.merge <- as.character(catch.set$Site)
# catch.site.by.time$site.merge <- as.character(catch.site.by.time$Site)
# catch.by.site$site.merge <- as.character(catch.by.site$Site)
# 
# pcr.water$site.merge <- as.character(pcr.water$site_name)
# pcr.site.by.time$site.merge <- as.character(pcr.site.by.time$site_name)
# pcr.by.site$site.merge <- as.character(pcr.by.site$site_name)
# 
# catch.set <- catch.set %>% mutate(site.merge= replace(site.merge,grepl("Turner",site.merge),"Turners")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Hoypus",site.merge),"Hoypus")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Straw",site.merge),"Strawberry")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Goat",site.merge),"Goat")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Dugualla",site.merge),"Dugualla")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Lone",site.merge),"Lone Tree")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Mariner",site.merge),"Mariners")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Brown",site.merge),"Brown")) 
# catch.site.by.time <- catch.site.by.time %>% mutate(site.merge= replace(site.merge,grepl("Turner",site.merge),"Turners")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Hoypus",site.merge),"Hoypus")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Straw",site.merge),"Strawberry")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Goat",site.merge),"Goat")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Dugualla",site.merge),"Dugualla")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Lone",site.merge),"Lone Tree")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Mariner",site.merge),"Mariners")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Brown",site.merge),"Brown")) 
# catch.by.site <- catch.by.site %>% mutate(site.merge= replace(site.merge,grepl("Turner",site.merge),"Turners")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Hoypus",site.merge),"Hoypus")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Straw",site.merge),"Strawberry")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Goat",site.merge),"Goat")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Dugualla",site.merge),"Dugualla")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Lone",site.merge),"Lone Tree")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Mariner",site.merge),"Mariners")) %>%
#                           mutate(site.merge= replace(site.merge,grepl("Brown",site.merge),"Brown")) 
# 
# pcr.water <- pcr.water %>% mutate(site.merge= replace(site.merge,grepl("Turner",site.merge),"Turners")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Hoypus",site.merge),"Hoypus")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Straw",site.merge),"Strawberry")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Goat",site.merge),"Goat")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Dugualla",site.merge),"Dugualla")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Lone",site.merge),"Lone Tree")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Mariner",site.merge),"Mariners")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Brown",site.merge),"Brown")) 
# pcr.site.by.time <- pcr.site.by.time %>% mutate(site.merge= replace(site.merge,grepl("Turner",site.merge),"Turners")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Hoypus",site.merge),"Hoypus")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Straw",site.merge),"Strawberry")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Goat",site.merge),"Goat")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Dugualla",site.merge),"Dugualla")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Lone",site.merge),"Lone Tree")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Mariner",site.merge),"Mariners")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Brown",site.merge),"Brown")) 
# pcr.by.site <- pcr.by.site %>% mutate(site.merge= replace(site.merge,grepl("Turner",site.merge),"Turners")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Hoypus",site.merge),"Hoypus")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Straw",site.merge),"Strawberry")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Goat",site.merge),"Goat")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Dugualla",site.merge),"Dugualla")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Lone",site.merge),"Lone Tree")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Mariner",site.merge),"Mariners")) %>%
#   mutate(site.merge= replace(site.merge,grepl("Brown",site.merge),"Brown")) 
# 
# ############### Finish naming conventions.
# 
# 
# ## Merge together sets and water samples.
# compare.site.by.time <- left_join(pcr.site.by.time %>% mutate(pcr.Mean =Mean,pcr.SD=SD,pcr.SE=SE) %>% as.data.frame() %>%
#                                       select(year,month,pcr.Mean,pcr.SD,pcr.SE,site.merge),
#                                   catch.site.by.time %>% mutate(catch.Mean = avg,catch.SD=SD) %>% filter(species.comb=="CK") %>%
#                                       select(year,month,catch.Mean,catch.SD,site.merge))
# 
# s.by.t <- list()  
# s.by.t[[1]] <- ggplot(compare.site.by.time,aes(x=catch.Mean,y=pcr.Mean,color=site.merge)) +
#         geom_point() +
#         geom_errorbar(aes(ymin=pcr.Mean-pcr.SD,ymax=pcr.Mean+pcr.SD),alpha=0.7,width=0.5) +
#         geom_errorbarh(aes(xmin=catch.Mean - catch.SD,xmax=catch.Mean+catch.SD),alpha=0.7,height=0.5) +
#         labs(y="DNA Concentration",x="Beach Seine Catch",color="Site") +
#         theme_bw()
# 
# s.by.t[[2]]<- ggplot(compare.site.by.time,aes(x=catch.Mean,y=pcr.Mean)) +
#   geom_point() +
#   geom_errorbar(aes(ymin=pcr.Mean-pcr.SD,ymax=pcr.Mean+pcr.SD),alpha=0.7,width=0.5) +
#   geom_errorbarh(aes(xmin=catch.Mean - catch.SD,xmax=catch.Mean+catch.SD),alpha=0.7,height=0.5) +
#   labs(y="DNA Concentration",x="Beach Seine Catch") +
#   theme_bw()+
#   facet_wrap(~site.merge,scales = "free")
# s.by.t[[2]]
# 
# ######## Merge pcr and catch by sample month
# compare.by.time <- left_join(pcr.by.time %>% mutate(pcr.Mean =Mean,pcr.SD=SD,pcr.SE=SE,N.pcr=N.site) %>% as.data.frame() %>%
#                                     select(year,month,N.pcr,pcr.Mean,pcr.SD,pcr.SE),
#                                   catch.by.time %>% mutate(catch.Mean = AVG,catch.SD=SD,catch.SE=SE,N.catch=N.catch) %>% filter(species.comb=="CK") %>%
#                                     select(year,month,N.catch,catch.Mean,catch.SD,catch.SE))
# 
# compare.time <- ggplot(compare.by.time %>% mutate(month=as.factor(month)),aes(x=catch.Mean,y=pcr.Mean,color=month)) +
#   geom_point() +
#   geom_errorbar(aes(ymin=pcr.Mean-pcr.SE,ymax=pcr.Mean+pcr.SE),alpha=0.7,width=0.5) +
#   geom_errorbarh(aes(xmin=catch.Mean - catch.SE,xmax=catch.Mean+catch.SE),alpha=0.7,height=0.5) +
#   labs(x="Beach Seine Catch", y= "DNA concentration") +
#   theme_bw()
# compare.time
# 
# cor.test(compare.by.time$pcr.Mean,compare.by.time$catch.Mean)
# 
# ######## Merge pcr and catch by sample site
# compare.by.site <- left_join(pcr.by.site %>% mutate(pcr.Mean =Mean,pcr.SD=SD,pcr.SE=SE,N.pcr=N.month) %>% as.data.frame() %>%
#                                select(year,site.merge,N.pcr,pcr.Mean,pcr.SD,pcr.SE),
#                              catch.by.site %>% mutate(catch.Mean = AVG,catch.SD=SD,catch.SE=SE,N.catch=N.catch) %>% filter(species.comb=="CK") %>%
#                                select(year,site.merge,N.catch,catch.Mean,catch.SD,catch.SE))
# 
# compare.site <- ggplot(compare.by.site ,aes(x=catch.Mean,y=pcr.Mean,color=site.merge)) +
#   geom_point() +
#   geom_errorbar(aes(ymin=pcr.Mean-pcr.SE,ymax=pcr.Mean+pcr.SE),alpha=0.7,width=0.5) +
#   geom_errorbarh(aes(xmin=catch.Mean - catch.SE,xmax=catch.Mean+catch.SE),alpha=0.7,height=0.5) +
#   lims(x=c(0,max(compare.by.site$catch.Mean+compare.by.site$catch.SE)),y=c(0,max(compare.by.site$pcr.Mean+compare.by.site$pcr.SE)))+
#   theme_bw()
# compare.site
# 
# cor.test(compare.by.site$pcr.Mean,compare.by.site$catch.Mean)
# 
# ####################################################################
# ## Plot Index of Abundance for both PCR and Catch
# ####################################################################
# 
# compare.index <- compare.by.time %>% mutate(pcr.ref = pcr.Mean[month==2],
#                                               pcr.index = pcr.Mean/pcr.ref,
#                                               pcr.index.sd=sqrt(pcr.SD^2 / pcr.ref^2),
#                                               pcr.index.se=pcr.index.sd/sqrt(N.pcr),
#                                               catch.ref= catch.Mean[month==2],
#                                               catch.index = catch.Mean/catch.ref,
#                                               catch.index.sd=sqrt(catch.SD^2 / catch.ref^2),
#                                               catch.index.se=catch.index.sd/sqrt(N.catch)
#                                               )
# 
# index.standardization <- ggplot(compare.index) +
#     geom_line(aes(y=pcr.index,x=month,color="qPCR"),size=1.5) +
#     geom_ribbon(aes(x=month,ymin=pcr.index-pcr.index.se,ymax=pcr.index+pcr.index.se),fill="red",alpha=0.3) +
#     geom_line(aes(y=catch.index,x=month,color ="Seine"),size=1.5) +
#     geom_ribbon(aes(x=month,ymin=catch.index-catch.index.se,ymax=catch.index+catch.index.se),fill="black",alpha=0.3) +
#     geom_hline(yintercept = 1,linetype=2) +
#     scale_color_manual(values=c("red","black")) +
# 
#     labs(y="Index", x="Month",color="Gear type")+
#     theme_bw()
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
# 
# 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # new <- data.frame(log.qbc = dat$log.qbc)
# # new.pred <- predict(mod,new,interval="prediction",se.fit=T)
# # new.fit <- data.frame(fit = new.pred$fit[,"fit"], se.fit =new.pred$se.fit)
# # 
# # dat <- cbind(dat,new.fit) %>% as.data.frame()
# # 
# # 
# # #######################################################################################
# # ## -- Summarize the qPCR results relative to the available water samples.
# # #######################################################################################
# # 
# # # Key points. Grouping variable in "lab_label" in the water sample file ("water") and "template_name" in the qPCR file.
# # 
# # dat.summ <- dat %>% dplyr::select(template_name,template_rep) %>% group_by(template_name) %>% summarize(n.rep=length(template_name))
# # samp.run <- left_join(water,dat.summ,by=c("lab_label"="template_name"))
# # 
# # temp <- samp.run %>% filter(is.na(n.rep)==F) %>% group_by(site_name, date) %>% summarize(samp = length(n.rep)) %>%
# #           dcast(.,date~site_name,value.var=c("samp")) %>% as.data.frame()
# # 
# # samp.run %>% filter(site_name %in% c("Mariners Bluff","Brown Point","Dugualla Bluff")) %>% select(date,site_name,n.rep,lab_label)
# # 
