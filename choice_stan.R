
data {
  int<lower=1> N; // total # observations
  int Y[N]; // response variable
  int<lower=1> K; // number of options
  vector[N] X; // reaction time
}

parameters {
  real init_ae;
  real mu_a;
  real mu_b;
  real<lower=0> sigma_a;
  real<lower=0> sigma_b;
  real<lower=0, upper=1> qa; // probability of guessing A incorrectly
  real<lower=0, upper=1> qb; // probability of guessing B incorrectly
}

transformed parameters {

}

model {
  
  Y ~ categorical(alpha * phi);
}