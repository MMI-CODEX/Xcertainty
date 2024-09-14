library(stringr)
library(dplyr)

#
# parse data for Xcertainty
#

data("calibration2")
data("body_condition_measurements")

body_condition_measurements <- body_condition_measurements %>% 
  select(!c(TL.10.0..Width, TL.15.0..Width, TL.5.0..Width, TL.90.0..Width,
            TL.95.0..Width))

# parse calibration study
calibration_data = parse_observations(
  x = calibration2, 
  subject_col = 'L_train',
  meas_col = 'RRR.pix', 
  tlen_col = 'L_train', 
  image_col = 'Images', 
  barometer_col = 'Baro...Ht',
  laser_col = 'Laser_Alt', 
  flen_col = 'Focal.length', 
  iwidth_col = 'Iw', 
  swidth_col = 'Sw',
  uas_col = 'Aircraft'
)

# identify the width columns in the dataset
width_names = grep(
  pattern = 'TL\\..*', 
  x = colnames(body_condition_measurements),
  value = TRUE
)

# parse whale data
whale_data = parse_observations(
  x = body_condition_measurements, #[1:5,], 
  subject_col = 'Animal_ID', 
  meas_col = c('TL', width_names), 
  image_col = 'Image', 
  barometer_col = 'BaroAlt',
  laser_col = 'LaserAlt', 
  flen_col = 'Focal_Length', 
  iwidth_col = 'Iw', 
  swidth_col = 'Sw', 
  uas_col = 'Aircraft', 
  alt_conversion_col = 'BaroAlt'
)

#
# fit a basic model or load model output
# 

if(interactive()) {
  
  # build sampler
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
  
  # run sampler
  body_condition_measurement_estimates = sampler(niter = 1e4, thin = 10)
  
} else {
  data("body_condition_measurement_estimates")
}


#
# post-process data
#

# enumerate the width locations along the animal's length
width_increments = as.numeric(
  str_extract(
    string = width_names, 
    pattern = '[0-9]+'
  )
)

# compute body condition scores
body_condition_output = body_condition(
  data = whale_data, 
  output = body_condition_measurement_estimates,
  length_name = 'TL',
  width_names = width_names,
  width_increments = width_increments,
  summary.burn = .5
)


body_condition_output$summaries
