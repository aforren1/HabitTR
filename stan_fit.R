library(rstan)
#library(brms)

individual_dat <- R.matlab::readMat('HabitData.mat')
three_week <- individual_dat[[1]][,,3]

subject_counter <- 1
data_list <- list()

for (ii in 1:24) {
  if (!is.null(three_week[,ii][[1]])) {
    data_list[[subject_counter]] <- data.frame(rt = three_week[,ii]$RT[1,],
                                               response = three_week[,ii]$response[1,],
                                               id = subject_counter)
    subject_counter <- subject_counter + 1
  }
}

three_week <- do.call(rbind, data_list)
three_week <- three_week[three_week$rt > 0,]

data <- list(rt = three_week$rt,
             y = three_week$response,
             nsub = length(unique(three_week$id)),
             subject = three_week$id,
             N = nrow(three_week))

mod <- stan_model('multilevel.stan')
mod2 <- stan_model('multilevel_discrete_rho.stan')

fit <- sampling(mod, data = data,
                chains = 3,
                cores = 3,
                iter = 5000,
                control = list(adapt_delta = 0.95))

#print(fit, pars = c('upper_b', 'mu', 'sigma', 'guess', 'habit'))

fit2 <- sampling(mod2, data = data,
                 chains = 3,
                 cores = 3,
                 iter = 5000)

preds <- summary(fit, pars = 'probs_sim_continuous', probs = c(0.1, 0.9))


get_response_probs <- function(x, mu1, mu2, sigma1, sigma2, upper_a, upper_b, guess, habit) {
  # upper_a fixed at 0.95 (also in stan code)
  alpha <- matrix(NA, nrow = 3, ncol = 4)
  phi_a <- pnorm((x - mu1)/sigma1)
  phi_b <- pnorm((x - mu2)/sigma2)
  phi_all <- matrix(c((1 - phi_a) * (1 - phi_b),
                      phi_a * (1 - phi_b),
                      (1 - phi_a) * phi_b,
                      phi_a * phi_b), ncol = 1)
  alpha[1,] <- c(guess, habit * (1 - upper_a)/3 + (1 - habit)*guess, upper_b, upper_b)
  alpha[2,] <- c(guess, habit * upper_a + (1 - habit) * guess, (1 - upper_b)/3, (1 - upper_b)/3)
  alpha[3,] <- c(2*(0.5 - guess), 
                 2*(habit * (1 - upper_a)/3 + (1 - habit) * (0.5 - guess)),
                 2*((1 - upper_b)/3),
                 2*((1 - upper_b)/3))
  alpha %*% phi_all
}

grp_stan <- '
vector get_response_probs(real rt, real mu1, real mu2, real sigma1, real sigma2,
                          real upper_b, 
                          real guess, real habit) {
  // single-trial response probabilities (1:3)
  matrix[3, 4] alpha;
  vector[4] phi_all;
  real phi_a;
  real phi_b;
  
  phi_a = Phi_approx((rt - mu1)/sigma1); // Phi_approx behaves better in the tails
  phi_b = Phi_approx((rt - mu2)/sigma2); // compared to the normal CDF
  phi_all[1] = (1 - phi_a) * (1 - phi_b);
  phi_all[2] = phi_a * (1 - phi_b);
  phi_all[3] = (1 - phi_a) * phi_b;
  phi_all[4] = phi_a * phi_b;
  
  alpha = [[guess, habit * (1 - 0.95)/3 + (1 - habit)*guess, upper_b, upper_b], // mapping B (correct)
           [guess, habit * 0.95 + (1 - habit) * guess, (1 - upper_b)/3, (1 - upper_b)/3], // mapping A (habit)
           [2*(0.5 - guess), 2*(habit * (1 - 0.95)/3 + (1 - habit) * (0.5 - guess)),
             2*((1 - upper_b)/3), 2*((1 - upper_b)/3)]]; // other responses (two combined)
  return alpha * phi_all;    
}
'

form <- bf(response ~ get_response_probs(rt, mu1, mu2, sigma1, sigma2, upper_b, guess, habit),
           family = categorical(link = 'identity'))


## TMB fit (frequentist)
library(TMB)
library(nloptr)

compile('test_tmb.cpp')
dyn.load(dynlib('test_tmb'))

y2 <- matrix(0, nrow = length(unique(three_week$response)), ncol = nrow(three_week))
y2[1,] <- three_week$response == 1
y2[2,] <- three_week$response == 2
y2[3,] <- three_week$response == 3

data <- list(y2 = y2[,three_week$id == 1],
             rt = three_week$rt[three_week$id == 1])

parameters <- list(mu1 = .2,
                   mu2 = .4,
                   sigma1 = .05,
                   sigma2 = .1,
                   upper_a = .95,
                   upper_b = .95,
                   guess = .25,
                   habit = .9)

map <- list(guess = factor(NA), # fix until fitting hierarchical version (too many parameters?)
            upper_a = factor(NA))

obj <- MakeADFun(data = data,
                 parameters = parameters,
                 map = map,
                 DLL = 'test_tmb')

opt <- nlminb(obj$par, obj$fn, obj$gr, 
              lower = c(0, 0, 0, 0, 0, 0),
              upper = c(Inf, Inf, Inf, Inf, 1, 1))

constr <- function(x, ...) {
  -x[2] + x[1] # should be greater than or equal to zero
}

constr_jac <- function(x, ...) {
  rbind(c(1, -1, 0, 0, 0, 0))
}

res0 <- nloptr(x0 = obj$par, eval_f = obj$fn,
               lb = c(0, 0, -Inf, -Inf, -Inf, -Inf),
               eval_grad_f = obj$gr,
               eval_g_ineq = constr,
               eval_jac_g_ineq = constr_jac,
               opts = list('algorithm' = 'NLOPT_LD_MMA',
                           'xtol_rel' = 1.0e-8,
                           'check_derivatives' = TRUE),
               ... = 0)