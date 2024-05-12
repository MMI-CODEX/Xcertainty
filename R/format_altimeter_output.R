#' Extract, summarize, and format altimeter components of model output
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
format_altimeter_output = function(pkg, samples, post_inds) {
  
  # parse model output
  res = apply(
    # loop over altimeters
    X = pkg$maps$altimeters %>% mutate(model_index = 1:n()), 
    MARGIN = 1, 
    FUN = function(r) {
      
      # store model definitions
      r['model_index'] = trimws(r['model_index'])
      meta = as.data.frame(t(r))
      rownames(meta) = NULL
      
      # identify model nodes with relevant posterior output
      tgt = gsub(
        pattern = 'X', 
        replacement = r['model_index'],
        x = c('altimeter_bias[X]', 'altimeter_variance[X]', 
              'altimeter_scaling[X]')
      )
      
      # extract posterior samples
      summary_samples = samples[post_inds, tgt]
      
      m = mcmc(summary_samples)
      
      # summarize posterior samples
      summary = data.frame(
        UAS = meta$UAS,
        altimeter = meta$altimeter,
        parameter = c('bias', 'variance', 'scaling'),
        mean = colMeans(summary_samples),
        sd = apply(summary_samples, 2, sd),
        HPDinterval(m),
        ESS = effectiveSize(m),
        PSS = length(post_inds)
      )
      
      # by default, model node names are rownames... remove
      rownames(summary) = NULL
      
      # package results
      list(
        meta = meta,
        samples = samples[, tgt],
        summary = summary
      )
    },
    simplify = FALSE
  )
  
  # label results with altimeter names
  names(res) = apply(
    X = pkg$maps$altimeters, 
    MARGIN = 1, 
    FUN = function(r) paste(r, collapse = ' ')
  )
  
  res
}
