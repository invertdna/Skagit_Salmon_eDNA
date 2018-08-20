###### PARSE Model output for qPCR and Seine surveys.
###### Make plots of:
      # pairwise comparisons, 
      # index for entire bay,
      # variance partitioning
      # correlation among sites and with pairwise distance

library(geosphere)
library(ggplot2)
library(dplyr)
library(gridExtra)
library(reshape2)
library(viridis)

rm(list=ls())
# Load up results from qPCR
base.dir <- "/Users/ole.shelton/GitHub/Skagit_Salmon_eDNA"
results.dir <- "./Analysis/STAN_Models/Output Files/Model Fits"
plot.dir <- "./Figures/Exploratory"

setwd(base.dir)
setwd(results.dir)
load("qPCR Skagit 2017 Fitted.RData")
load("Seine Skagit 2017 Fitted.RData")


### Create list that can be written to file and accessed automatically to include results in the R markdown file
Output.rmarkdown <- list()
########################################################################################
#############
# Work with qPCR output first
samp <- Output.qpcr$samp
samp.seine <- Output.seine$samp

### Work with output to look at 
## The summary file of log-DNA density at each site-month combination is SITE_MONTH_summary
SITE_MONTH <- Output.qpcr$SITE_MONTH
BOTTLES    <- Output.qpcr$BOTTLES
SITE_MONTH_summary <- Output.qpcr$SITE_MONTH_summary
BOTTLES_summary <- Output.qpcr$BOTTLES_summary

SITE_MONTH_seine <- Output.seine$SITE_MONTH_seine
SITE_MONTH_seine_summary <- Output.seine$SITE_MONTH_seine_summary

N_site <- Output.qpcr$N_site
N_month <- Output.qpcr$N_month

# Calculate distance between sites.
n.to.s <- c(
  "Turners Spit N",    
  "Hoypus",
  "Lone Tree Point",
  "Dugualla Bluff",
  "Goat Island",
  "Strawberry Point North",
  "Mariners Bluff",
  "Brown Point")

setwd(base.dir)
lat.lon <- read.csv("./Data/sites.csv")
lat.lon <- lat.lon %>% filter(net=="seine",revisit=="index",is.na(lat)==F,site_name!="Wylie Boat Ramp")

dist.km <- distm(lat.lon %>% dplyr::select(lon,lat),fun=distVincentyEllipsoid) / 1000
#dist.km <- lower.tri(dist.km,diag=T) * dist.km
rownames(dist.km) <- lat.lon$site_name
colnames(dist.km) <- lat.lon$site_name

dist.km.long <- melt(dist.km) %>% rename(site.1=Var1,site.2=Var2,dist.km=value)  


#################################################################
########################## PLOTS pairwise corr
#################################################################
corr.mean.tile.qpcr <- ggplot(corr.summary ) +
    geom_tile(aes(x=site.2,y=site.1,fill=mean.corr),alpha=0.8) +
    
    scale_fill_gradient2(name="Correlation",
              low = "blue", mid = grey(0.8),high = "red", midpoint = 0, space = "Lab",
              na.value = "black", guide = "colourbar",
              limits=c(-1,1)) +
    ggtitle("qPCR mean corr") +
    theme_bw() +
     theme(axis.text.x = element_text(angle = 90, hjust = 1)) 

corr.sd.tile.qpcr <- ggplot(corr.summary ) +
  geom_tile(aes(x=site.2,y=site.1,fill=sd.corr),alpha=0.8) +
  
  scale_fill_gradient2(name="SD Correlation",
                       low = "white",mid="blue", high = "red", space = "Lab",
                       na.value = "black", guide = "colourbar",
                       limits=c(0,1)) +
  ggtitle("qPCR sd corr") +
  theme_bw() 

### seine  
corr.mean.tile.seine <- ggplot(corr.summary.seine ) +
  geom_tile(aes(x=site.2,y=site.1,fill=mean.corr),alpha=0.8) +
  scale_fill_gradient2(name="Correlation",
                       low = "blue", mid = grey(0.8),high = "red", midpoint = 0, space = "Lab",
                       na.value = "black", guide = "colourbar",
                       limits=c(-1,1)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ggtitle("Seine mean corr") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) 

corr.sd.tile.seine <- ggplot(corr.summary.seine ) +
  geom_tile(aes(x=site.2,y=site.1,fill=sd.corr),alpha=0.8) +
  scale_fill_gradient2(name="SD Correlation",
                       low = "white",mid="blue", high = "red", space = "Lab",
                       na.value = "black", guide = "colourbar",
                       limits=c(0,1)) +
  ggtitle("Seine sd corr") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) 

setwd(base.dir)
setwd(plot.dir)
pdf("correlations.pdf",width=8,height=7)
  print(corr.mean.tile.qpcr)
  print(corr.mean.tile.seine)
dev.off()

#################################################################
########################## PLOTS of qPCR vs. Seine
#################################################################  
  
# Log scale (log_e vs. log 10) - this is the scale at which the models are fit.

A <- melt(SITE_MONTH_summary,id.var=c("site_name","month"),value.name="qpcr")
B <- melt(SITE_MONTH_seine_summary,id.var=c("site_name","month"),value.name="seine")

A.mean.median <- A %>% filter(variable %in% c("MEAN","Median"))
A.quant.05    <-   A %>% filter(variable %in% c("q.05")) %>% dplyr::select(-variable) %>% rename(q.05.qpcr=qpcr)
A.mean.median <-   A %>% filter(variable %in% c("q.95")) %>% dplyr::select(-variable) %>% rename(q.95.qpcr=qpcr) %>% 
                      full_join(.,A.quant.05) %>%
                      full_join(A.mean.median,.)

B.mean.median <-  B %>% filter(variable %in% c("MEAN","Median"))
B.quant.05    <-   B %>% filter(variable %in% c("q.05")) %>% dplyr::select(-variable) %>% rename(q.05.seine=seine)
B.mean.median <-   B %>% filter(variable %in% c("q.95")) %>% dplyr::select(-variable) %>% rename(q.95.seine=seine) %>% 
  full_join(.,B.quant.05) %>%
  full_join(B.mean.median,.)

compare_site <- full_join(A.mean.median,B.mean.median,by=c("site_name","month","variable"))
compare_site <- compare_site %>% mutate(qpcr.ident=10^qpcr,qpcr.ident.q.05=10^q.05.qpcr,qpcr.ident.q.95=10^q.95.qpcr,
                                        seine.ident=exp(seine),seine.ident.q.05=exp(q.05.seine),seine.ident.q.95=exp(q.95.seine))


pairwise.log <- ggplot() +
    geom_point(data=compare_site %>% filter(variable=="MEAN"),aes(x=seine,y=qpcr,color=site_name)) + 
    scale_color_discrete(name="Site") +
    geom_errorbar(data=compare_site %>% filter(variable=="MEAN"),aes(x=seine,ymin=q.05.qpcr,ymax=q.95.qpcr,color=site_name)) +
    geom_errorbarh(data=compare_site %>% filter(variable=="MEAN"),aes(x=seine,xmin=q.05.seine,xmax=q.95.seine,y=qpcr,color=site_name)) +  
    xlab(expression(log["e"]*"(Expected Seine Catch)")) +
    ylab(expression(log["10"]*"(Chinook DNA concentration)")) +
    theme_bw()


pairwise.ident <- ggplot() +
  geom_point(data=compare_site %>% filter(variable=="MEAN"),aes(x=seine.ident,y=qpcr.ident,color=site_name)) +
  geom_errorbar(data=compare_site %>% filter(variable=="MEAN"),
                aes(x=seine.ident,ymin=qpcr.ident.q.05,ymax=qpcr.ident.q.95,color=site_name)) +
  geom_errorbarh(data=compare_site %>% filter(variable=="MEAN"),
                 aes(x=seine.ident,xmin=seine.ident.q.05,xmax=seine.ident.q.95,y=qpcr.ident,color=site_name)) +  
  xlab(expression("Expected Seine Catch")) +
  ylab(expression("DNA Density")) +
  theme_bw()

pairwise.log.facet <- ggplot() +
  geom_point(data=compare_site %>% filter(variable=="MEAN"),aes(x=seine,y=qpcr,color=site_name)) +
  geom_errorbar(data=compare_site %>% filter(variable=="MEAN"),aes(x=seine,ymin=q.05.qpcr,ymax=q.95.qpcr,color=site_name)) +
  geom_errorbarh(data=compare_site %>% filter(variable=="MEAN"),aes(x=seine,xmin=q.05.seine,xmax=q.95.seine,y=qpcr,color=site_name)) +  
  xlab(expression(log["e"]*"Seine")) +
  ylab(expression(log["10"]*"DNA")) +
  facet_wrap(~site_name) +
  theme_bw()

pairwise.ident.facet <- ggplot() +
    geom_point(data=compare_site %>% filter(variable=="MEAN"),aes(x=seine.ident,y=qpcr.ident,color=site_name)) +
    geom_errorbar(data=compare_site %>% filter(variable=="MEAN"),
                  aes(x=seine.ident,ymin=qpcr.ident.q.05,ymax=qpcr.ident.q.95,color=site_name)) +
    geom_errorbarh(data=compare_site %>% filter(variable=="MEAN"),
                   aes(x=seine.ident,xmin=seine.ident.q.05,xmax=seine.ident.q.95,y=qpcr.ident,color=site_name)) +  
    xlab(expression("Expected Seine Catch")) +
    ylab(expression("DNA Density")) +
    facet_wrap(~site_name) +  
    theme_bw()

setwd(base.dir)
setwd(plot.dir)
pdf("pairwise by site.pdf",width=7,height=5)
  print(pairwise.log)
  print(pairwise.log.facet)
  print(pairwise.ident)
  print(pairwise.ident.facet)
dev.off()

#3 Pub Figures
pairwise.log.bw <- ggplot() +
  geom_point(data=compare_site %>% filter(variable=="MEAN"),aes(x=seine,y=qpcr),pch=21,size=2,stroke=1.1) + 
  scale_color_discrete(name="Site") +
  geom_errorbar(data=compare_site %>% filter(variable=="MEAN"),aes(x=seine,ymin=q.05.qpcr,ymax=q.95.qpcr),lwd=0.5) +
  geom_errorbarh(data=compare_site %>% filter(variable=="MEAN"),aes(x=seine,xmin=q.05.seine,xmax=q.95.seine,y=qpcr),lwd=0.5) +  
  xlab(expression(log["e"]*"(Expected Seine Catch)")) +
  ylab(expression(log["10"]*"(Chinook DNA concentration)")) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())


pairwise.log.facet <- ggplot() +
  geom_point(data=compare_site %>% filter(variable=="MEAN"),aes(x=seine,y=qpcr),pch=21,size=1.5,stroke=0.75) +
  geom_errorbar(data=compare_site %>% filter(variable=="MEAN"),aes(x=seine,ymin=q.05.qpcr,ymax=q.95.qpcr),lwd=0.5) +
  geom_errorbarh(data=compare_site %>% filter(variable=="MEAN"),aes(x=seine,xmin=q.05.seine,xmax=q.95.seine,y=qpcr),lwd=0.5) +  
  xlab(expression(log["e"]*"Seine")) +
  ylab(expression(log["10"]*"DNA")) +
  facet_wrap(~site_name) +
  xlab(expression(log["e"]*"(Expected Seine Catch)")) +
  ylab(expression(log["10"]*"(Chinook DNA concentration)")) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

setwd(base.dir)
setwd(plot.dir)
quartz(file="../Pub Figs/Fig pairwise log b-w.jpeg",width=5,height=4.75,type="jpeg",dpi=1200)
  print(pairwise.log.bw)
dev.off()

quartz(file="../Pub Figs/Fig pairwise log b-w facet.jpeg",width=5,height=4.75,type="jpeg",dpi=1200)
  print(pairwise.log.facet)
dev.off()


# Statistics to include in Output.rmarkdown

Output.rmarkdown <- list(Output.rmarkdown,
                         qpcr.seine.site.month.pair.corr = cor.test(compare_site$qpcr,compare_site$seine)
                      )

#############################################################################
#### INDEX COMPARISONS
#############################################################################

## qPCR
gamma.ident  <- 10^(samp$gamma)

N.samp <- nrow(samp$gamma)
THESE  <- seq(5,N.samp,by=5)

temp <- t(gamma.ident) %>% as.data.frame() %>% dplyr::select(c(THESE)) %>%
  mutate(site_month_idx=1:nrow(.)) %>% 
  full_join(SITE_MONTH %>% dplyr::select(site_name,month,site_month_idx),.,by = "site_month_idx")
temp$site_name <- factor(temp$site_name,levels=n.to.s)

out <- melt(temp,id.vars =c("site_name","month"),measure.vars = names(temp)[grep("V",names(temp))])

qpcr.index.iter <- out %>% group_by(month,variable) %>% summarize(qpcr.mean = mean(value))
qpcr.index      <- qpcr.index.iter %>% group_by(month) %>% 
                        summarize(qpcr.month.mean = mean(qpcr.mean),
                                  qpcr.month.sd = sd(qpcr.mean),
                                  qpcr.month.median = median(qpcr.mean),
                                  qpcr.month.q.025 = quantile(qpcr.mean,probs=0.025),
                                  qpcr.month.q.05 = quantile(qpcr.mean,probs=0.05),
                                  qpcr.month.q.25 = quantile(qpcr.mean,probs=0.25),
                                  qpcr.month.q.75 = quantile(qpcr.mean,probs=0.75),
                                  qpcr.month.q.95 = quantile(qpcr.mean,probs=0.95),
                                  qpcr.month.q.975 = quantile(qpcr.mean,probs=0.975)
                                  )
## SEINE
psi.ident    <- exp(samp.seine$psi)

N.samp <- nrow(samp.seine$psi)
THESE  <- seq(2,N.samp,by=2)

temp <- t(psi.ident) %>% as.data.frame() %>% dplyr::select(c(THESE)) %>%
  mutate(site_month_idx=1:nrow(.)) %>% 
  full_join(SITE_MONTH_seine %>% dplyr::select(site_name,month,site_month_idx),.,by = "site_month_idx")
temp$site_name <- factor(temp$site_name,levels=n.to.s)

out <- melt(temp,id.vars =c("site_name","month"),measure.vars = names(temp)[grep("V",names(temp))])


seine.index.iter <- out %>% group_by(month,variable) %>% summarize(seine.mean = mean(value))
seine.index      <- seine.index.iter %>% group_by(month) %>% 
  summarize(seine.month.mean = mean(seine.mean),
            seine.month.sd = sd(seine.mean),
            seine.month.median = median(seine.mean),
            seine.month.q.025 = quantile(seine.mean,probs=0.025),
            seine.month.q.05 = quantile(seine.mean,probs=0.05),
            seine.month.q.25 = quantile(seine.mean,probs=0.25),
            seine.month.q.75 = quantile(seine.mean,probs=0.75),
            seine.month.q.95 = quantile(seine.mean,probs=0.95),
            seine.month.q.975 = quantile(seine.mean,probs=0.975)
  )

index_seine_plot <- ggplot(seine.index) +
  geom_ribbon(aes(x=month,ymin=seine.month.q.05,ymax=seine.month.q.95),fill=grey(0.5),alpha=0.5) +
  geom_line(aes(x=month,y=seine.month.mean),col="black",lwd=1.5)+
  geom_hline(yintercept = 1)
  ggtitle("Seine") +
  ylab("Among Site Mean (Expected Count)") +
  theme_bw()
    
index_qpcr_plot <- ggplot(qpcr.index) +
  geom_ribbon(aes(x=month,ymin=qpcr.month.q.05,ymax=qpcr.month.q.95),fill="red",alpha=0.5) +
  geom_line(aes(x=month,y=qpcr.month.mean),col="red",lwd=1.5) +
  ggtitle("DNA") +
  ylab("Among Site Mean (DNA concentration)") +
  theme_bw()

##Standardized to february value

seine.index.stand <- seine.index %>% dplyr::select(-month)
seine.index.stand <- seine.index.stand / seine.index$seine.month.mean[seine.index$month==2]
seine.index.stand <- data.frame(month=seine.index$month,seine.index.stand)

qpcr.index.stand <- qpcr.index %>% dplyr::select(-month)
qpcr.index.stand <- qpcr.index.stand / qpcr.index$qpcr.month.mean[qpcr.index$month==2]
qpcr.index.stand <- data.frame(month=qpcr.index$month,qpcr.index.stand)

A <- seine.index.stand %>% dplyr::select(month,seine.month.mean,seine.month.q.025,seine.month.q.05,seine.month.q.95,seine.month.q.975) %>%
        mutate(type="Beach seine") %>% rename(Mean=seine.month.mean,q.025=seine.month.q.025,q.05=seine.month.q.05,q.95=seine.month.q.95,q.975=seine.month.q.975)
B <- qpcr.index.stand %>% dplyr::select(month,qpcr.month.mean,qpcr.month.q.025,qpcr.month.q.05,qpcr.month.q.95,qpcr.month.q.975) %>%
        mutate(type="qPCR") %>% rename(Mean=qpcr.month.mean,q.025=qpcr.month.q.025,q.05=qpcr.month.q.05,q.95=qpcr.month.q.95,q.975=qpcr.month.q.975)

both.index <- rbind(A,B) %>% as.data.frame()

COL = viridis(2,begin=0.1,end=0.5)

index.stand.plot.ts <- ggplot() +
        geom_ribbon(data=both.index, aes(x=month,ymin=q.05,ymax=q.95,fill=type),alpha=0.5) +
        geom_line(data=both.index, aes(x=month,y=Mean,linetype=type),lwd=1.25)+
        scale_fill_manual(name="Survey",values=COL) +
        scale_linetype_manual(name="Survey",values=c(1,4)) +
        geom_hline(yintercept = 1,linetype=2) +
        expand_limits(y=0)+
        scale_y_continuous(expand=c(0,0))+
        xlab("Month") +
        ylab("Index of abundance") +
        theme_bw() +
        theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),panel.border = element_rect(size=0.8),
              legend.position=c(0.15,0.85))


pair.index <- full_join(
                    qpcr.index %>% dplyr::select(c("month","qpcr.month.mean","qpcr.month.median","qpcr.month.q.05","qpcr.month.q.95")),
                    seine.index %>% dplyr::select(c("month","seine.month.mean","seine.month.median","seine.month.q.05","seine.month.q.95"))
                    )
pair.index.stand <- full_join(
                  qpcr.index.stand %>% dplyr::select(c("month","qpcr.month.mean","qpcr.month.median","qpcr.month.q.05","qpcr.month.q.95")),
                  seine.index.stand %>% dplyr::select(c("month","seine.month.mean","seine.month.median","seine.month.q.05","seine.month.q.95"))
                  )

index.pairwise <- ggplot(pair.index) +
            geom_point(aes(x=seine.month.mean,y=qpcr.month.mean)) +
            geom_errorbar(aes(x=seine.month.mean,ymin=qpcr.month.q.05,ymax=qpcr.month.q.95)) +
            geom_errorbarh(aes(x=seine.month.mean,y=qpcr.month.mean,xmin=seine.month.q.05,xmax=seine.month.q.95)) +
            xlab("Seine, raw") +
            ylab("DNA, raw") +
            theme_bw()

x.max <- max(pair.index.stand$seine.month.q.95) *1.02
y.max <- max(pair.index.stand$qpcr.month.q.95)*1.02
index.pairwise.stand  <- ggplot(pair.index.stand) +
            geom_point(aes(x=seine.month.mean,y=qpcr.month.mean),pch=21,stroke=0.75,size=2) +
            geom_errorbar(aes(x=seine.month.mean,ymin=qpcr.month.q.05,ymax=qpcr.month.q.95)) +
            geom_errorbarh(aes(x=seine.month.mean,y=qpcr.month.mean,xmin=seine.month.q.05,xmax=seine.month.q.95)) +
            xlab("Beach seine index") +
            ylab("qPCR index") +
            #  geom_abline(slope=0.5 , intercept=0)
            expand_limits(y=0,x=0)+
            scale_x_continuous(expand=c(0,0),limits=c(0,x.max))+
            scale_y_continuous(expand=c(0,0),limits=c(0,y.max ),breaks = c(0,3,6,9,12))+
            theme_bw() +
            theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),panel.border = element_rect(size=0.8))
      
setwd(base.dir)
setwd(plot.dir)
pdf("Indices of abundance.pdf",width=7,height=5)
  print(index_seine_plot)
  print(index_qpcr_plot)
  print(index.stand.plot.ts)
  print(index.pairwise)
  print(index.pairwise.stand)
dev.off()

gA <- ggplotGrob(index.stand.plot.ts)
gB <- ggplotGrob(index.pairwise.stand)
maxWidth = grid::unit.pmax(gA$widths[2:5], gB$widths[2:5])
gA$widths[2:5] <- as.list(maxWidth)
gB$widths[2:5] <- as.list(maxWidth)


##3 FIGURE FOR PUB
quartz(file="../Pub Figs/Fig index plots.jpeg",width=5,height=7,type="jpeg",dpi=1200)
  grid.arrange(gA, gB, nrow=2)
dev.off()


Output.rmarkdown = list(Output.rmarkdown,
                        qpcr.seine.index.cor = cor.test(pair.index.stand$qpcr.month.mean,pair.index.stand$seine.month.mean))
  

#######################################################################
### PLOT VARIANCE OF DIFFERENT COMPONENTS FOR qPCR
#######################################################################

# All in units of log_10 Density
# A <- data.frame(type="sd.among.standard.pcr", SD=Output.qpcr$sd.among.pcr.stand)
# B <- data.frame(type="sd.among.samp.pcr",SD=Output.qpcr$sd.among.pcr.samp)
# C <- data.frame(type="sd.among.bottles", Output.qpcr$sd.among.bottles)
# D <- data.frame(type="sd.among.time.given.site", Output.qpcr$sd.among.time.given.site)
# E <- data.frame(type="sd.among.site.given.time", Output.qpcr$sd.among.site.given.time)

sd.among.pcr.stand = Output.qpcr$sd.among.pcr.stand
sd.among.pcr.samp  = Output.qpcr$sd.among.pcr.samp
sd.among.pcr       = Output.qpcr$sd.among.pcr
sd.among.bottles   = Output.qpcr$sd.among.bottles
sd.among.time.given.site = Output.qpcr$sd.among.time.given.site
sd.among.site.given.time = Output.qpcr$sd.among.site.given.time







tot.sd.pcr <- rbind(A,B)
tot.sd.pcr <- rbind(tot.sd.pcr,C %>% dplyr::select(type,SD))
tot.sd.pcr <- rbind(tot.sd.pcr,D %>% dplyr::select(type,SD))
tot.sd.pcr <- rbind(tot.sd.pcr,E %>% dplyr::select(type,SD))

#######################################################################


########################################################################################
### Calculate pairwise correlations among sites across months using the raw MCMC samples
## QPCR first (log 10 scale)
########################################################################################
N.samp <- nrow(samp$gamma)
THESE  <- seq(5,N.samp,by=5)

temp <- t(samp$gamma) %>% as.data.frame() %>% dplyr::select(c(THESE)) %>%
  mutate(site_month_idx=1:nrow(.)) %>% 
  full_join(SITE_MONTH %>% dplyr::select(site_name,month,site_month_idx),.,by = "site_month_idx")
temp$site_name <- factor(temp$site_name,levels=n.to.s)

THESE.col <-  grep("V",names(temp))

CORR.raw <- array(0,dim=c(N_site,N_site,length(THESE)))
COV.raw <- array(0,dim=c(N_site,N_site,length(THESE)))
L.T <- lower.tri(CORR.raw[,,1]) 
diag(L.T) <- 1

for(i in 1:length(THESE)){
  CORR.raw[,,i] <- dcast(data=temp,month~site_name,value.var=names(temp)[THESE.col[i]]) %>% 
    dplyr::select(-month) %>%
    cor(.,use="complete.obs") * L.T
  COV.raw[,,i] <- dcast(data=temp,month~site_name,value.var=names(temp)[THESE.col[i]]) %>% 
    dplyr::select(-month) %>%
    cov(.,use="complete.obs") * L.T
  
  if(i %in% seq(1000,length(THESE),by=1000)){print(paste(i," of ",length(THESE)))}
}  
nom <- colnames(dcast(data=temp,month~site_name,value.var=names(temp)[THESE.col[1]]) %>% dplyr::select(-month))
CORR.mean <- apply(CORR.raw,c(1,2),mean) 
CORR.sd   <- apply(CORR.raw,c(1,2),sd)
CORR.quant<- apply(CORR.raw,c(1,2),quantile,probs=c(0.025,0.05,0.95,0.975))
colnames(CORR.mean) = nom; rownames(CORR.mean) = nom
colnames(CORR.sd) = nom;   rownames(CORR.sd) = nom
dimnames(CORR.quant) <-list(c("q.025","q.05","q.95","q.975"),nom,nom)

COV.mean <- apply(COV.raw,c(1,2),mean) 
COV.sd   <- apply(COV.raw,c(1,2),sd)
COV.quant<- apply(COV.raw,c(1,2),quantile,probs=c(0.025,0.05,0.95,0.975))
colnames(COV.mean) = nom; rownames(COV.mean) = nom
colnames(COV.sd) = nom;   rownames(COV.sd) = nom
dimnames(COV.quant) <-list(c("q.025","q.05","q.95","q.975"),nom,nom)

#3 CALCULATE PAIRWISE DISTANCES  

corr.summary <-  melt(CORR.mean,value.name="mean.corr") %>% left_join(.,melt(CORR.sd,value.name="sd.corr")) %>%
  left_join(.,melt(CORR.quant[1,,],value.name="q.025")) %>%
  left_join(.,melt(CORR.quant[2,,],value.name="q.05")) %>%
  left_join(.,melt(CORR.quant[3,,],value.name="q.095")) %>%
  left_join(.,melt(CORR.quant[4,,],value.name="q.0975")) %>%
  rename(site.1=Var1,site.2=Var2) %>%
  left_join(., dist.km.long) %>%
  filter(mean.corr!=0) 
corr.summary$site.1 <- factor(corr.summary$site.1,levels=n.to.s)
corr.summary$site.2 <- factor(corr.summary$site.2,levels=n.to.s)
corr.summary$mean.corr[corr.summary$mean.corr ==1 ] <- NA

cov.summary <-  melt(COV.mean,value.name="mean.cov") %>% left_join(.,melt(COV.sd,value.name="sd.cov")) %>%
  left_join(.,melt(COV.quant[1,,],value.name="q.025")) %>%
  left_join(.,melt(COV.quant[2,,],value.name="q.05")) %>%
  left_join(.,melt(COV.quant[3,,],value.name="q.095")) %>%
  left_join(.,melt(COV.quant[4,,],value.name="q.0975")) %>%
  rename(site.1=Var1,site.2=Var2) %>%
  left_join(., dist.km.long) %>%
  filter(mean.cov !=0)

par(mfrow=c(2,1))
plot(mean.corr~dist.km,data=corr.summary %>% filter(dist.km>0),ylim=c(-1,1))#title="DNA")


########################################################################################
### Calculate pairwise correlations among sites across months using the raw MCMC samples
## Seine second first (log e scale)
########################################################################################
N.samp <- nrow(samp.seine$psi)
THESE  <- seq(2,N.samp,by=2)

temp <- t(samp.seine$psi) %>% as.data.frame() %>% dplyr::select(c(THESE)) %>%
  mutate(site_month_idx=1:nrow(.)) %>% 
  full_join(SITE_MONTH_seine %>% dplyr::select(site_name,month,site_month_idx),.,by = "site_month_idx")
temp$site_name <- factor(temp$site_name,levels=n.to.s)

THESE.col <-  grep("V",names(temp))

CORR.raw <- array(0,dim=c(N_site,N_site,length(THESE)))
COV.raw <- array(0,dim=c(N_site,N_site,length(THESE)))
L.T <- lower.tri(CORR.raw[,,1]) 
diag(L.T) <- 1

for(i in 1:length(THESE)){
  CORR.raw[,,i] <- dcast(data=temp,month~site_name,value.var=names(temp)[THESE.col[i]]) %>% 
    dplyr::select(-month) %>%
    cor(.,use="complete.obs") * L.T
  COV.raw[,,i] <- dcast(data=temp,month~site_name,value.var=names(temp)[THESE.col[i]]) %>% 
    dplyr::select(-month) %>%
    cov(.,use="complete.obs") * L.T
  
  if(i %in% seq(1000,length(THESE),by=1000)){print(paste(i," of ",length(THESE)))}
}  
nom <- colnames(dcast(data=temp,month~site_name,value.var=names(temp)[THESE.col[1]]) %>% dplyr::select(-month))
CORR.mean.seine <- apply(CORR.raw,c(1,2),mean) 
CORR.sd.seine   <- apply(CORR.raw,c(1,2),sd)
CORR.quant.seine <- apply(CORR.raw,c(1,2),quantile,probs=c(0.025,0.05,0.95,0.975))
colnames(CORR.mean.seine) = nom; rownames(CORR.mean.seine) = nom
colnames(CORR.sd.seine) = nom;   rownames(CORR.sd.seine) = nom
dimnames(CORR.quant.seine) <-list(c("q.025","q.05","q.95","q.975"),nom,nom)

COV.mean.seine <- apply(COV.raw,c(1,2),mean) 
COV.sd.seine   <- apply(COV.raw,c(1,2),sd)
COV.quant.seine<- apply(COV.raw,c(1,2),quantile,probs=c(0.025,0.05,0.95,0.975))
colnames(COV.mean.seine) = nom; rownames(COV.mean.seine) = nom
colnames(COV.sd.seine) = nom;   rownames(COV.sd.seine) = nom
dimnames(COV.quant.seine) <-list(c("q.025","q.05","q.95","q.975"),nom,nom)

#3 CALCULATE PAIRWISE DISTANCES  
corr.summary.seine <-  melt(CORR.mean.seine,value.name="mean.corr") %>% left_join(.,melt(CORR.sd.seine,value.name="sd.corr")) %>%
  left_join(.,melt(CORR.quant.seine[1,,],value.name="q.025")) %>%
  left_join(.,melt(CORR.quant.seine[2,,],value.name="q.05")) %>%
  left_join(.,melt(CORR.quant.seine[3,,],value.name="q.095")) %>%
  left_join(.,melt(CORR.quant.seine[4,,],value.name="q.0975")) %>%
  rename(site.1=Var1,site.2=Var2) %>%
  left_join(., dist.km.long) %>%
  filter(mean.corr!=0) 
corr.summary.seine$site.1 <- factor(corr.summary.seine$site.1,levels=n.to.s)
corr.summary.seine$site.2 <- factor(corr.summary.seine$site.2,levels=n.to.s)
corr.summary.seine$mean.corr[corr.summary.seine$mean.corr ==1 ] <- NA

cov.summary.seine <-  melt(COV.mean.seine,value.name="mean.cov") %>% left_join(.,melt(COV.sd.seine,value.name="sd.cov")) %>%
  left_join(.,melt(COV.quant.seine[1,,],value.name="q.025")) %>%
  left_join(.,melt(COV.quant.seine[2,,],value.name="q.05")) %>%
  left_join(.,melt(COV.quant.seine[3,,],value.name="q.095")) %>%
  left_join(.,melt(COV.quant.seine[4,,],value.name="q.0975")) %>%
  rename(site.1=Var1,site.2=Var2) %>%
  left_join(., dist.km.long) %>%
  filter(mean.cov !=0)

plot(mean.corr~dist.km,data=corr.summary.seine %>% filter(dist.km>0),ylim=c(-1,1),col=2)#,title="FISH")

########################################
# Write the Output.rmarkdown object to file
setwd(base.dir)
save(Output.rmarkdown,file="./Writing/Output for rmarkdown.RData")




