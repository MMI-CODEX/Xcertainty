#' Build an MCMC sampler that only uses calibration data to estimate measurement 
#' error parameters
#'
#' @import nimble
#'
#' @export
#' 
calibration_sampler = function(data, priors) {
  
  validate_training_objects(data$training_objects)
  
  # exclude prediction objects from model
  data$prediction_objects = NULL
  
  # initialize analysis package
  pkg = flatten_data(data = data, priors = priors)
  
  #
  # set length priors
  #
  
  # for a training model, all lengths are known
  pkg$constants$n_basic_objects = 0
  pkg$constants$n_basic_object_length_constraints = 0
  pkg$constants$n_growth_curve_subjects = 0
  
  #
  # build model
  #
  
  # TODO: extract the basic model building and compilation to a helper function
  # since this is extremely common code across models... basically, a 
  # "build_model" function that includes the initial pixel_count_expected info
  
  # initialize nimble model
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
    res$altimeters = format_altimeter_output(
      pkg = pkg, samples = samples, post_inds = post_inds
    )
    if(verbose) message('Extracting image output')
    res$images = format_image_output(
      pkg = pkg, samples = samples, post_inds = post_inds
    )
    if(verbose) message('Extracting pixel error output')
    res$pixel_error = format_pixel_output(
      pkg = pkg, samples = samples, post_inds = post_inds
    )
    res
  }
}
