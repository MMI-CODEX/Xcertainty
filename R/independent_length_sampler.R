#' MCMC sampler for individuals with independent measurements.
#' 
#' Build an MCMC sampler that uses calibration data to estimate independent,
#' unknown measurements. This model assumes all Subject/Measurement/Timepoint 
#' combinations are independent. So, this sample is well suited for data 
#' containing individuals that either have no replicate samples or 
#' have replicate samples that are independent over time, such as body condition 
#' which can increase or decrease over time, as opposed to length which should 
#' be stable or increase over time. It can also be used to estimate lengths 
#' when there are replicate measurements. However, since the model assumes all 
#' Subject/Measurement/Timepoint combinations are independent, no strength will 
#' be borrowed across temporal replication of a subject's measurements, 
#' for example.
#' 
#' @importFrom stats runif
#' 
#' @importFrom nimble nimbleModel
#' @importFrom nimble compileNimble
#' @importFrom nimble configureMCMC
#' @importFrom nimble buildMCMC
#' 
#' @example examples/example_independent_length_sampler.R
#' 
#' @param data Photogrammetric data formatted for Xcertainty models, required to
#'   be an object with class \code{obs.parsed}, which can be obtained by running
#'   \code{parse_observations()}
#' @param priors \code{list} with components that define the model's prior 
#'   distribution.  See \code{help("flatten_data")} for more details.
#' @param package_only \code{TRUE} to return the formatted data used to build 
#'   the sampler, otherwise \code{FALSE} to return the sampler
#' 
#' @return outputs a function to run a sampler, the function arguments are: 
#' \describe{
#'  \item{niter}{set the number of iterations}
#'  \item{burn}{set the number samples to discard}
#'  \item{thin}{set the thinning rate}
#'  }
#'
#' @export
#' 
independent_length_sampler = function(data, priors, package_only = FALSE) {
  
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
    select(.data$ind) %>% 
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
  
  # early return
  if(package_only) return(pkg)
  
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
