#' Extract, summarize, and format object size components of model output
#' 
#' @param pkg analysis package
#' @param samples matrix of nimble posterior samples
#' @param post_inds array of indices from \code{samples} to use for summarizing
#'   posterior distributions
#' @param prediction_objects \code{data.frame} specifying which objects in the 
#'   model had lengths to be estimated
#'   
#' @importFrom coda mcmc HPDinterval effectiveSize
#' @importFrom stats sd
#' 
#' @noRd
#' 
format_object_output = function(pkg, samples, post_inds, prediction_objects) {
  
  # parse model output
  res = apply(
    # loop over prediction objects
    X = prediction_objects %>% 
      left_join(
        y = pkg$maps$objects %>% mutate(model_index = 1:n()), 
        by = c('Subject', 'Measurement', 'Timepoint')
      ), 
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
        x = 'object_length[X]'
      )
      
      # extract posterior samples
      summary_samples = samples[post_inds, tgt, drop = FALSE]
      
      m = mcmc(summary_samples)
      
      # summarize posterior samples
      summary = data.frame(
        Subject = meta$Subject,
        Measurement = meta$Measurement,
        Timepoint = meta$Timepoint,
        parameter = 'length',
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
  
  # label results with object names
  names(res) = apply(
    X = prediction_objects, 
    MARGIN = 1, 
    FUN = function(r) paste(r, collapse = ' ')
  )
  
  res
}
