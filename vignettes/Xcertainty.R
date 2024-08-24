## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ---- echo=FALSE, warning=FALSE, message =FALSE-------------------------------
library(Xcertainty)

library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)

#devtools::build_vignettes()

## -----------------------------------------------------------------------------
CO_data <- readRDS(file.path('..', 'data', "CO_data_ex1"))

CO_data <- CO_data %>% filter(uas == "I2F")

table(CO_data$uas)

## -----------------------------------------------------------------------------
calibration_data = parse_observations(
  x = CO_data, 
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
gw_data <- readRDS(file.path('..', 'data', "GW_data_ex1"))

gw_measurements <- gw_data %>% filter(uas == "I2F") %>%
  select(!c("TL_w05.00_px", "TL_w10.00_px", "TL_w15.00_px", 
            "TL_w75.00_px", "TL_w80.00_px", "TL_w85.00_px", "TL_w90.00_px", "TL_w95.00_px"))

# identify the width columns in the dataset
width_names = grep(
  pattern = 'TL_w\\_*', 
  x = colnames(gw_measurements),
  value = TRUE
)

## -----------------------------------------------------------------------------
# parse field study
whale_data = parse_observations(
  x = gw_measurements, 
  subject_col = 'whale_ID',
  meas_col = c('TL_px', width_names),
  image_col = 'image', 
  barometer_col = 'Baro_Alt',
  laser_col = 'Laser_Alt', 
  flen_col = 'Focal_Length', 
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
  ),
  # set to false to return sampler function
  package_only = FALSE
)

## -----------------------------------------------------------------------------
# run sampler
output = sampler(niter = 1e6, thin = 10)

## -----------------------------------------------------------------------------
head(output$summaries$objects)

## -----------------------------------------------------------------------------
output$summaries$objects %>% filter(Measurement == "TL_px")

## -----------------------------------------------------------------------------
output$summaries$objects %>% filter(Subject == "GW_01")

## ---- fig.dim = c(7, 5)-------------------------------------------------------
output$summaries$objects %>% filter(Measurement == "TL_px") %>% 
  ggplot() + theme_bw() + 
  geom_pointrange(aes(x = Subject, y = mean, ymin =lower, ymax = upper)) + 
  theme(axis.text.x = element_text(angle = 90, vjust = 1, hjust=1)) + 
  ylab("Total body length (m)") 

## ---- fig.dim = c(6, 6)-------------------------------------------------------
library(ggdist)

ID_samples <- output$objects$`GW_01 TL_px 1`$samples

data.frame(TL = ID_samples[(length(ID_samples)/2):length((ID_samples))]) %>%
  ggplot() + stat_halfeye(aes(TL), .width = 0.95) + theme_bw() 

## -----------------------------------------------------------------------------
output$summaries$altimeters

## -----------------------------------------------------------------------------
head(output$summaries$images)

## -----------------------------------------------------------------------------
output$pixel_error$summary

## -----------------------------------------------------------------------------
# First, enumerate the width locations along the animal's length
width_increments = as.numeric(
  str_extract(
    string = width_names, 
    pattern = '[0-9]+'
  )
)

# Compute body condition
body_condition_output = body_condition(
  data = whale_data, 
  output = output,
  length_name = 'TL_px',
  width_names = width_names,
  width_increments = width_increments,
  summary.burn = .5
)

## -----------------------------------------------------------------------------
head(body_condition_output$summaries$body_area_index)

## ---- fig.dim = c(7, 5)-------------------------------------------------------
body_condition_output$summaries$body_area_index %>% 
  ggplot() + theme_bw() + 
  geom_pointrange(aes(x = Subject, y = mean, ymin =lower, ymax = upper)) + 
  theme(axis.text.x = element_text(angle = 90, vjust = 1, hjust=1)) + 
  ylab("Body Area Index") 

## -----------------------------------------------------------------------------
head(body_condition_output$summaries$body_volume)

## ---- fig.dim = c(7, 5)-------------------------------------------------------
body_condition_output$summaries$body_volume %>% 
  ggplot() + theme_bw() + 
  geom_pointrange(aes(x = Subject, y = mean, ymin =lower, ymax = upper)) + 
  theme(axis.text.x = element_text(angle = 90, vjust = 1, hjust=1)) + 
  ylab("Body Volume (m^3)") 

## -----------------------------------------------------------------------------
body_condition_output$summaries$standardized_widths %>% filter(Subject == "GW_01")

## ---- fig.dim = c(7, 5)-------------------------------------------------------
body_condition_output$summaries$standardized_widths$metric <- gsub("standardized_widths TL_", "", body_condition_output$summaries$standardized_widths$metric)

body_condition_output$summaries$standardized_widths %>% filter(Subject == "GW_01") %>%
  ggplot() + theme_bw() + 
  geom_pointrange(aes(x = metric, y = mean, ymin = lower, ymax = upper)) + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + 
  xlab("width%") + ylab("standardized width") + ggtitle("GW_01") 

## ---- fig.dim = c(7, 5)-------------------------------------------------------
body_condition_output$summaries$standardized_widths %>% 
  ggplot() + theme_bw() + 
  geom_boxplot(aes(x = metric, y = mean)) + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + 
  xlab("width%") + ylab("standardized width")

## -----------------------------------------------------------------------------
head(body_condition_output$body_area_index$`GW_01`$samples)

## ---- fig.dim = c(6, 6)-------------------------------------------------------
library(ggdist)

ID_samples <- output$objects$`GW_01 TL_px 1`$samples

data.frame(BAI = ID_samples[(length(ID_samples)/2):length((ID_samples))]) %>%
  ggplot() + stat_halfeye(aes(BAI), .width = 0.95) + theme_bw() + ggtitle("GW_01")

