#' Reformat photogrammetric data for model-based analysis
#' 
#' Assemble \code{data.frame} objects into a format that can be analyzed using 
#' numerical methods.  This function is analagous to \code{stats::model.matrix},
#' which generates design matrices for models that are specified via formulas.
#' 
#' @param pixel_counts \code{data.frame} with columns \code{Subject}, 
#'   \code{Measurement}, \code{Image}, and \code{PixelCount} that describe the 
#'   length measurements taken from images
#' @param training_objects \code{data.frame} with columns \code{Subject},
#'   \code{Measurement}, and \code{Length} that describe the known lengths of 
#'   the objects used to calibrate the photogrammetric model
#' @param image_info \code{data.frame} with columns \code{Image}, 
#'   \code{AltitudeBarometer}, \code{AltitudeLaser}, \code{FocalLength}, 
#'   \code{ImageWidth}, and \code{SensorWidth} that describe the images used in 
#'   the photogrammetric study
#' @param priors \code{list} with elements \code{altitude}, \code{lengths}, 
#'   \code{bias}, and \code{sigma} that parameterize the prior distributions for 
#'   the Bayesian model
#' 
#' @import dplyr
#' 
flatten_data = function(
  data = NULL, priors, pixel_counts = data$pixel_counts, 
  training_objects = data$training_objects, image_info = data$image_info
) {
  
  #
  # validate inputs
  #
  
  # validate prior distribution input exists
  for(component in c('altitude', 'lengths', 'bias', 'sigma')) {
    if(is.null(priors[[component]])) {
      stop(paste('Missing component from input: priors$', component, sep = ''))
    }
  }
  
  validate_pixel_counts(pixel_counts)
  validate_image_info(image_info)
  if(!is.null(training_objects)) {
    validate_training_objects(training_objects)
  }
  
  
  # arrange pixel counts s.t. measurements are contiguous wrt. image
  pixel_counts = pixel_counts[order(pixel_counts$Image), ]
  
  #
  # initialize output
  #
  
  # initialize storage for nimble model
  pkg = list(data = list(), consts = list(), inits = list())
  
  # Initial measurement error parameters
  pkg$inits$bias = c(Barometer = 0, Laser = 0, Pixels = 0)
  pkg$inits$sigma = c(Barometer = 1, Laser = 1, Pixels = 1)
  
  # Prior distribution specifications
  pkg$consts$priors_altitude = priors$altitude
  pkg$consts$priors_lengths = priors$lengths
  pkg$consts$priors_bias = priors$bias
  pkg$consts$priors_sigma = priors$sigma
  
  #
  # additional labels for inputs
  #
  
  # define image id's
  image_info$ImageId = 1:nrow(image_info)
  
  # enumerate all objects for which measurements were taken
  objs = pixel_counts %>% 
    select(Subject, Measurement, Timepoint) %>% 
    unique() %>% 
    mutate(
      name = paste(gsub('\\s+', '_', Subject),
                   gsub('\\s+', '_', Measurement),
                   gsub('\\s+', '_', Timepoint),
                   sep = '-'),
      ObjectId = 1:n()
    )
  
  # determine and merge id's of training objects
  if(!is.null(training_objects)) {
    train_ids = objs %>%
      semi_join(
        training_objects, by = c('Subject', 'Measurement', 'Timepoint')
      ) %>%
      select(ObjectId) %>%
      unlist() 
  } else {
    train_ids = NULL
  }
  objs = objs %>%
    mutate(Type = ifelse(ObjectId %in% train_ids, 'Train', 'Estimate'))
  
  # export object id mapping
  pkg$maps$L = objs %>%
    mutate(
      Estimated = (Type == 'Estimate'),
      NodeName = paste('L[', ObjectId, ']', sep = '')
    ) %>%
    select(Subject, Measurement, Timepoint, Estimated, NodeName)
  
  #
  # format data for model code
  #
  
  # barometer and laser altimeter metadata
  pkg$consts$baro_map = which(is.finite(image_info$AltitudeBarometer))
  pkg$consts$laser_map = which(is.finite(image_info$AltitudeLaser))
    
  # barometer and laser altimeter reading data
  pkg$data$a_baro = image_info$AltitudeBarometer
  pkg$data$a_laser = image_info$AltitudeLaser
  pkg$inits$a = rowMeans(image_info[, c('AltitudeBarometer', 'AltitudeLaser')],
                         na.rm = TRUE)
  
  # pixel measurements
  pkg$data$pixels_obs = pixel_counts$PixelCount
  
  # TODO: add empirical lengths, for comparison
  
  # indices of first and last pixel measurement for image
  pixel_range = t(sapply(image_info$Image, function(img) {
    range(which(pixel_counts$Image == img))
  }))
  colnames(pixel_range) = c('FirstMeasurement', 'LastMeasurement')
  
  # information about each image
  pkg$consts$image_info = as.matrix(cbind(
    image_info[, c('FocalLength', 'ImageWidth', 'SensorWidth')],
    pixel_range
  ))

  # associate each length measurement with object (lengths) and images
  pkg$consts$pixel_id_map = as.matrix(
    pixel_counts %>%
      left_join(objs, by = c('Subject', 'Measurement', 'Timepoint')) %>%
      left_join(image_info, by = 'Image') %>%
      select(ObjectId, ImageId)
  )
  
  # initialize object lengths
  pkg$inits$L = pixel_counts %>%
    # get image information for measurements
    left_join(cbind(image_info, a = pkg$inits$a), by =  'Image') %>%
    # get object id's and test/train type
    left_join(objs, by = c('Subject', 'Measurement', 'Timepoint'))
  if(is.null(training_objects)) {
    # annotate that no exact lengths are known
    pkg$inits$L$Length = NA
  } else {
    pkg$inits$L = pkg$inits$L %>% 
      # source of training object lengths
      left_join(training_objects, by = c('Subject', 'Measurement', 'Timepoint')) 
  }
  pkg$inits$L = pkg$inits$L %>% 
    # estimated length
    mutate(L = a * SensorWidth / FocalLength / ImageWidth * PixelCount) %>%
    # overwrite estimates with true lengths if available (i.e., training objs)
    mutate(L = ifelse(is.finite(Length), Length, L)) %>%
    # summarize, arrange, output
    group_by(ObjectId) %>%
    summarise(L_est = mean(L)) %>%
    ungroup() %>%
    arrange(ObjectId) %>%
    select(L_est) %>%
    unlist()
  
  #
  # Extract totals
  #
  
  # indices of lengths to be estimated; add extra element to ensure nimble 
  # interprets L_unknown_inds as a vector, even if only estimating one length
  pkg$consts$L_unknown_inds = c(which(objs$Type == 'Estimate'), 0)
  
  pkg$consts$N_images = nrow(image_info)
  pkg$consts$N_unknown_lengths = length(pkg$consts$L_unknown_inds) - 1
  pkg$consts$N_lengths = length(pkg$inits$L)
  pkg$consts$N_pixel_counts = nrow(pixel_counts)
  pkg$consts$N_baro = length(pkg$consts$baro_map)
  pkg$consts$N_laser = length(pkg$consts$laser_map)
  
  # begin by specifying default, independence prior for unknown lengths
  pkg$consts$independentLengths = TRUE
  
  #
  # Initialize expected pixel counts
  #
  
  pkg$inits$pixels_expected = sapply(1:pkg$consts$N_pixel_counts, function(i) {
    pkg$inits$L[ pkg$consts$pixel_id_map[i, 1] ] *
      pkg$consts$image_info[ pkg$consts$pixel_id_map[i, 2], 1 ] *
      pkg$consts$image_info[ pkg$consts$pixel_id_map[i, 2], 2 ] /
      pkg$consts$image_info[ pkg$consts$pixel_id_map[i, 2], 3 ] /
      pkg$inits$a[ pkg$consts$pixel_id_map[i, 2] ]
  })
 
  class(pkg) = 'data.flattened'
  pkg
}
