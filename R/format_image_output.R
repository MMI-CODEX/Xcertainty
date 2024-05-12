#' Extract, summarize, and format image components of model output
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
format_image_output = function(pkg, samples, post_inds) {
  
  # parse model output
  res = apply(
    # loop over images
    X = data.frame(Image = pkg$maps$images) %>% mutate(model_index = 1:n()), 
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
        x = 'image_altitude[X]'
      )
      
      # extract posterior samples
      summary_samples = samples[post_inds, tgt, drop = FALSE]
      
      m = mcmc(summary_samples)
      
      # summarize posterior samples
      summary = data.frame(
        Image = meta$Image,
        parameter = 'altitude',
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
  
  # label results with image names
  names(res) = pkg$maps$images
  
  res
}
