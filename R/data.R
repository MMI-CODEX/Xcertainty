#' Calibration data for photogrammetric measurement error model
#'
#' A dataset containing photogrammetric measurements of known-length objects, 
#' used to estimate the characteristics of measurement errors attributed to the
#' drone platform.
#' 
#' @format A data frame with 657 rows and 10 variables:
#' \describe{
#'   \item{CO.ID}{Training object name}
#'   \item{Lpix}{Measured length of object in image (in pixels)}
#'   \item{CO.L}{True length of calibration object (in meters)}
#'   \item{image}{Name of image that measurements are taken from}
#'   \item{Baro_Alt}{The altitude (in meters) at which the image was 
#'         taken, according to the onboard barometer}
#'   \item{Laser_Alt}{The altitude (in meters) at which the image was 
#'         taken, according to the attached laser altimeter}
#'   \item{Focal_Length}{The focal length of the lens when the image was taken, 
#'         in mm}
#'   \item{Iw}{The width of the image, in pixels}
#'   \item{Sw}{The width of the camera sensor, in mm}
#'   \item{uas}{An identifier for the unoccupied aerial system (UAS) the image 
#'         and measurements are from}
#' }
'calibration'

#' Photogrammetric measurements of whales
#'
#' A dataset containing Photogrammetric measurements of whales.
#'
#' @format A data frame with 76 rows and 8 variables:
#' \describe{
#'   \item{whale_ID}{Unique identifier for the whale, matching 
#'     \code{whale_info$Subject}
#'    }
#'   \item{sex}{The whale's sex}
#'   \item{Age}{The whale's age at time of observation}
#'   \item{AgeType}{Additional details about the Age measurement}
#'   \item{year}{The year in which measurements were made}
#'   \item{date}{YYYY-MM-DD date string in which measurements were made}
#'   \item{Image}{Name of image measurements are taken from}
#'   \item{AltitudeBarometer}{The altitude (in meters) at which the image was 
#'         taken, according to the onboard barometer}
#'   \item{AltitudeLaser}{The altitude (in meters) at which the image was 
#'         taken, according to the attached laser altimeter}
#'   \item{FocalLength}{The focal length of the lens when the image was taken, 
#'         in mm}
#'   \item{ImageWidth}{The width of the image, in pixels}
#'   \item{SensorWidth}{The width of the camera sensor, in mm}
#'   \item{UAS}{An identifier for the unoccupied aerial system (UAS) the image 
#'         and measurements are from}
#'   \item{TL.pix}{Total length of whale in image (in pixels)}
#' }
'whales'

#' Metadata about whale observations
#'
#' A dataset containing additional information about whales for which 
#' measurements were taken
#'
#' @format A data frame with 293 rows and 5 variables:
#' \describe{
#'   \item{Year}{The year the observations were made}
#'   \item{Subject}{Unique identifier for the whale}
#'   \item{Group}{A categorical variable describing the whale's sex}
#'   \item{ObservedAge}{The whale's age at time of observation}
#'   \item{AgeType}{Additional details about the ObservedAge measurement}
#' }
'whale_info'
