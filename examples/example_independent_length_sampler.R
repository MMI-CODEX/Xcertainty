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
    pixel_variance = c(shape = .01, rate = .01),
    # TODO: make this similar to altimeter_bias priors, in which we can set 
    # separate priors for each object if we desired
    object_lengths = c(min = .01, max = 20)
  )
)

output = sampler = (niter = 1e4)