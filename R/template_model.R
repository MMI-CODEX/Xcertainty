template_model = nimble::nimbleCode({
  
  #
  # measurement error model
  #
  
  # altimeter measurement error parameters
  for(i in 1:n_altimeters) {
    # TODO: add hierarcical centering for altimeter class/type?
    altimeter_bias[i] ~ dnorm(
      mean = prior_altimeter_bias[i, 1],
      sd = prior_altimeter_bias[i, 2]
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
      mean = image_altitude[altimeter_measurement_image[i]] + 
        altimeter_bias[altimeter_measurement_type[i]],
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
  
  # TODO: consider potential namespace issues if multiple models have 
  # overlapping parameter names and are all active
  # 
  # whale growth curve model, intended to be applied to an animal's total length
  if(n_growth_curve_subjects > 0) {
    
    # Growth curve parameters
    t0 ~ dnorm(mean = prior_t0[1], sd = prior_t0[2])
    K ~ dnorm(mean = prior_K[1], sd = prior_K[2])
    
    # TODO: consider replacing sex with a more generic "group" specification
    # Priors for mean growth curve asymptote and effect of birth year (by sex)
    for(sex in 1:2) {
      A[sex] ~ dnorm(
        mean = prior_A[sex, 1], 
        sd = prior_A[sex, 2]
      )
      upsilon[sex] ~ dnorm(
        mean = prior_upsilon[sex, 1], 
        sd = prior_upsilon[sex, 2]
      )
    }
    
    # Age offset for each individual (Cauchy prior) and birth year
    for (i in 1:n_growth_curve_subjects) {
      age_offset[i] ~ T(dt(0, 1, 1), 0, 40) 
      B[i] <- B_min[i] - age_type_i[i] * age_offset[i] - 1940
    }
    
    # Sex of individuals of unknown sex
    for (u in 1:N_sexNA) {
      sex[unk_sex[u]] ~ dcat(p_sex[1:2])
    }
    
    # Process error around mean asymptote (SD)
    sigma_A ~ dunif(0, 10) 
    
    # Break point (between 1990 and 2015, i.e. y = 50 and 75)
    delta ~ dunif(50, 75)
    
    # Individual-specific asymptote
    for (i in 1:N_inds) {
      b[i] <- breakFun(B[i], delta)
      A_i_mean[i] <- 
        b[i] * A[sex[i]] +
        (1 - b[i]) * (A[sex[i]] + upsilon[sex[i]] * 
                        (B[i] - delta))
      A_i[i] ~ dnorm(A_i_mean[i], sd = sigma_A)
    }
    
    
    ## Additional monitors
    
    # TODO: remove monitors from model, but post-processing functions that 
    # help compute the same information
    # 
    # Monitor relationship with birth year
    for (yy in 1:81) {
      b_pred[yy] <- breakFun(yy, delta)
      A_pred[yy, 1] <- 
        b_pred[yy] * A[1] +
        (1 - b_pred[yy]) * (A[1] + upsilon[1] * (yy - delta))
      A_pred[yy, 2] <- 
        b_pred[yy] * A[2] +
        (1 - b_pred[yy]) * (A[2] + upsilon[2] * (yy - delta))
    }
    
    
    ## Likelihood for growth model
    
    # Estimate length for each individual in each year
    for (j in 1:N_unknown_lengths_nc) {
      
      # Age (offset is fixed by individual)
      y[nc[j]] <- age_obs[nc[j]] + age_type[nc[j]] * age_offset[ind[nc[j]]]
      
      # Expected length based on growth model and individual-specific asyumptote
      object_length[L_unknown_inds[nc[j]]] <- 
        A_i[ind[nc[j]]] * 
        (1 - exp(-K * (y[nc[j]] - t0))) 
    }
    
    # Calves
    for (j in 1:N_calves) {
      object_length[L_unknown_inds[calves[j]]] ~ dunif(3.5,
                                           A_i[ind[calves[j]]] *
                                             (1 - exp(-K * (1 - t0))))
    }
    
    
  }
  
})
