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
#' @param height_ratios numeric vector used to compute \code{'body_volume'}
#'   metric. the \code{'body_volume'} metric assumes the animal's height at a 
#'   \code{width_increment} is the measured width (estimate) times the 
#'   corresponding entry in \code{height_ratios}.  By default, all 
#'   \code{height_ratios} are assumed to equal 1, which reflects a default 
#'   assumption that an animal's vertical cross sections are circular rather 
#'   than elliptical.
#' 
#' @example examples/body_condition_example.R
#' 
#' @import dplyr
#' 
#' @return outputs a list with five elements: 
#' \describe{
#'  \item{surface_area}{a list containing the surface area samples and summaries
#'  for each Subject}
#'  \item{body_area_index}{a list containing the body area index samples and summaries
#'  for each Subject}
#'  \item{body_volume}{a list containing the body volume samples and summaries
#'  for each Subject}
#'  \item{standardized_widths}{a list containing the standardized width samples and summaries
#'  for each Subject}
#'  \item{summaries}{a list for each body condition metric containing summaries for each Subject}
#'  }
#' 
#' @export
#' 
body_condition = function(
    data, output, length_name, width_names, width_increments, summary.burn = .5,
    height_ratios = rep(1, length(width_names)), 
    metric = c('surface_area', 'body_area_index', 'body_volume', 
               'standardized_widths')
) {
  
  # add dependent measurements, as needed
  if('body_area_index' %in% metric) {
    metric = unique(c(metric, 'surface_area'))
  }
    
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
      
      # scale to height measurement samples
      height_samples = sweep(
        x = width_samples, 
        MARGIN = 2,
        STATS = height_ratios
      )
      
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
      if('surface_area' %in% metric) {
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
      
      # standardize each width estimate relative to the total length estimate
      if('standardized_widths' %in% metric) {
        # use lapply vs sweep so that we can get the output *format* correct
        res$standardized_widths = lapply(seq_along(width_names), function(ind) {
          list(
            samples = width_samples[, ind] / total_length_samples
          )
        })
        names(res$standardized_widths) = width_names
      }
      
      # compute body volume using ellipsoidal frustrums based on ratios
      if('body_volume' %in% metric) {
        res$body_volume = list()
        nwidths = nrow(width_meta)
        dwp = diff(width_meta$increment_proportion)
        dw = width_samples[, 2:nwidths] - width_samples[, 1:(nwidths-1)]
        dh = height_samples[, 2:nwidths] - height_samples[, 1:(nwidths-1)]
        res$body_volume$samples = pi * total_length_samples * 
          colSums(
            dwp * t(
              dw * dh / 3 + 
              (width_samples[, 1:(nwidths-1)] * dh + 
               height_samples[, 1:(nwidths-1)] * dw) / 2 + 
              width_samples[, 1:(nwidths-1)] * height_samples[, 1:(nwidths-1)]
            )
          ) / 4
      }
      
      # compute posterior summaries
      for(m in names(res)) {
        if('samples' %in% names(res[[m]])) {
          res[[m]]$summary = data.frame(
            Subject = r['Subject'],
            Timepoint = r['Timepoint'],
            metric = m,
            mean = mean(res[[m]]$samples[post_inds]),
            sd = sd(res[[m]]$samples[post_inds]),
            HPDinterval(mcmc(res[[m]]$samples[post_inds]))
          )
        } else {
          for(s in names(res[[m]])) {
            res[[m]][[s]]$summary = data.frame(
              Subject = r['Subject'],
              Timepoint = r['Timepoint'],
              metric = paste(m, s),
              mean = mean(res[[m]][[s]]$samples[post_inds]),
              sd = sd(res[[m]][[s]]$samples[post_inds]),
              HPDinterval(mcmc(res[[m]][[s]]$samples[post_inds]))
            )
          }
        }
        
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
