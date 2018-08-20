// This is a model file for calculating the qPCR results for Skagit eDNA sampling in 2017.

data { /////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Number of observations in various categories
    int N_site ;   // Number of Sites
    int N_month ;  // Number of months observed
    int N_site_month; // Number of site-month combinations observed.
    int N_bottle ; // Number of individual bottles observed.
    int N_pcr ;    // Number of PCR plates
    
    int N_bin_stand ;   // Number of observations for binomial part of the standards model
    int N_count_stand ; // Number of observations for count part of the standards model
    int N_bin_samp   ;  // Number of observations for binomial part of the sample model
    int N_count_samp ;  // Number of observations for count part of the sample model

    // Observations
    int bin_stand[N_bin_stand]     ;
    vector[N_count_stand] count_stand ;
    int bin_samp[N_bin_samp]      ; 
    vector[N_count_samp] count_samp   ;
    
    // Covariates
    vector[N_bin_stand] D_bin_stand     ;
    vector[N_count_stand] D_count_stand ;

    // Standard Indices
    int pcr_stand_bin_idx[N_bin_stand] ;
    int pcr_stand_count_idx[N_count_stand] ;
    int pcr_samp_bin_idx[N_bin_samp] ;
    int pcr_samp_count_idx[N_count_samp] ;

    // Site-month and bottle indices
    int site_month_idx[N_bottle]    ;
    int bottle_idx[N_bottle];
    int gamma_idx[N_site_month] ;
    
    // Sample related indices
    int site_bin_idx[N_bin_samp]      ;
    int site_count_idx[N_count_samp]  ;
    int site_month_bin_idx[N_bin_samp]   ;
    int site_month_count_idx[N_count_samp] ;
    int month_bin_idx[N_bin_samp]     ;
    int month_count_idx[N_count_samp] ;
    int bottle_bin_idx[N_bin_samp]    ;
    int bottle_count_idx[N_count_samp];
    
    // counter for number of sites estimated for each month  
    //vector[N_month] counter ;
    
    //Offset
    real OFFSET ;
}
transformed data{
}
parameters { /////////////////////////////////////////////////////////////////////////////////////////////
    // Standards regression and logit coeffs
      // real beta_0 ;
      // real beta_1 ;
      // real phi_0 ;
      // real phi_1 ;

      real beta_0[N_pcr] ;
      real beta_1[N_pcr] ;
      // real beta_0_bar ; // heirarchical parameters for slope
      // real beta_1_bar ; 
      // vector[N_pcr] beta_0_raw ;
      // vector[N_pcr] beta_1_raw ;
      // real<lower=0> beta_0_sd ;  // heirarchical parameters for slope
      //  real<lower=0> beta_1_sd ; 

      real phi_0[N_pcr] ;
      real phi_1[N_pcr];

      // real phi_0[N_pcr] ;
      // real phi_1[N_pcr];
      // real phi_0_bar ; // heirarchical parameters for slope
      // real phi_1_bar ;
      // real <lower=0> phi_0_sd ;  // heirarchical parameters for slope
      // real <lower=0> phi_1_sd ;


    // Variance parameters for observation and random effects
      real sigma_stand_int ;
      //real sigma_stand_slope ;
     // real sigma_stand_slope2 ;
      
      // real sigma_stand_int_bar ;
      // real<lower=0> sigma_stand_int_sd ;
      // real sigma_stand_slope_bar ;
      // real<lower=0> sigma_stand_slope_sd ;
      // 
      //vector<lower=0>[N_pcr] sigma_stand_int ;
      
      real<lower=0> tau_bottle ;
      real<lower=0> sigma_pcr ; 
    
    // Effects of sites and bottles
      real gamma[N_site_month] ;
      real delta[N_bottle] ;
}
transformed parameters { ////////////////////////////////////////////////////////////////////////////////
    // Latent variables for each log Density of 
      // real<lower=0> beta_0_sd ;
      // real<lower=0> beta_1_sd ;
      
      vector[N_bottle] D ;
      vector[N_bin_stand] theta_stand ;
      vector[N_bin_samp] theta_samp ;
      vector[N_count_stand] kappa_stand ;
      vector[N_count_samp] kappa_samp ;
//      vector[N_count_stand] sigma_all_stand ;
  //    vector[N_count_samp] sigma_all_samp ;
      real sigma_all_stand ;
      real sigma_all_samp ;
      
      // vector[N_pcr] beta_1 ;
      // vector[N_pcr] beta_0 ;

      //MATT TRICK FOR BETA_1
      // beta_0 = beta_0_bar + beta_0_sd * beta_0_raw ;
      // beta_1 = beta_1_bar + beta_1_sd * beta_1_raw ;

      // beta_0_sd = exp(log_beta_0_sd) ;
      // beta_1_sd = exp(log_beta_1_sd) ;
      
    // Latent variables for each site
    for(i in 1:N_bottle){
      D[i] = gamma[site_month_idx[i]] + delta[bottle_idx[i]] ;
    }
    
    // Presence-Absence component of model.
    for(i in 1:N_bin_stand){
       theta_stand[i] = phi_0[pcr_stand_bin_idx[i]] + phi_1[pcr_stand_bin_idx[i]] *  (D_bin_stand[i] - OFFSET) ;
      //theta_stand[i] = phi_0 + phi_1 * (D_bin_stand[i] - OFFSET) ;

    }
    for(i in 1:N_bin_samp){
       theta_samp[i]  = phi_0[pcr_samp_bin_idx[i]] + phi_1[pcr_samp_bin_idx[i]] * (D[bottle_bin_idx[i]] - OFFSET) ;
      //theta_samp[i]  = phi_0 + phi_1 * (D[bottle_bin_idx[i]] - OFFSET) ;
    }
    
    // Positive Comonent of the model
    for(i in 1:N_count_stand){
       kappa_stand[i] = beta_0[pcr_stand_count_idx[i]] + beta_1[pcr_stand_count_idx[i]] * (D_count_stand[i] - OFFSET) ;
      //kappa_stand[i] = beta_0 + beta_1 * D_count_stand[i] ;
    }
    for(i in 1:N_count_samp){
      kappa_samp[i]  = beta_0[pcr_samp_count_idx[i]] + beta_1[pcr_samp_count_idx[i]] * (D[bottle_count_idx[i]] - OFFSET) ;
      //kappa_samp[i]  = beta_0 + beta_1 * D[bottle_count_idx[i]] ;
    }
    
    // 
    //for( i in 1:N_count_stand){
      sigma_all_stand = sigma_stand_int;
                                //+ sigma_stand_slope * (D_count_stand[i]- OFFSET)),-2)   ;
                                //+ sigma_stand_slope2 * D_count_stand[i]^2),-2) ;

    //}  
    //for( i in 1:N_count_samp){
      sigma_all_samp = pow(sigma_stand_int^2 +
                            //sigma_stand_slope * (D[bottle_count_idx[i]]- OFFSET)) +
                            //+ sigma_stand_slope2 * D[bottle_count_idx[i]]^2) + 
                            sigma_pcr^2,-2) ;
    //} 
    
}
model {////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Likelihood components
    bin_stand  ~ bernoulli( inv_logit(theta_stand) ) ;
    bin_samp   ~ bernoulli( inv_logit(theta_samp) ) ;
    count_stand ~ normal(kappa_stand, sigma_all_stand) ;
    count_samp ~ normal(kappa_samp, sigma_all_samp) ;

    // Random effects
    gamma ~ normal(-4,8);
    delta ~ normal(0,tau_bottle) ;
    
    // Priors
    sigma_stand_int ~ gamma(1,1) ;
    // sigma_stand_int ~ normal(0,2) ;
    // sigma_stand_slope ~ normal(-3,1) ;
    
    tau_bottle ~ gamma(1,1) ;
    sigma_pcr ~ gamma(1,1) ;

    beta_0 ~ normal(35,10) ;
    beta_1 ~ normal(-5,5) ;
    
    // beta_0 ~ normal(beta_0_bar,beta_0_sd) ;
    //beta_1 ~ normal(beta_1_bar,beta_1_sd) ;
    
    // MATT TRICK FOR BETA_1
    // beta_0_raw ~ normal(0,1) ;
    // beta_1_raw ~ normal(0,1) ;
    // 
    // beta_0_bar ~ normal(35,10) ;
    // beta_1_bar ~ normal(-3,1)  ;
    // beta_0_sd ~ gamma(1,1) ;
    // beta_1_sd ~ gamma(1.5,1.5)  ;

    phi_0 ~ normal(0 , 10) ;
    phi_1 ~ normal(5, 5) ;
    
    // phi_0 ~ normal(phi_0_bar , phi_0_sd) ;
    // phi_1 ~ normal(phi_1_bar, phi_1_sd) ;
    // phi_0_bar ~ normal(20,10) ;
    // phi_1_bar ~ normal(4,4)  ;
    // phi_0_sd ~ gamma(1,1) ;
    // phi_1_sd ~ gamma(1,1)  ;
}
generated quantities{
    //   vector[N_month] geom_month_index ;
    //   vector[N_month] arith_month_index ;
    // 
    //  //////////////////
    // /// Derived quantities for index standardization
    // //////////////////
    // geom_month_index = rep_vector(0,N_month);
    // arith_month_index = rep_vector(0,N_month);
    //  for( i in 1:N_site_month){
    //      geom_month_index[gamma_idx[i]] = geom_month_index[gamma_idx[i]] + gamma[gamma_idx[i]] ;
    //      arith_month_index[gamma_idx[i]] = arith_month_index[gamma_idx[i]] + pow(gamma[gamma_idx[i]],10);
    //  }
    //  for(j in 1:N_month){
    //    geom_month_index[j] = pow(geom_month_index[j],10) / counter[j];
    //  }
    //  arith_month_index = arith_month_index ./ counter ;
}
