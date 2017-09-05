

functions {
  vector get_response_probs(real rt, vector mu, real[] sigma,
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
  real<lower=0, upper=1> upper_b; // prob of generating correct response after it is prepared
  positive_ordered[2] mu[nsub]; // location parameters per subject & CDF; index via mu_raw[subject, parameter]
  real mu_a;
  real mu_b;
  real<lower=0> sigma_a;
  real<lower=0> sigma_b;
  
  real<lower=0> sigma[2]; // scale parameters per subject & CDF
  real<lower=0, upper=1> guess; // prob of random guess (est population only for now)
  real<lower=0, upper=1> habit[nsub]; // habit==1 is habit, habit==0 is no habit (estimate one per subject)
  
}
transformed parameters {
}
model {
  // hyperparameters + hyperpriors(?)
  mu_a ~ normal(0.2, 0.1);
  sigma_a ~ normal(0, 0.1); // should we get a covariance between sigma_a and sigma_b?
  mu_b ~ normal(0.45, 0.1);
  sigma_b ~ normal(0, 0.2);
  
  // parameters
  mu[:,1] ~ normal(mu_a, sigma_a); // uncenter these
  mu[:,2] ~ normal(mu_b, sigma_b);
  sigma ~ gamma(2, 10); // avoid 0/close to zero, alt. might be normal(0.1, 0.1)
  guess ~ normal(0.25, 0.1); // pretty confident it's going to be 1/4 (do we want to fix it then?)
  upper_b ~ beta(10, 2); // give it vague support close to 1
  habit ~ beta(1, 1); // continuous habit (0, 1) (unpooled -- do we expect bimodality?)
  // increment log probability
  for (n in 1:N) {
    y[n] ~ categorical(get_response_probs(rt[n], mu[subject[n]], sigma,
                                          upper_a, upper_b, guess, 
                                          habit[subject[n]]));
  }
}

generated quantities {
  vector[N] y_sim;
  vector[N] log_lik;
  for (n in 1:N) {
    y_sim[n] = categorical_rng(get_response_probs(rt[n], mu[subject[n]], sigma,
                                                     upper_a, upper_b, guess, 
                                                     habit[subject[n]]));
    log_lik[n] = categorical_lpmf(y[n] | get_response_probs(rt[n], mu[subject[n]], sigma,
                                          upper_a, upper_b, guess, 
                                          habit[subject[n]]));
  }
}

