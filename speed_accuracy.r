library(R.matlab)
library(ggplot2)
library(data.table)

slider <- function(x, y, window_size = 0.1) {
  out <- rep(NA, length(y))
  upper <- x + (window_size/2)
  lower <- x - (window_size/2)
  for (nn in seq(1, length(y))) {
    out[nn] <- mean(y[x <= upper[nn] & x >= lower[nn]], na.rm = TRUE)
  }
  out
}

group_dat <- readMat('group_tmp.mat')

unchanged_1d <- data.table(
  rt = group_dat['unchangedX.all'][[1]][[1]][[1]],
  resp = group_dat['unchangedY.all'][[1]][[1]][[1]],
  days = '1d',
  cond = 'unrevised'
)

unchanged_5d <- data.table(
  rt = group_dat['unchangedX.all'][[1]][[2]][[1]],
  resp = group_dat['unchangedY.all'][[1]][[2]][[1]],
  days = '5d',
  cond = 'unrevised'
)

unchanged_20d <- data.table(
  rt = group_dat['unchangedX.all'][[1]][[3]][[1]],
  resp = group_dat['unchangedY.all'][[1]][[3]][[1]],
  days = '20d',
  cond = 'unrevised'
)

unchanged <- rbind(unchanged_1d, 
                   unchanged_5d,
                   unchanged_20d)
names(unchanged) <- c('rt', 'resp', 'days', 'cond')

unchanged <- unchanged[rt > 0]

revised_1d <- data.table(
  rt = group_dat['revisedX.all'][[1]][[1]][[1]],
  resp = group_dat['revisedY.all'][[1]][[1]][[1]],
  days = '1d',
  cond = 'revised'
)

revised_5d <- data.table(
  rt = group_dat['revisedX.all'][[1]][[2]][[1]],
  resp = group_dat['revisedY.all'][[1]][[2]][[1]],
  days = '5d',
  cond = 'revised'
)

revised_20d <- data.table(
  rt = group_dat['revisedX.all'][[1]][[3]][[1]],
  resp = group_dat['revisedY.all'][[1]][[3]][[1]],
  days = '20d',
  cond = 'revised'
)

revised <- rbind(revised_1d, 
                   revised_5d,
                   revised_20d)
names(revised) <- c('rt', 'resp', 'days', 'cond')

revised <- revised[rt > 0]

dat <- rbind(unchanged, revised)
dat$type <- interaction(dat$days, dat$cond)
#unchanged[, 'slide' := slider(rt, resp), by = c('type')]

# define function to match stan
normal_cdf <- function(...){ pnorm(...) }

mod <- brm(bf(
  resp ~ floor + (ceil - floor) * normal_cdf(rt, mn, sigma),
  ceil ~ 0 + type,
  floor ~ 1, # do we need a varying floor?
  mn ~ 0 + type,
  sigma ~ 0 + type,
  nl = TRUE),
  data = dat,
  family = bernoulli('identity'),
  prior = c(
    prior(normal(0.5, 0.1), nlpar = 'mn'),
    prior(normal(0.1, 0.1), nlpar = 'sigma', lb = 0),
    prior(normal(0.25, 0.05), nlpar = 'floor', lb = 0, ub = 1),
    prior(normal(0.95, 0.05), nlpar = 'ceil', lb = 0, ub = 1)
  ),
  chains = 4,
  cores = 4
)

# predict on newdata is weird
# fit seems perfectly finedd <- fitted(mod, newdata = data.frame(rt = rep(1:1200, 3),

tmp_data <- data.frame(rt = rep(1:1200, 3)/1000,
                       cond = rep(c('unrevised', 'revised'), c(3600, 3600)),
                       type = rep(c('1d.unrevised', '5d.unrevised', '20d.unrevised',
                                    '1d.revised', '5d.revised', '20d.revised'), rep(1200, 6)))
  
fitted_vals <- fitted(mod, 
                      newdata = tmp_data)
tmp_data <- cbind(tmp_data, fitted_vals)

ggplot(tmp_data, aes(x = rt, y = Estimate, fill = type)) + 
  geom_ribbon(aes(ymin = `2.5%ile`, ymax = `97.5%ile`), alpha = 0.5) +
  geom_line(aes(y = Estimate, colour = type))


