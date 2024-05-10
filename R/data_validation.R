handle_error = function(msg, action) {
  if(action == 'message') { message(msg) }
  if(action == 'warn') { warning(msg) }
  if(action == 'stop') { stop(msg) }
}

#' Validation checks for pixel data
#' 
#' @importFrom utils capture.output
#' 
#' @noRd
#' 
validate_pixel_counts = function(x, error = 'stop', verbose = TRUE) {
  
  if(!inherits(x, 'data.frame')) {
    handle_error(msg = 'Pixel counts must be in a data.frame', action = error)
  }
  
  # data columns must exist in data.frame
  required = c('Subject', 'Measurement', 'Timepoint', 'Image', 'PixelCount')
  if(!all(required %in% colnames(x))) {
    handle_error(
      msg = paste('Column(s)',
                  paste(setdiff(required, colnames(x)), collapse = ', '),
                  'not found in x'), 
      action = error
    )
  }
  
  # subject and measurement columns must be character vectors
  character_columns = c('Subject', 'Measurement')
  if(!all(sapply(x[,character_columns], class) == 'character')) {
    handle_error(
      msg = 'Subject and Measurement columns must be character vectors',
      action = error
    )
  }
  
  # need at least one measurement
  if(nrow(x) < 1) {
    handle_error(msg = 'Must include at least one measurement to analyze.', 
                 action = error)
  }
  
  # only allow one PixelCount per observation
  if(nrow(x) != 
     nrow(x %>% 
          select(
            .data$Subject, 
            .data$Measurement, 
            .data$Timepoint, 
            .data$Image) %>% 
          unique())
     ) {
    
    # figure out where the multiple pixel counts occur
    err_details = x %>% 
      group_by(
        .data$Subject, .data$Measurement, .data$Timepoint, .data$Image
      ) %>% 
      summarise(NumPixelCounts = n(), .groups = 'keep') %>% 
      filter(.data$NumPixelCounts > 1)
    
    # report error details
    if(verbose) {
      pf = capture.output(print(err_details))
      for(p in pf) {
        message(p)
      }
    }
    
    handle_error(
      msg = paste(
        'Some Subject/Measurement/Timepoint/Image combinations appear more',
        'once.'
      ),
      action = error
    )
  }
}

#' Validation checks for information about known object lengths
#' 
#' @importFrom utils capture.output
#' 
#' @noRd
#' 
validate_training_objects = function(x, error = 'stop', verbose = TRUE) {
  
  if(!inherits(x, 'data.frame')) {
    handle_error(msg = 'Training object info must be in a data.frame',
                 action = error)
  }
  
  # data columns must exist in data.frame
  required = c('Subject', 'Measurement', 'Timepoint', 'Length')
  if(!all(required %in% colnames(x))) {
    handle_error(
      msg = paste('Column(s)',
                  paste(setdiff(required, colnames(x)), collapse = ', '),
                  'not found in x'),
      action = error
    )
  }
  
  # subject and measurement columns must be character vectors
  character_columns = c('Subject', 'Measurement')
  if(!all(sapply(x[,character_columns], class) == 'character')) {
    handle_error(
      msg = 'Subject and Measurement columns must be character vectors',
      action = error
    )
  }
  
  # only one true length for each training object
  if(nrow(x) != 
     nrow(x %>% 
          select(.data$Subject, .data$Measurement, .data$Timepoint) %>% 
          unique())
     ) {
    
    # figure out where the multiple objects occur
    err_details = x %>% 
      group_by(.data$Subject, .data$Measurement, .data$Timepoint) %>% 
      summarise(NumTrueLengths = n(), .groups = 'keep') %>% 
      filter(.data$NumTrueLengths > 1)
    
    # report error details
    if(verbose) {
      pf = capture.output(print(err_details))
      for(p in pf) {
        message(p)
      }
    }
    
    handle_error(msg = 'Some training objects have more than one true length.',
                 action = error)
  }
}

#' Validation checks for information about object lengths to estimate
#' 
#' @importFrom utils capture.output
#' 
#' @noRd
#' 
validate_prediction_objects = function(x, error = 'stop', verbose = TRUE) {
  
  if(!inherits(x, 'data.frame')) {
    handle_error(msg = 'Prediction object info must be in a data.frame',
                 action = error)
  }
  
  # data columns must exist in data.frame
  required = c('Subject', 'Measurement', 'Timepoint')
  if(!all(required %in% colnames(x))) {
    handle_error(
      msg = paste('Column(s)',
                  paste(setdiff(required, colnames(x)), collapse = ', '),
                  'not found in x'),
      action = error
    )
  }
  
  # subject and measurement columns must be character vectors
  character_columns = c('Subject', 'Measurement')
  if(!all(sapply(x[,character_columns], class) == 'character')) {
    handle_error(
      msg = 'Subject and Measurement columns must be character vectors',
      action = error
    )
  }
  
  # only one entry for each training object
  if(nrow(x) != 
     nrow(x %>% 
          select(.data$Subject, .data$Measurement, .data$Timepoint) %>% 
          unique())
    ) {
    
    # figure out where the multiple objects occur
    err_details = x %>% 
      group_by(.data$Subject, .data$Measurement, .data$Timepoint) %>% 
      summarise(NumEntries = n(), .groups = 'keep') %>% 
      filter(.data$NumEntries > 1)
    
    # report error details
    if(verbose) {
      pf = capture.output(print(err_details))
      for(p in pf) {
        message(p)
      }
    }
    
    handle_error(msg = 'Some prediction objects are registered more than once.',
                 action = error)
  }
  
}

validate_image_info = function(x, error = 'stop', verbose = TRUE) {
  
  if(!inherits(x, 'data.frame')) {
    handle_error(msg = 'Image info must be in a data.frame', action = error)
  }
  
  # data columns must exist in data.frame
  required = c('Image', 'FocalLength', 'ImageWidth', 'SensorWidth', 'UAS')
  if(!all(required %in% colnames(x))) {
    handle_error(
      msg = paste('Column(s)',
                  paste(setdiff(required, colnames(x)), collapse = ', '),
                  'not found in x'),
      action = error
    )
  }
  
  # need column for at least one type of altimeter
  if(!any(c('Barometer', 'Laser') %in% colnames(x))) {
    handle_error(
      msg = 'Neither Barometer or Laser columns found in x',
      action = error
    )
  }
  
  # need at least one image
  if(nrow(x) < 1) {
    handle_error(msg = 'Must include at least one image to analyze.',
                 action = error)
  }
  
  # only one set of attributes for each image
  if(nrow(x) != nrow(x %>% select(.data$Image) %>% unique())) {
    
    # figure out where the multiple objects occur
    err_details = x %>% 
      group_by(.data$Image) %>% 
      summarise(NTimesDuplicated = n(), .groups = 'keep') %>% 
      filter(.data$NTimesDuplicated > 1)
    
    # report error details
    if(verbose) {
      pf = capture.output(print(err_details))
      for(p in pf) {
        message(p)
      }
    }
    
    handle_error(msg = 'Some images have conflicting metadata within x.',
                 action = error)
  }
  
  # need at least one altimeter measurement for each image
  altimeter_cols = intersect(colnames(x), c('Barometer', 'Laser'))
  missing_altitudes =x %>% 
    select(.data$Image, all_of(altimeter_cols)) %>%
    pivot_longer(
      cols = altimeter_cols, 
      names_to = 'altimeter', 
      values_to = 'measurement'
    ) %>% 
    group_by(.data$Image) %>% 
    summarise(nfinite = sum(is.finite(.data$measurement))) %>% 
    filter(.data$nfinite == 0) %>% 
    select(.data$Image) %>% 
    unlist() %>% 
    unname()
  if(length(missing_altitudes) > 0) {
    
    # report error details
    if(verbose) {
      message(
        paste(
          'No finite altimeter data provided for image(s):\n',
          paste(missing_altitudes, collapse = '\n')
        )
      )
    }
    
    handle_error(msg = 'Some images do not have any altimeter data.',
                 action = error)
  }
  
}
