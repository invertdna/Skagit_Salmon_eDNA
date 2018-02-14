# conc_orig <- 1.57e-9 # ng/uL

# conc_orig <- 4e-9 # nM

# # convert to pM
# conc_orig <- conc_orig 


conc_lib <- 135.728/255 # ng/uL

final <- 1.356


(conc_lib * 255)/final

lib_size <- 514

# nanomolar - i.e. MOLESe-9 / liter
molarity <- 1e6 * (conc_lib / (660 * lib_size)) # in nanomolar

vol_current <- 255e-6

nanomoles <- molarity * vol_current

new_vol <- 0.9e-6
(new_molarity <- moles/new_vol)

new_vol <- 0.2e-3
(new_molarity <- moles/new_vol)

molarity_desired <- 4e-9

vol_current*(molarity/molarity_desired) * 1e6

sum(17*(unlist(c(toplot, c(0.62, 0.58, 0.58)))))

136/20
15*17



