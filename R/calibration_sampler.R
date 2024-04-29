#' Build an MCMC sampler for calibration data
#' 
#' Build an MCMC sampler that only uses calibration data to estimate measurement 
#' error parameters
#' 
#' Description text
#'
#' @param data xxxxx
#' 
#' @import nimble
#'
#' @example  examples/example_calibration_sampler.R
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
calibration_sampler = function(data, priors) {
  
  validate_training_objects(data$training_objects)
  
  # exclude prediction objects from model
  data$prediction_objects = NULL
  
  # initialize analysis package
  pkg = flatten_data(data = data, priors = priors)
  
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
    if(verbose) message('Extracting summaries')
    res$summaries = extract_summaries(res)
    res
  }
}
