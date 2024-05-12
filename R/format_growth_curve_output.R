#' Extract, summarize, and format growth curve components of model output
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
format_growth_curve_output = function(pkg, samples, post_inds) {
  
  # extract samples for parameters
  res = list(
    zero_length_age = list(
      samples = samples[
        post_inds, 'zero_length_age', drop = FALSE
      ] %>% unname()
    ),
    growth_rate = list(
      samples = samples[
        post_inds, 'growth_rate', drop = FALSE
      ] %>% unname()
    ),
    group_asymptotic_size = list(
      samples = samples[
        post_inds,
        sprintf('group_asymptotic_size[%d]', 1:pkg$constants$n_groups),
        drop = FALSE
      ] %>% unname()
    ),
    group_asymptotic_size_trend = list(
      samples = samples[
        post_inds,
        sprintf('group_asymptotic_size_trend[%d]', 1:pkg$constants$n_groups),
        drop = FALSE
      ] %>% unname()
    ),
    birth_year = list(
      samples = samples[
        post_inds,
        sprintf(
          'subject_birth_year[%d]', 
          1:pkg$constants$n_growth_curve_subjects
        ),
        drop = FALSE
      ] %>% unname()
    ),
    # map categorical group membership vars. to dummy variables for each subject
    group_membership = list(
      samples = do.call(cbind, lapply(
        X = seq_along(pkg$maps$growth_curve$subjects), 
        FUN = function(subject_ind) {
          summary_samples = matrix(
            data = 0, 
            nrow = length(post_inds), 
            ncol = length(pkg$maps$growth_curve$groups)
          )
          colnames(summary_samples) = paste(
            pkg$maps$growth_curve$groups, 
            pkg$maps$growth_curve$subjects[subject_ind],
            'probability for'
          )
          summary_samples[
            , samples[post_inds, sprintf('subject_group[%d]', subject_ind)]
          ] = 1
          summary_samples
        }
      ))
    ),
    asymptotic_size_sd = list(
      samples = samples[
        post_inds, 'asymptotic_size_sd', drop = FALSE
      ] %>% unname()
    ),
    group_size_shift_start_year = list(
      samples = samples[
        post_inds, 'group_size_shift_start_year', drop = FALSE
      ] %>% unname()
    ),
    subject_asymptotic_size = list(
      samples = samples[
        post_inds,
        sprintf(
          'subject_asymptotic_size[%d]', 
          1:pkg$constants$n_growth_curve_subjects
        ),
        drop = FALSE
      ] %>% unname()
    )
  )
  
  colnames(res$group_asymptotic_size$samples) = pkg$maps$growth_curve$groups
  
  colnames(res$group_asymptotic_size_trend$samples) = 
    pkg$maps$growth_curve$groups
  
  colnames(res$birth_year$samples) = pkg$maps$growth_curve$subjects
  
  colnames(res$subject_asymptotic_size$samples) = pkg$maps$growth_curve$subjects
  
  # summarize parameters
  for(component in names(res)) {
    m = mcmc(res[[component]]$samples)
    res[[component]]$summary = data.frame(
      parameter = paste(colnames(m), component),
      mean = colMeans(m),
      sd = apply(m, 2, sd),
      HPDinterval(m),
      ESS = effectiveSize(m),
      PSS = length(post_inds)
    )
    rownames(res[[component]]$summary) = NULL
  }
  
  res
}
