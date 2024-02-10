devtools::document()

# load example wide-format data
data("calibration")
data("whales")

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
  uas_col = 'UAS'
)

sampler = build_sampler(
  data = combine_observations(calibration_data, whale_data),
  priors = list(
    altitude = c(min = 0.1, max = 130),
    lengths = c(min = 0, max = 30),
    bias = rbind(
      Barometer = c(mean = 0, sd = 1e2),
      Laser = c(mean = 0, sd = 1e2),
      Pixels = c(mean = 0, sd = 1e2)
    ),
    sigma = rbind(
      Barometer = c(shape = .01, rate = .01),
      Laser = c(shape = .01, rate = .01),
      Pixels = c(shape = .01, rate = .01)
    )
  )
)
