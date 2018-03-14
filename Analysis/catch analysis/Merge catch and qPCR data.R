### Matching qPCR results with seine information.


# Load catch information from seines
source("/Users/ole.shelton/GitHub/Skagit_Salmon_eDNA/Analysis/catch analysis/parse catch data.R")

# Load up water samples and information from qPCR
setwd("/Users/ole.shelton/GitHub/Skagit_Salmon_eDNA/Analysis/")
source("0_load_project.R")
source("qpcr_load.R")

data_dir <- "/Users/ole.shelton/GitHub/Skagit_Salmon_eDNA/Data/"
water <- load_water_samples()

# we are interested in the objects "water" and "res[[7]]" which corresponds to the qpcr run on 180302
head(water)
head(res[[7]])

dat <- as.data.frame(res[[7]])
sort(unique(dat$template_name))
sort(unique(water$lab_label))
names(water)
names(dat)

dat.summ <- dat %>% dplyr::select(template_name,template_rep) %>% group_by(template_name) %>% summarize(n.rep=length(template_name))
samp.run <- left_join(water,dat.summ,by=c("lab_label"="template_name"))

temp <- samp.run %>% filter(is.na(n.rep)==F) %>% group_by(site_name, date) %>% summarize(samp = length(n.rep)) %>%
          dcast(.,date~site_name,value.var=c("samp")) %>% as.data.frame()






