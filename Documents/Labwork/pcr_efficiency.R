# calculate efficiency of PCR and cleanup for amplicon prep (16s nextera protocol)

# concentrations (ng/ul) after PCR1, before cleanup (Qiagen columns)
pre_cleanup <- c(
  "1" = 13.1, 
  "2" = 9.8,
  "3" = 12.9,
  "5" = 14.4,
  "6" = 8.69,
  "8" = 59.0
)

# concentrations (ng/ul) after cleanup (Qiagen columns), before PCR2
post_cleanup <- c(
  "1" = 20.8, 
  "2" = 19.2, 
  "3" = 21.6, 
  "5" = 22.8
)

# exclude samples not found in both sets
in_both <- names(post_cleanup)
pre_cleanup <- pre_cleanup[in_both]


# calculate cleanup recovery efficiency
(cleanup_eff <- ((pre_cleanup * 50) - (post_cleanup * 16))/(pre_cleanup*50))
mean(cleanup_eff)


# concentrations (ng/ul) after PCR2, before cleanup (AMPure SPRI beads)
post_pcr2 <- c(
  "1" = 51.4,
  "2" = 48.8,
  "3" = 56.2,
  "5" = 58.0
)

# mean amplification rate of PCR2
mean((post_pcr2*50)/(post_cleanup*15))

# minimum concentration needed after PCR1
# based on requirement of 10ng/uL after PCR2 cleanup
((500/8.5)*2)/25
