#' Recursive convenience function to combine summary objects from other 
#' formatting functions
#' 
#' @param model_output collection of MCMC output previously formatted using 
#'   functions such as \code{format_altimeter_output}, 
#'   \code{format_image_output}, etc.
#'   
#' @noRd
#'   
extract_summaries = function(model_output) {
  lapply(model_output, function(component) {
    if('summary' %in% names(component)) {
      s = component$summary
    } else {
      s = do.call(rbind, extract_summaries(component))
      rownames(s) = NULL
    }
    s
  })
} 
