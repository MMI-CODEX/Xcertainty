#' MCMC sampler for measurements of individuals with replicates and age information to generate growth curve
#' 
#' Build an MCMC sampler that uses calibration data to estimate independent,
#' unknown measurements. This sampler is well suited for when individuals have 
#' replicate measurements across time points and also have age information.
#' This sampler uses these replicate samplers and age information to build 
#' a von-Bertalanffy-Putter growth model, following Pirotta & Bierlich et al., (in revision)
#' 
#' @import nimble
#' 
#' @example examples/example_growth_curve_sampler.R
#' 
#'
#' @return outputs a function to run a sampler, the function arguments are: 
#' \describe{
#'  \item{niter}{set the number of iterations}
#'  \item{burn}{set the number samples to discard}
#'  \item{thin}{set the thinning rate}
#'  }
#'
#'
#' @export
#' 
growth_curve_sampler = function(data, priors, subject_info) {
  
  validate_training_objects(data$training_objects)
  
  validate_prediction_objects(data$prediction_objects)
  
  # validate subject-group information
  ambiguous_subject_group_info = subject_info %>% 
    group_by(Subject) %>% 
    summarise(ngroups = length(unique(Group))) %>% 
    filter(ngroups > 1)
  if(nrow(ambiguous_subject_group_info) > 0) {
    stop('Subjects in argument "subject_info" must have one group definition')
  }
  
  # initialize analysis package
  pkg = flatten_data(data = data, priors = priors)
  
  #
  # configure growth curve model
  #
  
  pkg$maps$growth_curve = list()
  
  pkg$maps$growth_curve$subjects = unique(subject_info$Subject)
  
  pkg$constants$n_growth_curve_subjects = length(pkg$maps$growth_curve$subjects)
  
  pkg$constants$prior_zero_length_age = priors$zero_length_age
  
  pkg$inits$zero_length_age = pkg$constants$prior_zero_length_age['mean']
  
  pkg$constants$prior_growth_rate = priors$growth_rate
  
  pkg$inits$growth_rate = pkg$constants$prior_growth_rate['mean']
  
  # identify groups, excluding NA's
  pkg$maps$growth_curve$groups = unique(subject_info$Group)
  pkg$maps$growth_curve$groups = pkg$maps$growth_curve$groups[
    !is.na(pkg$maps$growth_curve$groups)
  ]
  
  pkg$constants$n_groups = length(pkg$maps$growth_curve$groups)
  
  pkg$constants$prior_group_asymptotic_size = priors$group_asymptotic_size[
    pkg$maps$growth_curve$groups,
  ]
  
  pkg$inits$group_asymptotic_size = pkg$constants$prior_group_asymptotic_size[
    , 'mean'
  ]
  
  pkg$constants$prior_group_asymptotic_size_trend = 
    priors$group_asymptotic_size_trend[pkg$maps$growth_curve$groups,]
  
  pkg$inits$group_asymptotic_size_trend = 
    pkg$constants$prior_group_asymptotic_size_trend[, 'mean']
  
  pkg$inits$subject_group = data.frame(
    Subject = pkg$maps$growth_curve$subjects
  ) %>% 
    left_join(
      y = subject_info %>% 
        select(Subject, Group) %>% 
        unique(),
      by = 'Subject'
    ) %>% 
    left_join(
      y = data.frame(Group = pkg$maps$growth_curve$groups) %>% 
        mutate(group_ind = 1:n()),
      by = 'Group'
    ) %>% 
    select(group_ind) %>% 
    unlist() %>% 
    unname()
  
  pkg$constants$subject_group_distribution = priors$subject_group_distribution[
    pkg$maps$growth_curve$groups
  ]
  
  pkg$constants$unknown_subject_group = which(is.na(pkg$inits$subject_group))
  
  pkg$constants$n_missing_subject_groups = length(
    pkg$constants$unknown_subject_group
  )
  
  pkg$inits$subject_group[
    pkg$constants$unknown_subject_group
  ] = sample(
    x = seq_along(pkg$maps$growth_curve$groups), 
    size = pkg$constants$n_missing_subject_groups, 
    replace = TRUE
  )
  
  pkg$constants$year_minimum = priors$year_minimum
  
  pkg$maps$growth_curve$age_type = data.frame(
    AgeType = c('known age', 'min age'),
    AgeTypeValue = c(0, 1)
  )
  
  # summarize minimum birth year data by subject
  df = data.frame(
    Subject = pkg$maps$growth_curve$subjects
  ) %>% 
    left_join(
      y = subject_info %>% 
        mutate(min_birth_year = Year - ObservedAge) %>% 
        group_by(Subject) %>%
        arrange(AgeType, min_birth_year) %>% 
        slice(1) %>% 
        ungroup(),
      by = 'Subject'
    ) %>%
    left_join(
      y = pkg$maps$growth_curve$age_type,
      by = 'AgeType'
    )
  
  pkg$constants$subject_birth_year_minimum = df$min_birth_year
  
  pkg$inits$subject_age_offset = rep(1, pkg$constants$n_growth_curve_subjects)
  
  pkg$constants$subject_age_type = df$AgeTypeValue
  
  pkg$constants$prior_asymptotic_size_sd = priors$asymptotic_size_sd
  
  pkg$inits$asymptotic_size_sd = mean(pkg$constants$prior_asymptotic_size_sd)
  
  pkg$constants$prior_group_size_shift_start_year = 
    priors$group_size_shift_start_year
  
  pkg$inits$group_size_shift_start_year = mean(
    pkg$constants$prior_group_size_shift_start_year
  )
  
  pkg$inits$subject_asymptotic_size = pkg$inits$group_asymptotic_size[
    pkg$inits$subject_group
  ] %>% unname()
  pkg$inits$subject_asymptotic_size[is.na(pkg$inits$subject_asymptotic_size)] =
    mean(pkg$inits$subject_asymptotic_size, na.rm = TRUE)
  
  # enrich object lengths with additional subject information
  df = pkg$maps$objects %>% 
    mutate(
      object_ind = 1:n()
    ) %>% 
    left_join(
      y = subject_info %>% mutate(Subject = as.character(Subject)),
      by = c('Subject', 'Timepoint' = 'Year')
    ) %>% 
    mutate(
      is_calf = (ObservedAge == 0) & (AgeType == 'known age')
    ) %>% 
    left_join(
      y = pkg$maps$growth_curve$age_type,
      by = 'AgeType'
    ) %>% 
    left_join(
      y = data.frame(Subject = as.character(pkg$maps$growth_curve$subjects)) %>% 
        mutate(subject_ind = 1:n()),
      by = 'Subject'
    )
  
  # process length measurements of non-calves
  non_calf_objects = df %>% filter(is_calf == FALSE)
  pkg$constants$n_non_calf_lengths = nrow(non_calf_objects)
  pkg$constants$non_calf_length_age_obs = non_calf_objects$ObservedAge
  pkg$constants$non_calf_length_age_type = non_calf_objects$AgeTypeValue
  pkg$constants$non_calf_length_subject = non_calf_objects$subject_ind
  pkg$constants$non_calf_length = non_calf_objects$object_ind
  
  # process length measurements of calves
  calf_objects = df %>% filter(is_calf == TRUE)
  pkg$constants$n_calf_lengths = nrow(calf_objects)
  pkg$constants$calf_length = calf_objects$object_ind
  pkg$constants$calf_length_subject = calf_objects$subject_ind
  
  pkg$constants$min_calf_length = priors$min_calf_length
  
  pkg$inits$object_length[pkg$constants$calf_length] = 
    pkg$constants$min_calf_length
  
  #
  # build model
  #
  
  mod = nimbleModel(
    code = template_model, constants = pkg$constants, data = pkg$data, 
    inits = pkg$inits
  )
  
  cmod = compileNimble(mod)
  
  if(!is.finite(cmod$calculate())) {
    ll = sapply(cmod$getNodeNames(), function(x) cmod$calculate(x))
    non_finite_nodes = names(ll[!is.finite(ll)])
    non_finite_node_groups = unique(gsub(
      pattern = '\\[.*\\]', replacement = '', x = non_finite_nodes
    ))
    stop('Model does not have a finite likelihood')
  }
  
  #
  # build sampler
  #
  
  cfg = configureMCMC(mod)
  
  cfg$addMonitors(
    c('subject_birth_year', 'subject_asymptotic_size', 'non_calf_length_age',
      'object_length')
  )
  
  sampler = buildMCMC(cfg)
  
  csampler = compileNimble(sampler)
  
  function(niter, thin = 1, summary.burn = .5, verbose = TRUE) {
    if(verbose) message('Sampling')
    csampler$run(
      niter = niter, resetMV = TRUE, thin = thin, progressBar = verbose
    )
    samples = as.matrix(csampler$mvSamples)
    post_inds = seq(from = nrow(samples) * summary.burn, to = nrow(samples))
    res = list()
    if(verbose) message('Extracting altimeter output')
    res$altimeters = format_altimeter_output(pkg, samples, post_inds)
    if(verbose) message('Extracting image output')
    res$images = format_image_output(pkg, samples, post_inds)
    if(verbose) message('Extracting pixel error output')
    res$pixel_error = format_pixel_output(pkg, samples, post_inds)
    if(verbose) message('Extracting object output')
    res$objects = format_object_output(
      pkg, samples, post_inds, data$prediction_objects
    )
    if(verbose) message('Extracting growth curve model output')
    res$growth_curve = format_growth_curve_output(
      pkg, samples, post_inds
    )
    if(verbose) message('Extracting summaries')
    res$summaries = extract_summaries(res)
    res
  }
}
