devtools::document()

# load example wide-format data
data("calibration")
data("whales")
data("whale_info")

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
    year_minimum = 1940,
    group_size_shift_start_year = c(min = 50, max = 75)
  ),
  subject_info = whale_info
)

output = sampler(niter = 1e5)

# KCB: saving output to compare with other samplers in 'Output_play.Rmd'
output_growth <- output

# let's save all the sampler outputs 
save(output, file = file.path("..", "kcb_outputs/dataframes/growth_outputs_240416.rda"))
output = sampler(niter = 1e4)

plot(mcmc(output$growth_curve$growth_rate$samples))

output$growth_curve$growth_rate$summary
.181
# hasn't converged yet with O(1e4) samples, growth_rate parameter keeps increasing

plot(mcmc(output$growth_curve$subject_asymptotic_size$samples))

output$growth_curve$growth_rate$summary
output$growth_curve$subject_asymptotic_size$summary
output$summaries$altimeters %>% 
  filter(parameter == 'variance')

whale_data$pixel_counts %>% 
  filter(
    Subject == '364'
  ) %>% 
  left_join(
    y = whale_data$image_info,
    by = 'Image'
  ) %>% 
  mutate(
    barometer_length = 
      PixelCount * Barometer * SensorWidth / ImageWidth / FocalLength,
    barometer_pX_length = 
      PixelCount * (Barometer+1) * SensorWidth / ImageWidth / FocalLength,
    laser_length = 
      PixelCount * Laser * SensorWidth / ImageWidth / FocalLength
  ) %>% 
  select(
    Timepoint,
    Image,
    UAS,
    Barometer,
    Laser,
    barometer_length, 
    barometer_pX_length,
    laser_length
  ) %>% 
  # group_by(
  #   Timepoint
  # ) %>%
  # summarise(
  #   # min_barometer = min(barometer_length),
  #   avg_barometer = mean(barometer_length),
  #   # max_barometer = max(barometer_length),
  #   cv = sd(barometer_length) / avg_barometer,
  #   sd = sd(barometer_length),
  #   n = n()
  # ) %>% 
  View()


# 854, large uncty, but 2017 measurements just looked off, so what's up with that?
