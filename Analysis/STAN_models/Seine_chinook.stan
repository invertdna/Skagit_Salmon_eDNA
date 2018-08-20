// This is a model file for calculating the qPCR results for Skagit eDNA sampling in 2017.

data { /////////////////////////////////////////////////////////////////////////////////////////////////////
    // Indices and counters
  int N_site ;   // Number of Sites
  int N_month ; // Number of months observed
  int N_site_month;
  int N_seine; // Number of seine sets
  
  int site_month_idx[N_seine] ; 
  
  // Chinook catches observed
  int count_set[N_seine] ;
}
transformed data{
}
parameters { /////////////////////////////////////////////////////////////////////////////////////////////
    // Effects of sites and seines
      vector[N_site_month] psi ; // this is the log mean of the negative binomial for each site-month combo
      //real eta[N_seine] ;
    // Among seine parameter for overdispersion    
      real<lower=0> tau_seine ;
}
transformed parameters { ////////////////////////////////////////////////////////////////////////////////
    // Latent variables for each log Density of 
      vector[N_seine] theta ;
      
    // Latent variables for each site
    for(i in 1:N_seine){
      theta[i] = psi[site_month_idx[i]]  ;
    }

}
model {////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Likelihood components
    count_set ~ neg_binomial_2_log(theta, tau_seine);

    // Priors
    psi ~ normal(0,3) ; // log mean prior
    tau_seine~ gamma(1,1);
}
