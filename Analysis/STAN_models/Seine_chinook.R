##3 EXAMINE OUTPUT FROM QPCR of Skagit 2018 

rm(list=ls())
library(ggplot2)
library(reshape2)
library(dplyr)
library(rstan)
library(gtools)
library(MASS)
library(fields)
library(RColorBrewer)
library(viridis)
library(extrafont)
### Make diagnostic and exploratory plots for model objects

base.dir    <- "/Users/ole.shelton/GitHub/Skagit_Salmon_eDNA"
results.dir <- "/Users/ole.shelton/GitHub/Skagit_Salmon_eDNA/Analysis/STAN_models/Output files/Model Fits"
#code.dir    <- "/Users/ole.shelton/GitHub/Salmon-Climate/Mixed model post processing"
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())


# Load catch information from seines
setwd(base.dir)
source("./Analysis/catch analysis/parse catch data.R")

dat.set.chin <- dat.set %>% filter(species.comb == "CK")
# Make site names identical to the qPCR names
dat.set.chin$Site <- recode(dat.set.chin$Site,"Turners Spit N" = "Turners Spit N",    
                            "Hoypus Pt E" = "Hoypus",
                            "Lone Tree Pt" = "Lone Tree Point",
                            "Dugualla Bluff" ="Dugualla Bluff",
                            "Goat Is" = "Goat Island",
                            "Strawberry Pt N" = "Strawberry Point North",
                            "Mariners Bluff" = "Mariners Bluff",
                            "Brown Point (X)" = "Brown Point")

SITE_MONTH_seine <- dat.set.chin %>% group_by(Site,month,species.comb) %>% summarise(sum(total)) %>% as.data.frame()

SITE_MONTH_seine$site_month_idx <- 1:nrow(SITE_MONTH_seine)

N_site_month <- nrow(SITE_MONTH_seine)
N_site <- length(unique(SITE_MONTH_seine$Site))
N_month <- length(unique(SITE_MONTH_seine$month))

dat.set.chin <- left_join(dat.set.chin,SITE_MONTH_seine %>% dplyr::select(Site,month,site_month_idx),by=c("Site","month"))
N_seine <- nrow(dat.set.chin)

##################################################################
#### MAKE DATA FOR STAN
##################################################################

stan_data = list(
  # Chinook
  "count_set"   = dat.set.chin$total, 

  # Indices and counters
  "N_site"   = N_site,   # Number of Sites
  "N_month"  = N_month,  # Number of months observed
  "N_site_month" = N_site_month,
  "N_seine" = N_seine,
  "site_month_idx" = dat.set.chin$site_month_idx
)

stan_pars = c(
  "psi", # intercept for standards
  "tau_seine" # overdispersion
)   


### Fitt 
N_CHAIN = 5
Warm = 5000
Iter = 10000
Treedepth = 10
Adapt_delta = 0.80

setwd(base.dir)
stanMod = stan(file = './Analysis/STAN_models/Seine_chinook.stan',data = stan_data, 
               verbose = FALSE, chains = N_CHAIN, thin = 5, 
               warmup = Warm, iter = Warm + Iter, 
               control = list(max_treedepth=Treedepth,adapt_delta=Adapt_delta,metric="diag_e"),
               pars = stan_pars,
               boost_lib = NULL,
               #sample_file = "./Analysis/STAN_models/Output files/test seine.csv")
               # init = stan_init_f1(n.chain=N_CHAIN,
               #                     N_site_month = N_site_month
               #))

################################################################ 

pars <- rstan::extract(stanMod, permuted = TRUE)
# get_adaptation_info(stanMod)
samp_params <- get_sampler_params(stanMod)
#samp_params 
stanMod_summary <- summary(stanMod)$summary
round(stanMod_summary,2)

base_params <- c(
  "psi",
  "tau_seine"   # variability among bottles, given site, and month
) 

##### MAKE SOME DIAGNOSTIC PLOTS

print(traceplot(stanMod,pars=c("lp__",base_params),inc_warmup=FALSE))

######################################
######################################

SITE_MONTH_seine <- SITE_MONTH_seine %>% rename(site_name=Site)

site.month.out <- data.frame(site_month_idx= 1:ncol(pars$psi), Mean=apply(pars$psi,2,mean),
                             Sd=apply(pars$psi,2,sd),
                             data.frame(t(apply(pars$psi,2,quantile,probs=c(0.025,0.05,0.10,0.25,0.5,0.75,0.9,0.95,0.975)))))

SITE_MONTH_seine_summary <- left_join(SITE_MONTH_seine,site.month.out,by="site_month_idx") %>% group_by(site_name,month) %>%
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

lims <- c(min(SITE_MONTH_seine_summary$MEAN),max(SITE_MONTH_seine_summary$MEAN))
lims <- seq(lims[1],lims[2],length.out=1000)
exp.lims <-exp(lims)

temp <- t(exp.lims + exp.lims^2 %*% t(pars$tau_seine))

var.seine <-data.frame(psi=exp.lims,
              var.mean= apply(temp,2,mean),
              var.sd= apply(temp,2,sd),
              t(apply(temp,2,quantile,probs=c(0.025,0.05,0.25,0.50,0.75,0.95,0.975))) %>% as.data.frame() ) %>%
              rename( q.025= X2.5.,
                    q.05 = X5.,
                    q.25 = X25.,
                    Median=  X50.,
                    q.75 = X75.,
                    q.95 = X95.,
                    q.975= X97.5.)

#########################################

Output.seine <- list(stanMod = stanMod, stanMod_summary = stanMod_summary,samp = pars, samp_params=samp_params,
                    dat.set.chin = dat.set.chin, 
                    base_params =base_params,
                    SITE_MONTH_seine = SITE_MONTH_seine, SITE_MONTH_seine_summary = SITE_MONTH_seine_summary,
                    N_site   = N_site,   # Number of Sites
                    N_month  = N_month,  # Number of months observed
                    var.seine = var.seine
)


setwd("./Analysis/STAN_models/Output files/Model Fits")
save(Output.seine,file="Seine Skagit 2017 Fitted.RData")










  