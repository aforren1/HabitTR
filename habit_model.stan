
functions {
  vector get_response_probs(real rt, vector mu, vector sigma,
                            real upper_a, real upper_b, 
                            real guess, real habit) {
    // single-trial response probabilities (1:3)
    matrix[3, 4] alpha;
    vector[4] phi_all;
    real phi_a;
    real phi_b;

    phi_a = Phi_approx((rt - mu[1])/sigma[1]); // Phi_approx behaves better in the tails
    phi_b = Phi_approx((rt - mu[2])/sigma[2]); // compared to the normal CDF
    phi_all[1] = (1 - phi_a) * (1 - phi_b);
    phi_all[2] = phi_a * (1 - phi_b);
    phi_all[3] = (1 - phi_a) * phi_b;
    phi_all[4] = phi_a * phi_b;
    
    alpha = [[guess, habit * (1 - upper_a)/3 + (1 - habit)*guess, upper_b, upper_b], // mapping B (correct)
    [guess, habit * upper_a + (1 - habit) * guess, (1 - upper_b)/3, (1 - upper_b)/3], // mapping A (habit)
    [2*(0.5 - guess), 2*(habit * (1 - upper_a)/3 + (1 - habit) * (0.5 - guess)),
     2*((1 - upper_b)/3), 2*((1 - upper_b)/3)]]; // other responses (two combined)
    return alpha * phi_all;    
  }
}

data {
  int<lower=0> N; // total number of responses
  int<lower=0> y[N]; // response
  int<lower=0> nsub; // number of subjects
  int<lower=1, upper=nsub> subject[N];
  real rt[N]; // reaction time
}
transformed data {
  real upper_a = 0.95; // fixed upper asymptote for a (otherwise redundant w/ habit)
}

parameters {
  //real<lower=0, upper=1> upper_a;
  real upper_b_raw[nsub]; // prob of generating correct response after it is prepared
  real upper_b_mu;
  real<lower=0> upper_b_sigma;
  //ordered[2] mu[nsub]; // location parameters per subject & CDF; index via mu_raw[subject, parameter]
  
  vector[2] mu_raw[nsub];
  real mu_a;
  real mu_b;
  real<lower=0> mu_sigma_a;
  real<lower=0> mu_sigma_b;
  
  //vector[2] sigma[nsub]; // scale parameters per subject & CDF (unscaled)
  vector[2] sigma_raw[nsub];
  real sigma_a; // population-level effects (unscaled)
  real sigma_b;
  real<lower=0> sigma_sigma_a;
  real<lower=0> sigma_sigma_b;
  
  real<lower=0, upper=1> guess; // prob of random guess (pooled)
  real<lower=0, upper=1> habit[nsub]; // habit==1 is habit, habit==0 is no habit (estimate one per subject)
}

transformed parameters {
  vector[2] mu[nsub];
  vector[2] sigma[nsub];
  vector[2] exp_sigma[nsub];
  
  real upper_b[nsub];
  real inv_logit_upper_b[nsub];
  
  // center/scale "actual" mu/sigma
  for (n in 1:nsub) {
    mu[n,1] = mu_raw[n,1] * mu_sigma_a + mu_a;
    mu[n,2] = mu_raw[n,2] * mu_sigma_b + mu_b;
    
    sigma[n,1] = sigma_raw[n,1] * sigma_sigma_a + sigma_a;
    sigma[n,2] = sigma_raw[n,2] * sigma_sigma_b + sigma_b;
    
    upper_b[n] = upper_b_raw[n] * upper_b_sigma + upper_b_mu;
    
  }

  // constrain sigma to be positive
  exp_sigma[:,1] = exp(sigma[:,1]);
  exp_sigma[:,2] = exp(sigma[:,2]);
  
  // inverse logit of upper bound for b
  inv_logit_upper_b = inv_logit(upper_b);
}

model {
  // hyperpriors on hyperparameters
  mu_a ~ normal(0.2, 0.05);
  mu_b ~ normal(0.45, 0.05);
  mu_sigma_a ~ normal(0, 0.1); // these become half-normal priors (due to <lower=0> constraint)
  mu_sigma_b ~ normal(0, 0.1);
  
  sigma_a ~ normal(-3, 1);
  sigma_b ~ normal(-3, 1);
  sigma_sigma_a ~ normal(0.1, 0.1);
  sigma_sigma_b ~ normal(0.1, 0.1);
  
  upper_b_mu ~ normal(3, 1);
  upper_b_sigma ~ normal(1, 1);
  
  // priors for 'uncentered' parameterization
  mu_raw[:,1] ~ normal(0, 1);
  mu_raw[:,2] ~ normal(0, 1);
  sigma_raw[:,1] ~ normal(0, 1);
  sigma_raw[:,2] ~ normal(0, 1);
  upper_b_raw ~ normal(0, 1);
  
  // priors for additional parameters
  guess ~ normal(0.25, 0.05); // fairly confident it'll be 0.25
  habit ~ beta(1, 1); // uniform support over (0, 1)
  
  for (n in 1:N) {
    y[n] ~ categorical(get_response_probs(rt[n], mu[subject[n]], exp_sigma[subject[n]],
                       upper_a, inv_logit_upper_b[subject[n]], guess, habit[subject[n]]));
  }
}

generated quantities {
  matrix[3, N] probs_sim_continuous;
  vector[N] log_lik;
  
  for (n in 1:N) {
    probs_sim_continuous[:, n] = get_response_probs(rt[n], mu[subject[n]], exp_sigma[subject[n]],
                                                    upper_a, inv_logit_upper_b[subject[n]], guess, 
                                                    habit[subject[n]]);
    log_lik[n] = categorical_lpmf(y[n] | probs_sim_continuous[:, n]);
  }
}




