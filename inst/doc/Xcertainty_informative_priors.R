## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ----echo=TRUE, warning=FALSE-------------------------------------------------
library(Xcertainty)

library(tidyverse)
library(ggdist)

## -----------------------------------------------------------------------------
# load calibration measurement data
data("co_data")

# sample size for both drones
table(co_data$uas)

# filter for P4P drone
co_data_p4p <- co_data %>% filter(uas == "P4P")

## -----------------------------------------------------------------------------
calibration_data = parse_observations(
  x = co_data_p4p, 
  subject_col = 'CO.ID',
  meas_col = 'Lpix', 
  tlen_col = 'CO.L', 
  image_col = 'image', 
  barometer_col = 'Baro_Alt',
  laser_col = 'Laser_Alt', 
  flen_col = 'Focal_Length_adj', 
  iwidth_col = 'Iw', 
  swidth_col = 'Sw',
  uas_col = 'uas'
)

## -----------------------------------------------------------------------------
# load gray whale measurement data
data("gw_data")

# filter for I2 drone and select specific widths to include for estimating body condition (20-70%)
gw_measurements <- gw_data %>% filter(uas == "P4P") %>% 
  select(!c("TL_w05.00_px", "TL_w10.00_px", "TL_w15.00_px", 
            "TL_w75.00_px", "TL_w80.00_px", "TL_w85.00_px", "TL_w90.00_px", "TL_w95.00_px"))

# identify the width columns in the dataset
width_names = grep(
  pattern = 'TL_w\\_*', 
  x = colnames(gw_measurements),
  value = TRUE
)

# view the data, note that some individuals have multiple images.
gw_measurements

## -----------------------------------------------------------------------------
# parse field study
whale_data = parse_observations(
  x = gw_measurements, 
  subject_col = 'whale_ID',
  meas_col = c('TL_px', width_names),
  image_col = 'image', 
  barometer_col = 'Baro_Alt',
  laser_col = 'Laser_Alt', 
  flen_col = 'Focal_Length_adj', 
  iwidth_col = 'Iw', 
  swidth_col = 'Sw', 
  uas_col = 'uas'
  #alt_conversion_col = 'altitude'
)

## -----------------------------------------------------------------------------
sampler = independent_length_sampler(
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
      data.frame(altimeter = 'Barometer', mean = 1, sd = 1e1),
      data.frame(altimeter = 'Laser', mean = 1, sd = 1e1)
    ),
    pixel_variance = c(shape = .01, rate = .01),
    object_lengths = c(min = .01, max = 20)
  )
)

## -----------------------------------------------------------------------------
# run sampler
output = sampler(niter = 1e6, thin = 10)

## -----------------------------------------------------------------------------
output$summaries$altimeters

## ----fig.dim = c(7, 5)--------------------------------------------------------
output$summaries$images %>% left_join(co_data %>% rename(Image = image), by = "Image") %>%
  ggplot() + theme_bw() + 
  geom_pointrange(aes(x = Baro_Alt, y = mean, ymin = lower, ymax = upper), color = "blue") +
  geom_abline(slope = 1, intercept = 0, lty = 2) + 
  ylab("posterior altitude (m)") + xlab("observed altitude (m)")


## -----------------------------------------------------------------------------
output$pixel_error$summary

## -----------------------------------------------------------------------------
head(output$summaries$objects)

## -----------------------------------------------------------------------------
output$summaries$objects %>% filter(Measurement == "TL_px")

## ----fig.dim = c(7, 5)--------------------------------------------------------
output$summaries$objects %>% filter(Measurement == "TL_px") %>% 
  ggplot() + theme_bw() + 
  geom_pointrange(aes(x = Subject, y = mean, ymin =lower, ymax = upper)) + 
  theme(axis.text.x = element_text(angle = 90, vjust = 1, hjust=1)) + 
  ylab("Total body length (m)") 

## -----------------------------------------------------------------------------
gw_data %>% filter(uas == "P4P") %>% 
  mutate(TL_m= Baro_Alt/Focal_Length_adj * Sw/Iw * TL_px) %>% select(c(whale_ID, TL_m))

## ----fig.dim = c(7, 5)--------------------------------------------------------
co_data_p4p %>% 
  mutate(alt_true = (CO.L*Focal_Length_adj)/((Sw/Iw)*Lpix),
         perDiff = ((Baro_Alt - alt_true)/alt_true)*100) %>%
  ggplot() + theme_bw() + 
  geom_point(aes(x = Baro_Alt, y = alt_true, color = perDiff)) + 
  geom_abline(intercept = 0, slope =1, lty = 2)

## -----------------------------------------------------------------------------
cal_sampler = calibration_sampler(
  data = calibration_data,
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
      data.frame(altimeter = 'Barometer', mean = 1, sd = 1e1),
      data.frame(altimeter = 'Laser', mean = 1, sd = 1e1)
    ),
    pixel_variance = c(shape = .01, rate = .01),
    object_lengths = c(min = .01, max = 20)
  ),
  # set to false to return sampler function
  package_only = FALSE
)

## -----------------------------------------------------------------------------
output_calibration = cal_sampler(niter = 1e6, thin = 10)

## -----------------------------------------------------------------------------
output_calibration$altimeters$`P4P Barometer`$summary

## -----------------------------------------------------------------------------
sampler = independent_length_sampler(
  data = combine_observations(calibration_data, whale_data),
  priors = list(
    image_altitude = c(min = 0.1, max = 130),
    altimeter_bias = rbind(
      #data.frame(altimeter = 'Barometer', mean = 0, sd = 1e-2)
      data.frame(altimeter = 'Barometer', mean = 0, sd = 1)
    ),
    altimeter_variance = rbind(
      data.frame(altimeter = 'Barometer', shape = .01, rate = .01)
    ),
    altimeter_scaling = rbind(
      #data.frame(altimeter = 'Barometer', mean = 1, sd = 1e-2)
      data.frame(altimeter = 'Barometer', mean = 1, sd = 0.1)
    ),
    pixel_variance = c(shape = .01, rate = .01),
    object_lengths = c(min = .01, max = 20)
  ),
  # set to false to return sampler function
  package_only = FALSE
)


## -----------------------------------------------------------------------------
output_informative = sampler(niter = 1e6, thin = 10)

## -----------------------------------------------------------------------------
output_informative$altimeters$`P4P Barometer`$summary

## -----------------------------------------------------------------------------
head(output_informative$summaries$objects)

## -----------------------------------------------------------------------------
output_informative$summaries$objects %>% filter(Measurement == "TL_px")

## ----fig.dim = c(7, 5)--------------------------------------------------------
output_informative$summaries$objects %>% filter(Measurement == "TL_px") %>% 
  ggplot() + theme_bw() + 
  geom_pointrange(aes(x = Subject, y = mean, ymin =lower, ymax = upper)) + 
  theme(axis.text.x = element_text(angle = 90, vjust = 1, hjust=1)) + 
  ylab("Total body length (m)") 

