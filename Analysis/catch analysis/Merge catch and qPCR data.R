### Matching qPCR results with seine information.


# Load catch information from seines
source("parse catch data.R")

# Load up water samples and information from qPCR
setwd("..")
source("0_load_project.R")
source("qpcr_load.R")

data_dir <- "../Data/"
water <- load_water_samples()

# we are interested in the objects "water" and "res[[7]]" which corresponds to the qpcr run on 180302
head(water)
head(res[[7]])

res[[6]][,note := NULL]
res[[7]][,note := NULL]

dat <- as.data.frame(rbindlist(res))
dat <- as.data.frame(res[[7]])

sort(unique(dat$template_name))
sort(unique(water$lab_label))
names(water)
names(dat)

dat.summ <- dat %>% dplyr::select(template_name,template_rep) %>% group_by(template_name) %>% summarize(n.rep=length(template_name))
samp.run <- left_join(water,dat.summ,by=c("lab_label"="template_name"))

temp <- samp.run %>% filter(is.na(n.rep)==F) %>% group_by(site_name, date) %>% summarize(samp = length(n.rep)) %>%
          dcast(.,date~site_name,value.var=c("samp")) %>% as.data.frame()

samp.run %>% filter(site_name %in% c("Mariners Bluff","Brown Point","Dugualla Bluff")) %>% select(date,site_name,n.rep,lab_label)

