#' Pre-process training and experimental data from wide-format to long-format
#'
#' Photogrammetric data are often recorded in a wide-format \code{data.frame}, 
#' in which each row contains all measurement information for a single animal.
#' The row contains the image information (i.e., observed altitude and sensor 
#' information) as well as all measurements for a given subject. This function
#' parses the wide-format data into a normalized \code{list} of 
#' \code{data.frame} objects that separately describe the image and measurement 
#' data.  This function can process observations of calibration data as well as 
#' experimental data.
#' 
#' @param x Wide-format \code{data.frame} describing images and measurements
#' @param subject_col column name in \code{x} for subject IDs
#' @param meas_col character vector of column names in \code{x} with 
#'  pixel-counts for each measurement of a subject
#' @param tlen_col column name in \code{x} with the true length value (i.e., in 
#'  meters) of a measurement; primarily used to specify the true length value 
#'  for an observation of a calibration object.  If \code{NULL}, then no true 
#'  length will be associated with the measurement.
#' @param image_col column name in \code{x} containing names of images from 
#'  which measurements are taken
#' @param barometer_col column name in \code{x} with Barometer altimeter values
#' @param laser_col column name in \code{x} with Laser altimeter values
#' @param flen_col column name in \code{x} with camera focal lengths (mm)
#' @param iwidth_col column name in \code{x} with image widths (pixels)
#' @param swidth_col column name in \code{x} with camera sensor widths (mm)
#' @param uas_col column names in \code{x} with UAS name or ID
#' @param timepoint_col column name in \code{x} with a timepoint value of a 
#'   measurement.  If \code{NULL}, then all measurements are assumed to be at 
#'   the same timepoint, or equivalently, that time does not matter for the 
#'   analysis
#' @param alt_conversion_col if not \code{NULL}, column name in \code{x} with 
#'  an altitude used to convert measurement columns from lengths to pixels
#' 
#' @example  examples/example_parse_observations.R
#' 
#' @import dplyr
#' @importFrom tidyr pivot_longer
#' 
#' @return outputs a list with four elements: 
#' \describe{
#'  \item{pixel_counts}{a tibble containing the measurements in pixels 
#'  linked with Subject, Measurement description, Image, and the Timepoint}
#'  \item{training_objects}{a tibble containing the Subject, Measurement, Length, 
#'  and Timepoint. NULL if no training objects were included}
#'  \item{prediction_objects}{a tibble containing the Subject, Measurement, and 
#'  Timepoint. NULL if no prediction data included}
#'  \item{image_info}{a tibble containing the Image, Barometer, Laser, FocalLength,
#'  ImageWidth, SensorWidth, and UAS}
#'  }
#' 
#' @export
#' 
parse_observations = function(
  x, subject_col, meas_col, tlen_col = NULL, image_col, barometer_col = NULL, 
  laser_col = NULL, flen_col, iwidth_col, swidth_col, uas_col, 
  timepoint_col = NULL, alt_conversion_col = NULL
) {
  
  #
  # validate input
  #
  
  if(all(is.null(barometer_col), is.null(laser_col))) {
    stop('Must provide barometer and/or laser altimeter data.')
  }

  if(!inherits(x, 'data.frame')) {
    stop('x must be a data.frame')
  }

  # columns that identify key pieces of information must be unique
  data_column_names = list(
    subject_col = subject_col, tlen_col = tlen_col, image_col = image_col, 
    barometer_col = barometer_col, laser_col = laser_col, flen_col = flen_col, 
    iwidth_col = iwidth_col, swidth_col = swidth_col, uas_col = uas_col,
    timepoint_col = timepoint_col
  )
  non_unique_data_columns = lapply(data_column_names, length) > 1
  if(any(non_unique_data_columns)) {
    stop(
      paste(
        'Some arguments specify more than one column when not allowed:',  
        paste(names(data_column_names)[non_unique_data_columns], 
              collapse = ', ')
      )
    )
  }

  # data columns must exist in data.frame
  required = c(unlist(data_column_names), meas_col)
  if(!all(required %in% colnames(x))) {
    stop(
      paste(
        'Column(s)',
        paste(setdiff(required, colnames(x)), collapse = ', '),
        'not found in x'
      )
    )
  }

  #
  # extract data
  #

  # long-format measurements so each row has all information about each meas.
  xlong = x %>% 
    pivot_longer(
      cols = all_of(meas_col),
      names_to = 'Measurement',
      values_to = 'PixelCount'
    )
  
  # extract pixel counts
  pixel_counts = xlong %>% 
    select(
      Subject = subject_col,
      .data$Measurement,
      Timepoint = timepoint_col,
      Image = image_col,
      .data$PixelCount
    ) %>% 
    unique() %>% 
    mutate(
      Subject = as.character(.data$Subject),
      Measurement = as.character(.data$Measurement)
    )
  
  # add a default, common timepoint if information not provided
  if(!('Timepoint' %in% colnames(pixel_counts))) {
    pixel_counts$Timepoint = 1
  }
  
  # extract reference information for training objects, if available
  training_objects = NULL
  if(!is.null(tlen_col)) {
    training_objects = xlong %>% 
      filter(is.finite(.data[[tlen_col]])) %>% 
      dplyr::select(
        Subject = subject_col,
        .data$Measurement,
        Timepoint = timepoint_col,
        Length = tlen_col
      ) %>% 
      unique() %>% 
      mutate(
        Subject = as.character(.data$Subject),
        Measurement = as.character(.data$Measurement)
      )
    # add a default, common timepoint if information not provided
    if(!('Timepoint' %in% colnames(training_objects))) {
      training_objects$Timepoint = 1
    }
  }
  
  # enumerate objects whose lengths should be estimated, if available
  prediction_objects = pixel_counts %>% 
    select(.data$Subject, .data$Measurement, .data$Timepoint) %>%
    unique() %>%
    mutate(
      Subject = as.character(.data$Subject),
      Measurement = as.character(.data$Measurement)
    )
  if(inherits(training_objects, 'data.frame'))
    prediction_objects = prediction_objects %>% 
      setdiff(training_objects %>% 
                select(.data$Subject, .data$Measurement, .data$Timepoint))
  if(nrow(prediction_objects) == 0)
    prediction_objects = NULL
  
  # extract image information
  image_info = x %>% 
    select(
      Image = image_col,
      Barometer = barometer_col,
      Laser = laser_col,
      FocalLength = flen_col,
      ImageWidth = iwidth_col,
      SensorWidth = swidth_col,
      UAS = uas_col
    ) %>% 
    unique()
  
  # convert measurements from lengths to pixels
  if(!is.null(alt_conversion_col)) {
    pixel_counts = pixel_counts %>% 
      left_join(
        image_info %>% left_join(x, by = c(Image = image_col)),
        by = 'Image'
      ) %>% 
      select(
        .data$Subject,
        .data$Measurement,
        .data$Timepoint,
        .data$Image,
        .data$PixelCount,
        Altitude = alt_conversion_col,
        .data$FocalLength,
        .data$ImageWidth,
        .data$SensorWidth
      ) %>% 
      mutate(
        GSD = .data$Altitude * .data$SensorWidth / .data$FocalLength / 
          .data$ImageWidth,
        PixelCount = .data$PixelCount / .data$GSD
      ) %>% 
      select(
        .data$Subject,
        .data$Measurement,
        .data$Timepoint,
        .data$Image,
        .data$PixelCount
      ) %>% 
      unique()
  }

  #
  # validate parsed data
  #

  validate_pixel_counts(pixel_counts)
  
  if(!is.null(training_objects)) {
    validate_training_objects(training_objects)
  }
  
  if(!is.null(prediction_objects)) {
    validate_prediction_objects(prediction_objects)
  }
  
  validate_image_info(image_info)
  
  # package results
  res = list(
    pixel_counts = pixel_counts,
    training_objects = training_objects,
    prediction_objects = prediction_objects,
    image_info = image_info
  )
  class(res) = 'obs.parsed'
  res
}
