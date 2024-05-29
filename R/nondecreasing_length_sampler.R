#' MCMC sampler for measurements of individuals with replicates but no age information.
#' 
#' Build an MCMC sampler that uses calibration data to estimate measurements 
#' that are assumed to be non-decreasing in time.  This sampler is well suited 
#' for when individuals have replicate measurements across time points but do 
#' not have age information.  The model estimates changes in unique combinations 
#' of Subject/Measurement pairs over Timepoints.
#' 
#' @importFrom stats runif
#' 
#' @importFrom nimble nimbleModel
#' @importFrom nimble compileNimble
#' @importFrom nimble configureMCMC
#' @importFrom nimble buildMCMC
#'
#' @example examples/example_nondecreasing_length_sampler.R
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
nondecreasing_length_sampler = function(data, priors, package_only = FALSE) {
  
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
  
  # preliminarily initialize object lengths
  pkg$inits$object_length[pkg$constants$basic_object_ind] = apply(
    X = pkg$constants$prior_basic_object, 
    MARGIN = 1, 
    FUN = function(x) runif(n = 1, min = x[1], max = x[2])
  )
  
  # identify objects to model with non-decreasing lengths over time
  temporal_targets = data$prediction_objects %>% 
    group_by(.data$Subject, .data$Measurement) %>% 
    summarise(number_timepoints = n()) %>% 
    ungroup() %>%
    filter(.data$number_timepoints > 1) %>% 
    select(.data$Subject, .data$Measurement)
  
  # encode non-decreasing length constraints; re-initialize impacted objects
  if(nrow(temporal_targets) > 0) {
    # initialize non-decreasing length constraint definitions in model
    pkg$constants$basic_object_length_constraint_ind = matrix(
      nrow = 0, ncol = 2
    )
    # add non-decreasing length constraints to model
    for(row_ind in 1:nrow(temporal_targets)) {
      # object ids in order of non-decreasing length
      object_ordering = temporal_targets[row_ind,] %>% 
        left_join(
          y = pkg$maps$objects %>% mutate(ind = 1:n()),
          by = c('Subject', 'Measurement')
        ) %>% 
        arrange(.data$Timepoint) %>% 
        select(.data$ind) %>% 
        unlist()  %>% 
        as.numeric()
      # organize into a constraint definition matrix
      object_constraints = cbind(
        object_ordering[1:(length(object_ordering)-1)], object_ordering[-1]
      )
      # append constraints to model
      pkg$constants$n_basic_object_length_constraints = 
        pkg$constants$n_basic_object_length_constraints + 
        nrow(object_constraints)
      pkg$constants$basic_object_length_constraint_ind = rbind(
        pkg$constants$basic_object_length_constraint_ind,
        object_constraints
      )
      # re-sort inits so they respect the non-decreasing constraints
      pkg$inits$object_length[object_constraints] = sort(
        pkg$inits$object_length[object_constraints]
      )
    }
    # finish nimble specification for non-decreasing length constraint
    pkg$data$basic_object_length_constraint = rep(
      1, pkg$constants$n_basic_object_length_constraints
    )
  }
  
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
    ll = sapply(cmod$getNodeNames(), function(x) cmod$calculate(x))
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
