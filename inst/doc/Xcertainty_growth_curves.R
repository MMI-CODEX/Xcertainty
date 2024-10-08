## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ----echo=TRUE, warning=FALSE-------------------------------------------------
library(Xcertainty)

library(tidyverse)
library(ggdist)
library(coda)

## -----------------------------------------------------------------------------
data('calibration')

# sample size for each UAS
table(calibration$uas)


## -----------------------------------------------------------------------------
# parse calibration study
calibration_data = parse_observations(
  x = calibration, 
  subject_col = 'CO.ID',
  meas_col = 'Lpix', 
  tlen_col = 'CO.L', 
  image_col = 'image', 
  barometer_col = 'Baro_Alt',
  laser_col = 'Laser_Alt', 
  flen_col = 'Focal_Length', 
  iwidth_col = 'Iw', 
  swidth_col = 'Sw',
  uas_col = 'uas'
)

## -----------------------------------------------------------------------------
data('whales')

# parse field study
whale_data = parse_observations(
  x = whales, 
  subject_col = 'whale_ID',
  meas_col = 'TL.pix', 
  image_col = 'Image', 
  barometer_col = 'AltitudeBarometer',
  laser_col = 'AltitudeLaser', 
  flen_col = 'FocalLength', 
  iwidth_col = 'ImageWidth', 
  swidth_col = 'SensorWidth', 
  uas_col = 'UAS',
  timepoint_col = 'year'
)

## ----warning=FALSE------------------------------------------------------------
sampler = growth_curve_sampler(
  data = combine_observations(calibration_data, whale_data),
  priors = list(
    image_altitude = c(min = 0.1, max = 130),
    altimeter_bias = rbind(
      data.frame(altimeter = 'Barometer', mean = 0, sd = 1e2),
      data.frame(altimeter = 'Laser', mean = 0, sd = 1e2)
    ),
    altimeter_variance = rbind(
      data.frame(altimeter = 'Barometer', shape = .01, rate = .01),
      data.frame(altimeter = 'Laser', shape = .01, rate = .01)
    ),
    altimeter_scaling = rbind(
      data.frame(altimeter = 'Barometer', mean = 0, sd = 1e1),
      data.frame(altimeter = 'Laser', mean = 0, sd = 1e1)
    ),
    pixel_variance = c(shape = .01, rate = .01),
    # priors from Agbayani et al. 
    zero_length_age = c(mean = -5.09, sd = 0.4),
    growth_rate = c(mean = .18, sd = .01),
    # additional priors
    group_asymptotic_size = rbind(
      Female = c(mean = 12, sd = .5),
      Male = c(mean = 12, sd = .5)
    ),
    group_asymptotic_size_trend = rbind(
      Female = c(mean = 0, sd = 1),
      Male = c(mean = 0, sd = 1)
    ),
    subject_group_distribution = c(Female = .5, Male = .5),
    asymptotic_size_sd = c(min = 0, max = 10),
    min_calf_length = 3.5,
    # To model break points between 1990 and 2015
    group_size_shift_start_year = c(min = 1990, max = 2015)
  ),
  subject_info = whale_info
)

## -----------------------------------------------------------------------------
output_growth = sampler(niter = 1e4)

## -----------------------------------------------------------------------------
head(output_growth$summaries$objects)

## -----------------------------------------------------------------------------
output_growth$summaries$altimeters

## -----------------------------------------------------------------------------
output_growth$pixel_error$summary

## -----------------------------------------------------------------------------
output_growth$summaries$growth_curve[1:10,]

## -----------------------------------------------------------------------------
# total length summary outputs for each subject
sums_L <- output_growth$summaries$objects

# birth year summary outputs for each subject
birth_year <- output_growth$growth_curve$birth_year$summary %>% rename_with(~str_c("birth_year_", .), everything()) %>%
  separate(birth_year_parameter, c("Subject", "Parameter"), sep = " ") %>% dplyr::select(!"Parameter")

# combine total length and birth year summary outputs. Then join with whale info to get sex, AgeType. Finally, calculated new estimated age. 
sum <- sums_L %>% 
  left_join(birth_year, by = "Subject") %>% mutate(Year = as.integer(Timepoint)) %>%
  left_join(whale_info %>% mutate(Subject = as.factor(Subject)) %>% rename(sex = Group), by = c("Subject", "Year")) %>% 
  relocate(Year, .before = Timepoint) %>% 
  mutate(Age_est_mean = Year - birth_year_mean, 
         Age_est_lower = Year - birth_year_upper, 
         Age_est_upper = Year - birth_year_lower)

## ----fig.dim = c(7, 5)--------------------------------------------------------
ggplot() + theme_bw() + 
  geom_pointrange(data = sum, aes(x = Age_est_mean, y = mean, ymin = lower, ymax = upper)) +
  geom_errorbarh(data = sum, 
                 aes(xmin = Age_est_lower, xmax = Age_est_upper, y = mean), lty = 2) + 
  xlab("estimated age") + ylab("total body length (m)") 


## -----------------------------------------------------------------------------
# create a dataframe of the output growth parameters
pred_growth <- rbind(data.frame(t0 = output_growth$growth_curve$zero_length_age$samples,
           k = output_growth$growth_curve$growth_rate$samples,
           sex = "Female",
           A = output_growth$growth_curve$group_asymptotic_size$samples[,1]),
           data.frame(
           t0 = output_growth$growth_curve$zero_length_age$samples,
           k = output_growth$growth_curve$growth_rate$samples,
           sex = "Male",
           A = output_growth$growth_curve$group_asymptotic_size$samples[,2]))

# write a loop to calculate the expected length for male and females between ages 1-40 for each MCMC iteration to create a distribution. Then calculate the mean and HPDIs from the distribution for each expected length.
age_list <- seq(from  = 1, to = 40, by = 1)
sex_list <- c("Male", "Female")

age_df <- data.frame()
full_df <- data.frame()

for (s in sex_list){
  s_x = s
for (i in age_list){
  yr0 = i
  growth_filt = pred_growth %>% filter(sex == s_x)
  Exp.L = growth_filt$A * (1-exp(-growth_filt$k * (yr0 - growth_filt$t0)))
  Exp.L_mean = mean(Exp.L)
  Exp.L_lower = HPDinterval(mcmc(Exp.L))[1]
  Exp.L_upper = HPDinterval(mcmc(Exp.L))[2]
  temp_df <- data.frame(age = yr0, sex = s_x, 
                        Exp.L_mean, Exp.L_lower = Exp.L_lower, Exp.L_upper = Exp.L_upper) 
  age_df <- rbind(age_df, temp_df)
}
  full_df <- rbind(full_df, age_df)
}


## ----fig.dim = c(7, 5)--------------------------------------------------------
ggplot() + theme_bw() + 
  xlab("estimated age") + ylab("total body length (m)") + 
  geom_ribbon(data = full_df, aes(x = age, ymin = Exp.L_lower, ymax = Exp.L_upper, fill = sex), alpha = 0.4) + 
  geom_line(data = full_df, aes(x = age, y = Exp.L_mean, color = sex)) +
  scale_color_manual(values = c(Female = "lightblue3", Male = "darkorange")) +
  scale_fill_manual(values = c(Female = "lightblue3", Male = "darkorange")) +
  geom_pointrange(data = sum %>% filter(!is.na(sex)),
                  aes(x = Age_est_mean, y = mean, ymin = lower, ymax = upper, color = sex)) +
  geom_errorbarh(data = sum, 
                 aes(xmin = Age_est_lower, xmax = Age_est_upper, y = mean, color = sex), lty = 3) 
  

