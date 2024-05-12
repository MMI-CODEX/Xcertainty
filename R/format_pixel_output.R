#' Extract, summarize, and format pixel error components of model output
#' 
#' @param pkg analysis package
#' @param samples matrix of nimble posterior samples
#' @param post_inds array of indices from \code{samples} to use for summarizing
#'   posterior distributions
#'   
#' @importFrom coda mcmc HPDinterval effectiveSize
#' @importFrom stats sd
#' 
#' @noRd
#' 
format_pixel_output = function(pkg, samples, post_inds) {
  
  tgt = 'pixel_variance'
  
  summary_samples = samples[post_inds, tgt]
  m = mcmc(summary_samples)
  
  summary = data.frame(
    error = 'pixel',
    parameter = 'variance',
    mean = mean(summary_samples),
    sd = sd(summary_samples),
    HPDinterval(m),
    ESS = effectiveSize(m),
    PSS = length(post_inds)
  )
  
  rownames(summary) = NULL
  
  # parse model output
  res = list(
    samples = samples[, tgt],
    summary = summary
  )
  
  res
}
