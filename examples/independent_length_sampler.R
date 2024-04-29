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

sampler = independent_length_sampler(
  data = combine_observations(calibration_data, whale_data),
  priors = list(
    image_altitude = c(min = 0.1, max = 130),
    altimeter_bias = rbind(
      data.frame(altimeter = 'Barometer', mean = 0, sd = 1e2),
      data.frame(altimeter = 'Laser', mean = 0, sd = 1e2)
    ),
    altimeter_scaling = rbind(
      data.frame(altimeter = 'Barometer', mean = 1, sd = 1e2),
      data.frame(altimeter = 'Laser', mean = 1, sd = 1e2)
    ),
    altimeter_variance = rbind(
      data.frame(altimeter = 'Barometer', shape = .01, rate = .01),
      data.frame(altimeter = 'Laser', shape = .01, rate = .01)
    ),
    pixel_variance = c(shape = .01, rate = .01),
    object_lengths = c(min = .01, max = 20)
  )
)

output = sampler(niter = 1e2, thin = 1)

# 
# res = readRDS('tmp_out_independent_dt_2_1.rds')
# res = output
# output=res

# 
# investigate lengths
#

plot(mcmc(output$altimeters$`P4S Barometer`$samples))

plot(mcmc(output$altimeters$`I2F Laser`$samples))
plot(mcmc(output$altimeters$`I2F Laser`$samples[
  seq(
    from = nrow(output$altimeters$`I2F Laser`$samples)/2,
    to = nrow(output$altimeters$`I2F Laser`$samples)
  ),
]))

output$summaries$altimeters %>% 
  filter(parameter == 'variance')

imgs = whale_data$pixel_counts %>% 
  filter(
    Subject == '854',
    Timepoint == 2017
  ) %>% 
  left_join(
    y = whale_data$image_info,
    by = 'Image'
  ) %>%
  mutate(
    barometer_length = 
      PixelCount * Barometer * SensorWidth / ImageWidth / FocalLength,
    barometer_pX_length = 
      PixelCount * (Barometer-2) * SensorWidth / ImageWidth / FocalLength,
    laser_length = 
      PixelCount * Laser * SensorWidth / ImageWidth / FocalLength,
    hypothesized_length = 12,
    hypothesized_barometer_altitude = 
      hypothesized_length * FocalLength * ImageWidth / SensorWidth / PixelCount,
    hypothesized_barometer_error = Barometer - hypothesized_barometer_altitude
  ) %>% 
  select(
    Subject,
    Timepoint,
    Image,
    UAS,
    FocalLength,
    Barometer,
    Laser,
    barometer_length, 
    hypothesized_barometer_altitude,
    hypothesized_barometer_error,
    laser_length
  ) %>% 
  # View()
# so, for the 2017 data, if animal 854 were 12m long, then there would be a 
# near-constant 5m bias on the barometer altimeter.  the challenge is that the
# training data for the P4S don't provide that sort of evidence.  the training 
# data do provide evidence of errors that can be that large, but not 
# so consistently. maybe we don't have enough training data, or the right 
# training data?  or, if the focal lengths are 20% longer in reality, then this
# could also be an explanation.
#
# similarly, the 2019 image of animal 992 would have needed to have a 12m 
# altimeter error on a P4P uas if the animal was actually 12m.  we don't see 
# any errors like this in the calibration data, so we might really have an 
# uncaptured process impacting altimeters or something else in the data
# collection process on the water.  like, if it is barometer drift, you might 
# want to do data logging from a barometer on the boat the whole time you're 
# flying the drone.  if pressure changes dramatically during flight, this could 
# be a potential explanation.... is it possible to EDA for this by checking the 
# drone altimeter data at the start and end of these flights that seem sketchy?
# if there was substantial barometer drift during flight, then we should expect
# to see the takeoff and landing altitudes be very different.  again, we're 
# looking for changes that might be on the order of 5-15m.  we might not 
# otherwise be able to see barometer drift during flight since this would 
# manifest as altitude changes, and we might anticipate slow but steady changes
# to baseline barometric pressure, so changes might not be easily visible.  
# furthermore, for hovering, we wouldn't expect to see drift show up b/c the 
# drone will just be maintaining a relative pressure wrt its internal sensors.
# so, we won't necessarily be able to observe if the environment in which the 
# sensors are operating in is changing... unless, you might try to assess 
# presence of barometer drift by looking at laser altimeter data.  if you plot
# the difference between the laser and barometer altimeters over the duration 
# of a flight, you should ideally hope to see the difference be roughly 
# constant.  however, we might hypothesize a clear trend or mean shift if there
# is barometric drift during the flight.
# 
# so, maybe investigate the altimeter flight data associated with image 
# 220722_I2F_S4_U2_DJI0006_00_02_25_vlc00001.png.  this was a 2022 image of 
# animal 1256.  there is an 11m difference between the laser and barometer 
# readings for this image, so we might hypothesize this is a flight where 
# barometer drift occurred. 
#
# if we find evidence to support the hypothesis that barometric drift is 
# causing the bad readings, then we might conclude that severe barometric drift
# is a semi-rare occasion that cannot be directly accounted for from onboard
# barometer data alone.  it is essential to have laser altimeter as a backup
# (and our model is not currently set up to address drift like this), or 
# potentially to take barometric readings from the boat during flight too.  we 
# might also anticipate barometric drift could potentially be a problem in the 
# antarctic or other places where there are very localized temperature swings. 
# so, a gust of wind bringing cold air into the flight area briefly.  or, 
# if the micro-weather where the boat is relative to the whale is 
# dramatically different.  mostly, here, i'm suggesting temperature changes.
#
# i am encouraged via eda that barometric drift may be a potential issue since 
# we hypothesized that errors may be as large as 12m (i.e, whale 992 in 2019),
# and we found an image where that scale of error may be possible by directly
# comparing differences between laser and barometer altimeter readings.  we 
# also see, empirically, that these large differences are a rare occurrence,
# with differences over 10m only happening in .5% of our available image data.
# more moderate differences that can still have substantial impacts, differences
# greater than 4m, happen in ~5% of available image data.  such differences are 
# sufficient for creating the issues we see with whale 854 in 2017.  of course,
# since this happened to this whale consistently across a season, it suggests 
# there may be a systematic cause for the trouble vs. a completely random
# chance encounter.  so, again, perhaps something related to the types of 
# environments operations are taking place in.
  # ggplot(aes(x = hypothesized_barometer_altitude, Barometer)) +
  # geom_abline(slope = 1, intercept = 0, lty = 3) +
  # stat_smooth(method = 'lm') + 
  # geom_point() + 
  # coord_equal() + 
  # theme_few()
  # imgs
  # group_by(
  #   Timepoint
  # ) %>%
  # summarise(
  #   avg_barometer = mean(barometer_length),
  #   cv = sd(barometer_length) / avg_barometer,
  #   sd = sd(barometer_length),
  #   n = n()
  # ) %>%
  select(Image) %>% 
  unlist() %>% 
  unname()
  
  whale_data$image_info %>% 
    mutate(alt_diff = abs(Barometer - Laser)) %>% 
    filter(is.finite(alt_diff)) %>% 
    mutate(large_diff = alt_diff > 3) %>% 
    select(large_diff) %>% 
    unlist() %>% 
    mean() * 100
  
  whale_data$image_info %>% 
    mutate(alt_diff = abs(Barometer - Laser)) %>% 
    View()
  
  whale_data$image_info %>% 
    mutate(alt_diff = abs(Barometer - Laser)) %>% 
    ggplot(aes(x=alt_diff)) + 
    stat_density(geom = 'line') + 
    theme_few()
  
  res$images$`170626_P4S_S7_U4_NV_NT_vlc2.png`$summary %>% 
    mutate(
      mid_range = (upper-lower)/2
    )
  

res=output
plot(mcmc(res$images$`170905_P4S_S2_U3_NV_NT_vlc1.png`$samples))


tgt_image = '170626_P4S_S7_U4_NV_NT_vlc2.png'
plot(density(res$images[[tgt_image]]$samples))
qqnorm(res$images[[tgt_image]]$samples)
qqline(res$images[[tgt_image]]$samples)

# it looks like there should be more variability in the image altitudes than 
# we're seeing in the posteriors by a factor of 2
res$summaries$images %>% 
  filter(Image %in% imgs) %>% 
  mutate(
    half_range = (upper - lower)/2,
    upper_pct = (upper - mean)/mean
  ) %>% 
  arrange(half_range)

library(ggplot2)
library(ggthemes)

pl = output$summaries$objects %>% 
  filter(
    Subject %in% c('364','992','186','854','204','611','537','1237','1779')
  ) %>% 
  ggplot(aes(x = Timepoint, y = mean, ymin = lower, ymax = upper)) + 
  geom_pointrange() + 
  facet_wrap(~Subject, scales = 'free') + 
  theme_few()
  

ggsave(pl, filename = 'independent_sampler_long_output_scaling.png', width=10,height=10)
plot(mcmc(output$objects$`854 TL.pix 2016`$samples))

output$objects$`854 TL.pix 2016`$summary

res$altimeters$`P4S Barometer`$summary

summary(mcmc(1/res$altimeters$`P4S Barometer`$samples[,3]))

summary(mcmc(1/rexp(n = 1e6)))

# replace with 151, see what the +/- spread is.  for 1e6 it looks like 8m
altimeter_variance = rnorm(n = 13, mean = 18.97, sd = 4.42)
altimeter_bias = rnorm(n = length(altimeter_variance), mean = .628, sd = .816)
altimeter_measurement = rnorm(
  n = length(altimeter_variance), 
  mean = altimeter_bias, 
  sd = sqrt(altimeter_variance)
)
plot(density(na.omit(altimeter_measurement)))
diff(as.numeric(HPDinterval(mcmc(altimeter_measurement))))/2


res$altimeters$`P4S Barometer`$summary

library(ggplot2)
library(ggthemes)

calibration %>% 
  mutate(
    Altitude_calculated = CO.L * Focal_Length * Iw / Sw / Lpix,
    Altitude_error = Baro_Alt - Altitude_calculated,
    Altitude_error_pct = (Baro_Alt - Altitude_calculated) / Altitude_calculated
  )  %>%
  ggplot(aes(y = Altitude_calculated, x = Baro_Alt)) + 
  geom_abline(slope = 1, intercept = 0, lty = 3) + 
  geom_point() + 
  stat_smooth(method = 'lm', formula = 'y~x') + 
  facet_wrap(~uas) + 
  theme_few()


calibration %>% 
  mutate(
    Altitude_calculated = CO.L * Focal_Length * Iw / Sw / Lpix,
    Altitude_error = Baro_Alt - Altitude_calculated,
    Altitude_error_pct = (Baro_Alt - Altitude_calculated) / Altitude_calculated
  ) %>% 
  filter(
    uas == 'P4S'
  ) %>% 
  select(
    Altitude_error
  ) %>% 
  summary()
  lm(formula = Altitude_calculated~Baro_Alt) %>% 
  predict(newdata = data.frame(Baro_Alt=28))


res$summaries$altimeters %>% 
  filter(
    parameter == 'bias',
    altimeter == 'Barometer'
  ) %>% 
  arrange(UAS)


library(ggplot2)
errs = calibration %>% 
  filter(uas == "P4S") %>%
  mutate(
    Altitude_calculated = CO.L * Focal_Length * Iw / Sw / Lpix,
    Altitude_error = Baro_Alt - Altitude_calculated,
    Altitude_error_pct = (Baro_Alt - Altitude_calculated) / Altitude_calculated
  )  %>%
  select(Altitude_error) %>% 
  unlist()

plot(density(errs))
var(errs)

tgt_barometer = 'P4S Barometer'

var(nimble::rt_nonstandard(
  n = nrow(res$altimeters[[tgt_barometer]]$samples),
  df = 1/res$altimeters[[tgt_barometer]]$samples[,3], 
  sigma = sqrt(res$altimeters[[tgt_barometer]]$samples[,2]))
)

qqnorm(errs)
qqline(errs)

plot(density(errs))
curve(dnorm(x = x, mean = mean(errs), sd = sd(errs)), col = 2, add = TRUE)
  
  ggplot() + 
  geom_point(aes(x = Baro_Alt, y = Altitude_error_pct * 100, color = date)) + 
  theme_bw() + 
  ggtitle("P4S")


calibration %>% filter(uas == "P4S")


plot(density(scale(res$images$`170626_P4S_S7_U4_NV_NT_vlc2.png`$samples, center = TRUE, scale = FALSE)))
lines(density(scale(errs,center = TRUE,scale = FALSE)),col=2)

library(ggthemes)
ggplot() + 
  stat_density(
    data = data.frame(x = scale(res$images$`170626_P4S_S7_U4_NV_NT_vlc2.png`$samples, center = TRUE, scale = FALSE)),
    mapping = aes(x=x),
    geom='line'
  ) + 
  stat_density(
    data = data.frame(x = scale(errs, center = TRUE, scale = FALSE)),
    mapping = aes(x=x),
    col = 2,
    geom='line'
  ) + 
  geom_rug(
    mapping = aes(x=x),
    data = data.frame(x=scale(errs,center = TRUE, scale = FALSE))
  ) + 
  theme_few()

qqnorm(errs)
qqline(errs)



