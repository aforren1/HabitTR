
data {
  int<lower=0> N; // total number of responses
  int<lower=0> y[N]; // response
  real rt[N]; // reaction time
}

parameters {
  real<lower=0, upper=1> q[2]; // prob of generating response A after prepared
  positive_ordered[2] mu; // mean time of prep per action, constrain mu ordering
  real<lower=0> sigma[2];
  real<lower=0, upper=1> q_i; // prob of random guess
  real<lower=0, upper=1> rho; // rho==1 is habit, rho==0 is no habit
}

transformed parameters {
  matrix[3, 4] alpha;
  matrix[4, N] phi_all;
  real phi_a;
  real phi_b;
  matrix[3, N] response;
  alpha = [[q_i, rho * (1 - q[1])/3 + (1 - rho)*q_i, q[2], q[2]], // mapping B (correct)
           [q_i, rho * q[1] + (1 - rho) * q_i, (1 - q[2])/3, (1 - q[2])/3], // mapping A (habit)
           [2*(0.5 - q_i), 2*(rho * (1 - q[1])/3 + (1 - rho) * (0.5 - q_i)), 2*((1 - q[2])/3), 2*((1 - q[2])/3)]];

  for (ii in 1:N) {
      phi_a = Phi_approx((rt[ii] - mu[1])/sigma[1]);
      phi_b = Phi_approx((rt[ii] - mu[2])/sigma[2]);
      phi_all[1, ii] = (1 - phi_a) * (1 - phi_b);
      phi_all[2, ii] = phi_a * (1 - phi_b);
      phi_all[3, ii] = (1 - phi_a) * phi_b;
      phi_all[4, ii] = phi_a * phi_b;
  }
  response = alpha * phi_all;
}

model {
  mu[1] ~ normal(0.2, 0.1);
  mu[2] ~ normal(0.5, 0.1);
  sigma ~ normal(0.1, 0.1);
  q_i ~ beta(2, 4);
  q ~ beta(20, 5);
  rho ~ beta(5, 5);
  for (n in 1:N) {
    y[n] ~ categorical(response[:, n]);
  }
}
