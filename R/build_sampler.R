#'
#'
#'
#' @export
#' 
build_sampler = function(data, priors, control = list()) {
  
  #
  # set configuration defaults
  #
  
  # TODO: redo this s.t. if control$barometer == FALSE, then we will simply 
  # remote barometer measurement data and altimeters from the model, etc.
  
  # use barometer altimeter data by default
  if(!('barometer' %in% names(control))) {
    control$barometer = TRUE
  }
  
  # use laser altimeter data by default
  if(!('laser' %in% names(control))) {
    control$laser = TRUE
  }
  
  #
  # build model
  #
  
  # initialize model package
  pkg = flatten_data(data = data, priors = priors)
  
  # what altitude data to use?
  pkg$consts$useBarometer = control$barometer
  pkg$consts$useLaser = control$laser
  
  # are there unknown lengths to estimate?
  pkg$consts$estimateLengths = pkg$consts$N_unknown_lengths > 0
  
  # initialize nimble model
  mod = nimbleModel(
    code = template_model, constants = pkg$consts, data = pkg$data, 
    inits = pkg$inits
  )
  
  
  #
  # build sampler
  #
  
  
  # TODO: build convenience functions to relabel model outputs, maybe also 
  # do some summarization
  
  browser()
  
}