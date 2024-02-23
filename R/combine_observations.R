#' Combine parsed observations into a single parsed object
#' 
#' @example examples/parse_observations.R
#' 
#' @param ... Parsed datasets to combine (i.e., outputs from 
#'   \code{Xcertainty::parsed_observations})
#' 
#' @export
#' 
combine_observations = function(...) {
  
  # collect arguments
  x = list(...)
  
  # validate input
  for(i in seq_along(x)) {
    if(!inherits(x[[i]], 'obs.parsed')) {
      stop(paste('Argument', i, 'is not output from parse_observations()'))
    }
  }
  
  # combine arguments
  res = list(
    pixel_counts = do.call(rbind, lapply(x, function(x) x$pixel_counts)),
    training_objects = do.call(rbind, lapply(x, function(x) x$training_objects)),
    prediction_objects = do.call(rbind, lapply(x, function(x) x$prediction_objects)),
    image_info = do.call(rbind, lapply(x, function(x) x$image_info))
  )
  
  #
  # validate combined data
  #

  validate_pixel_counts(res$pixel_counts)

  if(!is.null(res$training_objects)) {
    validate_training_objects(res$training_objects)
  }
  
  if(!is.null(res$prediction_objects)) {
    validate_prediction_objects(res$prediction_objects)
  }
  
  validate_image_info(res$image_info)

  # package results
  class(res) = 'obs.parsed'
  res
}
