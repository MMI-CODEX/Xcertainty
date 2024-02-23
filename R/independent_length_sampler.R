#' Build an MCMC sampler that uses calibration data to estimate independent,
#' unknown lengths
#' 
#' @import nimble
#'
#' @export
#' 
independent_length_sampler = function(data, priors) {
  
  validate_training_objects(data$training_objects)
  
  validate_prediction_objects(data$prediction_objects)
  
  # initialize analysis package
  pkg = flatten_data(data = data, priors = priors)
  
  #
  # set length priors
  #
  
  pkg$constants$n_basic_objects = nrow (data$prediction_objects)
  
  pkg$constants$prior_basic_object = matrix(
    data = priors$object_lengths, 
    nrow = pkg$constants$n_basic_objects,
    ncol = 2,
    byrow = TRUE
  )
  
  pkg$constants$basic_object_ind = data$prediction_objects %>% 
    left_join(
      y = pkg$maps$objects %>% mutate(ind = 1:n()),
      by = c('Subject', 'Measurement', 'Timepoint')
    ) %>% 
    select(ind) %>% 
    unlist() %>% 
    as.numeric()
  
  pkg$inits$object_length[pkg$constants$basic_object_ind] = apply(
    X = pkg$constants$prior_basic_object, 
    MARGIN = 1, 
    FUN = function(x) runif(n = 1, min = x[1], max = x[2])
  )
  
  
  #
  # build model
  #
  
  # TODO: extract the basic model building and compilation to a helper function
  # since this is extremely common code across models... basically, a 
  # "build_model" function that includes the initial pixel_count_expected info
  
  mod = nimbleModel(
    code = template_model, constants = pkg$constants, data = pkg$data, 
    inits = pkg$inits
  )
  
  cmod = compileNimble(mod)
  
  if(!is.finite(cmod$calculate())) {
    stop('Model does not have a finite likelihood')
  }
  
  #
  # build sampler
  #
  
  cfg = configureMCMC(mod)
  
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
    if(verbose) message('Extracting summaries')
    res$summaries = extract_summaries(res)
    res
  }
}
