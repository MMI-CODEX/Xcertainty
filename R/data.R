#' Calibration data for photogrammetric measurement error model
#'
#' A dataset containing photogrammetric measurements of known-length objects, 
#' used to estimate the characteristics of measurement errors attributed to the
#' drone platform.
#' 
#' TODO: update column descriptions
#'
#' @format A data frame with 616 rows and 9 variables:
#' \describe{
#'   \item{object_id}{Name of training object}
#'   \item{image}{Name of image measurements are taken from}
#'   \item{calibration_measurement}{The length of the object in the image, in 
#'         pixels}
#'   \item{true_length}{The known length of the object, in meters}
#'   \item{barometer_altitude}{The altitude (in meters) at which the image was 
#'         taken, according to the onboard barometer}
#'   \item{laser_altitude}{The altitude (in meters) at which the image was 
#'         taken, according to the attached laser altimeter}
#'   \item{focal_length}{The focal length of the lens when the image was taken, 
#'         in mm}
#'   \item{image_width}{The width of the image, in pixels}
#'   \item{sensor_width}{The width of the camera sensor, in mm}
#' }
'calibration'

#' Photogrammetric measurements of whales
#'
#' A dataset containing Photogrammetric measurements of whales.
#' 
#' TODO: update column descriptions
#'
#' @format A data frame with 76 rows and 8 variables:
#' \describe{
#'   \item{whale_id}{Name of measured whale}
#'   \item{image}{Name of image measurements are taken from}
#'   \item{TL}{The whale's length in the image, in pixels}
#'   \item{TL.XX.0..Width}{The whale's width in the image, in pixels.  The width 
#'         is measured at XX% of the way toward the whale's head, from its 
#'         tail.}
#'   \item{barometer_altitude}{The altitude (in meters) at which the image was 
#'         taken, according to the onboard barometer}
#'   \item{laser_altitude}{The altitude (in meters) at which the image was 
#'         taken, according to the attached laser altimeter}
#'   \item{focal_length}{The focal length of the lens when the image was taken, 
#'         in mm}
#'   \item{image_width}{The width of the image, in pixels}
#'   \item{sensor_width}{The width of the camera sensor, in mm}
#' }
'whales'

#' Metadata about whale observations
#'
#' A dataset containing additional information about whales for which 
#' measurements were taken
#' 
#' TODO: update column descriptions
#'
#' @format A data frame with 76 rows and 8 variables:
#' \describe{
#'   \item{whale_id}{Name of measured whale}
#'   \item{image}{Name of image measurements are taken from}
#'   \item{TL}{The whale's length in the image, in pixels}
#'   \item{TL.XX.0..Width}{The whale's width in the image, in pixels.  The width 
#'         is measured at XX% of the way toward the whale's head, from its 
#'         tail.}
#'   \item{barometer_altitude}{The altitude (in meters) at which the image was 
#'         taken, according to the onboard barometer}
#'   \item{laser_altitude}{The altitude (in meters) at which the image was 
#'         taken, according to the attached laser altimeter}
#'   \item{focal_length}{The focal length of the lens when the image was taken, 
#'         in mm}
#'   \item{image_width}{The width of the image, in pixels}
#'   \item{sensor_width}{The width of the camera sensor, in mm}
#' }
'whale_info'
