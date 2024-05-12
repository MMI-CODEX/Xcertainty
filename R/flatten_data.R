#' Reformat photogrammetric data for model-based analysis
#' 
#' For internal use only.  Not intended to be called directly by users.
#' 
#' Assemble \code{data.frame} objects into a format that can be analyzed using 
#' numerical methods.  This function is analagous to \code{stats::model.matrix},
#' which generates design matrices for models that are specified via formulas.
#' 
#' @param data A \code{list} object, or similar that includes components 
#'   that describe observations to analyze.  Components are automatically
#'    extracted into this function's other arguments.  See the remaining 
#'    documentation for details about required components.
#' @param pixel_counts \code{data.frame} with columns \code{Subject}, 
#'   \code{Measurement}, \code{Image}, and \code{PixelCount} that describe the 
#'   length measurements taken from images
#' @param training_objects \code{data.frame} with columns \code{Subject},
#'   \code{Measurement}, and \code{Length} that describe the known lengths of 
#'   the objects used to calibrate the photogrammetric model
#' @param image_info \code{data.frame} with columns \code{Image}, 
#'   \code{Barometer}, \code{Laser}, \code{FocalLength}, 
#'   \code{ImageWidth}, and \code{SensorWidth} that describe the images used in 
#'   the photogrammetric study
#' @param priors \code{list} with elements \code{altitude}, \code{lengths}, 
#'   \code{bias}, and \code{sigma} that parameterize the prior distributions for 
#'   the Bayesian model.  The bias components may specify separate priors for
#'   each UAS/altimeter type combination, or for all barometers at once based on
#'   the information provided for joining.
#' @param prediction_objects \code{data.frame} with elements \code{Subject}, 
#'   \code{Measurement}, and \code{Timepoint} that describe the unknown lengths
#'   of objects that should be estimated
#' 
#' @example examples/example_parse_observations.R
#' 
#' @import dplyr
#' @import tidyr
#' 
flatten_data = function(
  data = NULL, priors, pixel_counts = data$pixel_counts, 
  training_objects = data$training_objects, image_info = data$image_info,
  prediction_objects = data$prediction_objects
) {
  
  #
  # validate inputs
  #
  
  # validate prior distribution input exists
  for(component in c('altimeter_bias', 'altimeter_variance', 'image_altitude',
                     'pixel_variance', 'altimeter_scaling')) {
    if(is.null(priors[[component]])) {
      stop(paste('Missing component from input: priors$', component, sep = ''))
    }
  }
  
  validate_pixel_counts(pixel_counts)
  
  validate_image_info(image_info)
  
  if(!is.null(training_objects)) {
    validate_training_objects(training_objects)
  }
  
  if(!is.null(prediction_objects)) {
    validate_prediction_objects(prediction_objects)
  }
  
  #
  # process inputs
  #
  
  # TODO: Will this still return a data.frame if there is only one altimeter?
  # enumerate altimeter combinations we have data for
  altimeter_types = image_info %>% 
    select(.data$UAS, all_of(unique(priors$altimeter_bias$altimeter))) %>% 
    pivot_longer(
      cols = all_of(unique(priors$altimeter_bias$altimeter)), 
      names_to = 'altimeter', 
      values_to = 'measurement'
    ) %>% 
    filter(is.finite(.data$measurement)) %>% 
    select(.data$UAS, .data$altimeter) %>% 
    unique() %>% 
    arrange(.data$UAS, .data$altimeter)
  
  # enumerate objects to analyze
  object_list = NULL
  if(!is.null(training_objects)) { 
    object_list = rbind(
      object_list, 
      training_objects %>% 
        select(.data$Subject, .data$Measurement, .data$Timepoint)
    )
  }
  if(!is.null(prediction_objects)) {
    object_list = rbind(
      object_list, 
      prediction_objects %>% 
        select(.data$Subject, .data$Measurement, .data$Timepoint)
    )
  }
  
  # only retain pixel count data in pixel_counts for known objects
  pixel_counts = object_list %>% 
    left_join(
      y = pixel_counts,
      by = c('Subject', 'Measurement', 'Timepoint')
    )
  
  # arrange pixel counts s.t. measurements are contiguous wrt. image
  pixel_counts = pixel_counts[order(pixel_counts$Image), ]
  
  #
  # initialize output
  #
  
  # initialize storage for nimble model
  pkg = list(data = list(), constants = list(), inits = list(), maps = list())
  
  pkg$maps$altimeters = altimeter_types
  pkg$constants$n_altimeters = nrow(pkg$maps$altimeters)
  pkg$inits$altimeter_bias = rep(0, pkg$constants$n_altimeters)
  pkg$inits$altimeter_scaling = rep(1, pkg$constants$n_altimeters)
  pkg$inits$altimeter_variance = rep(1, pkg$constants$n_altimeters)
  
  # assemble prior bias distributions for all uas/altimeter type combinations
  pkg$constants$prior_altimeter_bias = pkg$maps$altimeters %>% 
    left_join(
      y = priors$altimeter_bias
    ) %>% 
    select(.data$mean, .data$sd) %>% 
    as.matrix()
  
  # assemble prior scaling distributions for all uas/altimeter type combinations
  pkg$constants$prior_altimeter_scaling = pkg$maps$altimeters %>% 
    left_join(
      y = priors$altimeter_scaling
    ) %>% 
    select(.data$mean, .data$sd) %>% 
    as.matrix()
  
  # assemble prior var. distributions for all uas/altimeter type combinations
  pkg$constants$prior_altimeter_variance = pkg$maps$altimeters %>% 
    left_join(
      y = priors$altimeter_variance
    ) %>% 
    select(.data$shape, .data$rate) %>% 
    as.matrix()
  
  pkg$maps$images = image_info$Image
  pkg$constants$n_images = length(pkg$maps$images)

  # use average reported image altitude as initial guess for true altitude
  pkg$inits$image_altitude = image_info %>% 
    select(all_of(unique(pkg$maps$altimeters$altimeter))) %>% 
    rowMeans(na.rm = TRUE) %>% 
    as.numeric()
  
  pkg$constants$prior_image_altitude = priors$image_altitude
  
  # pivot altimeter readings to extract flattened data; ignore missing data
  altitude_measurements_longer = image_info %>% 
    select(
      .data$Image, 
      .data$UAS, 
      all_of(unique(pkg$maps$altimeters$altimeter))
    ) %>% 
    pivot_longer(
      cols = all_of(unique(pkg$maps$altimeters$altimeter)), 
      names_to = 'altimeter', 
      values_to = 'measurement'
    ) %>% 
    drop_na()
  
  pkg$constants$n_altimeter_measurements = nrow(altitude_measurements_longer)
  pkg$data$altimeter_measurement = altitude_measurements_longer$measurement
  
  pkg$constants$altimeter_measurement_image = altitude_measurements_longer %>% 
    left_join(
      y = data.frame(Image = pkg$maps$images) %>% mutate(ind = 1:n()),
      by = 'Image'
    ) %>% 
    select(.data$ind) %>% 
    unlist() %>% 
    as.numeric()
  
  pkg$constants$altimeter_measurement_type = altitude_measurements_longer %>% 
    left_join(
      y = pkg$maps$altimeters %>% mutate(ind = 1:n())
    ) %>%
    select(.data$ind) %>% 
    unlist() %>% 
    as.numeric()
  
  pkg$inits$pixel_variance = 1
  pkg$constants$prior_pixel_variance = priors$pixel_variance
  
  pkg$maps$objects = object_list
  
  # initialize object lengths as unknown values.  values will be populated 
  # according to whether or not objects are training objects or not
  if(is.null(data$training_objects)) {
    pkg$inits$object_length = rep(NA, nrow(pkg$maps$objects))
  } else {
    pkg$inits$object_length = object_list %>% 
      left_join(
        y = data$training_objects,
        by = c('Subject', 'Measurement', 'Timepoint')
      ) %>% 
      select(.data$Length) %>% 
      unlist() %>% 
      as.numeric()
  }
  
  pkg$constants$pixel_count_expected_object = pixel_counts %>% 
    left_join(
      y = pkg$maps$objects %>% mutate(ind = 1:n()),
      by = c('Subject', 'Measurement', 'Timepoint')
    ) %>% 
    select(.data$ind) %>% 
    unlist() %>% 
    as.numeric()
  
  pkg$constants$image_focal_length = image_info$FocalLength
  pkg$constants$image_width = image_info$ImageWidth
  pkg$constants$image_sensor_width = image_info$SensorWidth
  
  pkg$constants$pixel_count_expected_image = pixel_counts %>% 
    left_join(
      y = data.frame(Image = pkg$maps$images) %>% mutate(ind = 1:n()),
      by = 'Image'
    ) %>% 
    select(.data$ind) %>% 
    unlist() %>% 
    as.numeric()
  
  pkg$data$pixel_count_observed = pixel_counts$PixelCount
  
  pkg$constants$n_pixel_counts = length(pkg$data$pixel_count_observed)
  
  # turn off all length models by default
  pkg$constants$n_basic_objects = 0
  pkg$constants$n_basic_object_length_constraints = 0
  pkg$constants$n_growth_curve_subjects = 0
 
  class(pkg) = 'data.flattened'
  pkg
}
