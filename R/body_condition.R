#' Compute body condition metrics for a set of measurements
#' 
#' Function that post-processes posterior samples from a sampler, such as 
#' \code{independent_length_sampler()}.
#'
#' @param data The output from parse_observations
#' @param output The return object from a sampler
#' @param length_name The name of the total-length measurement in the dataset
#' @param width_names Character vector with the names of the width measurements
#'   in the dataset
#' @param width_increments Numeric vector indicating which perpendicular width 
#'   segment each \code{width_names} entry corresponds to, reported as a 
#'   percentage along an animal's total length (i.e., \code{5} for "5\%", etc.)
#' @param metric Character vector of the body condition metrics to compute
#' @param summary.burn proportion of posterior samples to discard before 
#'   computing posterior summary statistics
#' 
#' @example examples/body_condition_example.R
#' 
#' @import dplyr
#' 
#' @export
#' 
body_condition = function(
    data, output, length_name, width_names, width_increments, summary.burn = .5,
    metric = c('surface_area', 'body_area_index')
) {
  
  if(all('body_area_index' %in% metric, length(width_names) < 3)) {
    stop('Need at least 3 width measurements to compute body_area_index')
  }
  
  # collate the width names with their measurement positions along the body
  width_meta = data.frame(
    measurement = width_names,
    increment_proportion = width_increments / 100
  ) %>% 
    arrange(.data$increment_proportion)
  
  # collate all measurements needed to compute bai
  required_measurements = c(length_name, width_meta$measurement)
  
  subject_timepoints = data$prediction_objects %>% 
    select(.data$Subject, .data$Timepoint) %>% 
    unique()
  
  # compute posterior body condition samples, by subject and timepoint
  body_condition_samples = apply(
    X = subject_timepoints, 
    MARGIN = 1, 
    FUN = function(r) {
      
      # skip combination if not all required measurements are available
      if(!all(
        required_measurements %in% (
          data$prediction_objects %>%
          filter(
            .data$Subject == r['Subject'],
            .data$Timepoint == r['Timepoint']
          ) %>% 
          select(.data$Measurement) %>% 
          unlist()
        )
      )) {
        return(NULL)
      }
      
      # extract total length measurement samples
      total_length_samples = output$objects[[
        paste(r['Subject'], length_name, r['Timepoint'])
      ]]$samples
      
      # extract width measurements into a matrix (nsamples x nwidths)
      width_samples = do.call(cbind, lapply(
        X = width_meta$measurement, 
        FUN = function(w) {
          output$objects[[
            paste(r['Subject'], w, r['Timepoint'])
          ]]$samples
        }
      ))
      
      #
      # compute metrics
      #
      
      post_inds = seq(
        from = length(total_length_samples) * summary.burn, 
        to = length(total_length_samples)
      )
      
      # initialize output
      res = list()
      
      # compute surface area samples
      if(any(c('surface_area', 'body_area_index') %in% metric)) {
        res$surface_area = list()
        nwidths = nrow(width_meta)
        res$surface_area$samples = total_length_samples * 
          colSums(
            diff(width_meta$increment_proportion) *
              t(width_samples[,2:nwidths] + width_samples[,1:(nwidths-1)])
          ) / 2
      }
      
      # compute bai samples
      if('body_area_index' %in% metric) {
        res$body_area_index = list()
        head_tail_range = diff(range(width_meta$increment_proportion))
        res$body_area_index$samples = res$surface_area$samples / (
          head_tail_range * total_length_samples
        )^2 * 100
      }
      
      # compute posterior summaries
      for(m in names(res)) {
        res[[m]]$summary = data.frame(
          Subject = r['Subject'],
          Timepoint = r['Timepoint'],
          metric = m,
          mean = mean(res[[m]]$samples[post_inds]),
          sd = sd(res[[m]]$samples[post_inds]),
          HPDinterval(mcmc(res[[m]]$samples[post_inds]))
        )
      }
      
      res
    }
  )
  
  # label outputs, which are grouped by subject/timepoint combination
  names(body_condition_samples) = apply(
    X = subject_timepoints, 
    MARGIN = 1, 
    FUN = function(r) paste(r, collapse = ' ')
  )
  
  # reformat outputs, group by metric 
  res = list()
  for(m in metric) {
    res[[m]] = lapply(body_condition_samples, function(x) {
      x[[m]]
    })
  }
  
  # collate summaries into common data.frame objects
  res$summaries = extract_summaries(res)
  
  res
}
