template_model = nimble::nimbleCode({
  
  #
  # measurement error model
  #
  
  # altimeter measurement error parameters
  for(i in 1:n_altimeters) {
    altimeter_bias[i] ~ dnorm(
      mean = prior_altimeter_bias[i, 1],
      sd = prior_altimeter_bias[i, 2]
    )
    altimeter_scaling[i] ~ dnorm(
      mean = prior_altimeter_scaling[i, 1],
      sd = prior_altimeter_scaling[i, 2]
    )
    altimeter_variance[i] ~ dinvgamma(
      shape = prior_altimeter_variance[i, 1],
      rate = prior_altimeter_variance[i, 2]
    )
  }
  
  # priors for true altitudes (1:1 relationship with each image)
  for(i in 1:n_images) {
    image_altitude[i] ~ dunif(
      min = prior_image_altitude[1], 
      max = prior_image_altitude[2]
    )
  }
  
  # observation model for altimeter measurements
  for(i in 1:n_altimeter_measurements) {
    altimeter_measurement[i] ~ dnorm(
      mean = altimeter_bias[altimeter_measurement_type[i]] + 
        image_altitude[altimeter_measurement_image[i]] *
        altimeter_scaling[altimeter_measurement_type[i]],
      var = altimeter_variance[altimeter_measurement_type[i]]
    )
  }
  
  # pixel measurement error parameters (assumed identical across UAS types)
  pixel_variance ~ dinvgamma(
    shape = prior_pixel_variance[1], 
    rate = prior_pixel_variance[2]
  )
  
  # observation model for pixel counts
  for(i in 1:n_pixel_counts) {
    # object pixel length without measurement error
    pixel_count_expected[i] <- 
      object_length[pixel_count_expected_object[i]] *
      image_focal_length[pixel_count_expected_image[i]] *
      image_width[pixel_count_expected_image[i]] /
      image_sensor_width[pixel_count_expected_image[i]] /
      image_altitude[pixel_count_expected_image[i]]
    # observed pixel length
    pixel_count_observed[i] ~ dnorm(
      mean = pixel_count_expected[i],
      var = pixel_variance
    )
  }
  
  #
  # subject/length models
  #
  
  # Strategy: we will have a single object_length vector, and we will use 
  # different looping sub-structures to specify different types of priors for 
  # the different length variables.  so, some may be a simple prior, whereas 
  # others may have more complex growth curves
  
  # basic objects have non-specific, independent uniform length priors
  if(n_basic_objects > 0) {
    for(i in 1:n_basic_objects) {
      object_length[basic_object_ind[i]] ~ dunif(
        min = prior_basic_object[i, 1],
        max = prior_basic_object[i, 2]
      )
    }
  }
  
  # we can add simple order constraints to specific objects, for example, to 
  # 1) non-parametrically model non-decreasing growth over time, 2) assumptions 
  # that one type of width measurement should always be larger than another, or
  # 3) that a subject's length should be larger than its width
  if(n_basic_object_length_constraints > 0) {
    for(i in 1:n_basic_object_length_constraints) {
      basic_object_length_constraint[i] ~ dconstraint(
        object_length[basic_object_length_constraint_ind[i, 2]] >=
        object_length[basic_object_length_constraint_ind[i, 1]]
      )
    }
  }
   
  # whale growth curve model, intended to be applied to an animal's total length
  if(n_growth_curve_subjects > 0) {
    
    
    # (common) growth curve temporal "intercept"
    zero_length_age ~ dnorm(
      mean = prior_zero_length_age[1], sd = prior_zero_length_age[2]
    )
    
    # (common) growth curve growth rate
    growth_rate ~ dnorm(
      mean = prior_growth_rate[1], sd = prior_growth_rate[2]
    )
    
    # priors for group-level, average asymptotic sizes and temporal trends
    for(i in 1:n_groups) {
      group_asymptotic_size[i] ~ dnorm(
        mean = prior_group_asymptotic_size[i, 1], 
        sd = prior_group_asymptotic_size[i, 2]
      )
      group_asymptotic_size_trend[i] ~ dnorm(
        mean = prior_group_asymptotic_size_trend[i, 1],
        sd = prior_group_asymptotic_size_trend[i, 2]
      )
    }
    
    # missing demographic information for some individuals
    if(n_missing_subject_groups > 0) {
      for(i in 1:n_missing_subject_groups) {
        subject_group[unknown_subject_group[i]] ~ dcat(
          subject_group_distribution[1:n_groups]
        )
      }
    }
      
    # demographic information for each individual
    for(i in 1:n_growth_curve_subjects) {
      # Age offset and birth year for each individual (Cauchy prior)
      subject_age_offset[i] ~ T(dt(0, 1, 1), 0, 40) 
      subject_birth_year[i] <- 
        subject_birth_year_minimum[i] - 
        subject_age_type[i] * subject_age_offset[i]
    }
    
    # individual variation around average asymptotic sizes
    asymptotic_size_sd ~ dunif(
      min = prior_asymptotic_size_sd[1], max = prior_asymptotic_size_sd[2]
    )
    
    # year when growth curve shifts (i.e., break point)
    group_size_shift_start_year ~ dunif(
      min = prior_group_size_shift_start_year[1], 
      max = prior_group_size_shift_start_year[2]
    )
    
    # Individual-level asymptotic sizes
    for(i in 1:n_growth_curve_subjects) {
      # is individual asymptotic size based on pre or post-breakpoint model?
      asymptotic_model_indicator[i] <- breakFun(
        subject_birth_year[i], 
        group_size_shift_start_year
      )
      # realized group-level, average asymptotic sizes and temporal trends
      expected_subject_asymptotic_size[i] <- 
        asymptotic_model_indicator[i] * 
          group_asymptotic_size[subject_group[i]] +
        (1 - asymptotic_model_indicator[i]) * (
          group_asymptotic_size[subject_group[i]] + 
          group_asymptotic_size_trend[subject_group[i]] * 
            (subject_birth_year[i] - group_size_shift_start_year)
        )
      # individual-level asymptotic size
      subject_asymptotic_size[i] ~ dnorm(
        mean = expected_subject_asymptotic_size[i], sd = asymptotic_size_sd
      )
    }
    
    if(n_non_calf_lengths > 0) {
      for(i in 1:n_non_calf_lengths) {
        non_calf_length_age[i] <- non_calf_length_age_obs[i] + 
          non_calf_length_age_type[i] * 
          subject_age_offset[non_calf_length_subject[i]]
        object_length[non_calf_length[i]] <- 
          subject_asymptotic_size[non_calf_length_subject[i]] * (
            1 - exp( -growth_rate * (non_calf_length_age[i] - zero_length_age) )
          )
      }
    }
    
    if(n_calf_lengths > 0) {
      for(i in 1:n_calf_lengths) {
        object_length[calf_length[i]] ~ dunif(
          min = min_calf_length,
          max = subject_asymptotic_size[calf_length_subject[i]] * (
            1 - exp( -growth_rate * (1 - zero_length_age) )
          )
        )
      }
    }
    
  }
  
})
