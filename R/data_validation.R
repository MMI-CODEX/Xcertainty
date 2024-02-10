handle_error = function(msg, action) {
  if(action == 'message') { message(msg) }
  if(action == 'warn') { warning(msg) }
  if(action == 'stop') { stop(msg) }
}

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
  
  # need at least one measurement
  if(nrow(x) < 1) {
    handle_error(msg = 'Must include at least one measurement to analyze.', 
                 action = error)
  }
  
  # only allow one PixelCount per observation
  if(nrow(x) != nrow(x %>% select(Subject, Measurement, Timepoint, Image) %>% 
                     unique())) {
    
    # figure out where the multiple pixel counts occur
    err_details = x %>% 
      group_by(Subject, Measurement, Timepoint, Image) %>% 
      summarise(NumPixelCounts = n(), .groups = 'keep') %>% 
      filter(NumPixelCounts > 1)
    
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
  
  # only one true length for each training object
  if(nrow(x) != nrow(x %>% select(Subject, Measurement, Timepoint) %>% 
                     unique())) {
    
    # figure out where the multiple objects occur
    err_details = x %>% 
      group_by(Subject, Measurement, Timepoint) %>% 
      summarise(NumTrueLengths = n(), .groups = 'keep') %>% 
      filter(NumTrueLengths > 1)
    
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

validate_image_info = function(x, error = 'stop', verbose = TRUE) {
  
  if(!inherits(x, 'data.frame')) {
    handle_error(msg = 'Image info must be in a data.frame', action = error)
  }
  
  # data columns must exist in data.frame
  required = c('Image', 'AltitudeBarometer', 'AltitudeLaser', 'FocalLength',
               'ImageWidth', 'SensorWidth', 'UAS')
  if(!all(required %in% colnames(x))) {
    handle_error(
      msg = paste('Column(s)',
                  paste(setdiff(required, colnames(x)), collapse = ', '),
                  'not found in x'),
      action = error
    )
  }
  
  # need at least one image
  if(nrow(x) < 1) {
    handle_error(msg = 'Must include at least one image to analyze.',
                 action = error)
  }
  
  # only one set of attributes for each image
  if(nrow(x) != nrow(x %>% select(Image) %>% unique())) {
    
    # figure out where the multiple objects occur
    err_details = x %>% 
      group_by(Image) %>% 
      summarise(NTimesDuplicated = n(), .groups = 'keep') %>% 
      filter(NTimesDuplicated > 1)
    
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
  missing_altitudes = x$Image[
    (!is.finite(x$AltitudeBarometer)) & (!is.finite(x$AltitudeLaser))
  ]
  if(length(missing_altitudes) > 0) {
    
    # report error details
    if(verbose) {
      message(
        paste(
          'No finite barometer or laser data for image(s):',
          paste(missing_altitudes, collapse = ', ')
        )
      )
    }
    
    handle_error(msg = 'Some images do not have any altimeter data.',
                 action = error)
  }
  
}
