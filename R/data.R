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

#' Calibration data for photogrammetric measurement error model
#'
#' A dataset containing photogrammetric measurements of known-length objects, 
#' used to estimate the characteristics of measurement errors attributed to the
#' drone platform.
#' 
#' @format A data frame with 46 rows and 9 variables:
#' \describe{
#'   \item{RRR.pix}{Measured length of object in image (in pixels)}
#'   \item{L_train}{True length of calibration object (in meters)}
#'   \item{Images}{Name of image that measurements are taken from}
#'   \item{Baro...Ht}{The altitude (in meters) at which the image was 
#'         taken, according to the onboard barometer}
#'   \item{Laser_Alt}{The altitude (in meters) at which the image was 
#'         taken, according to the attached laser altimeter}
#'   \item{Focal.length}{The focal length of the lens when the image was taken, 
#'         in mm}
#'   \item{Iw}{The width of the image, in pixels}
#'   \item{Sw}{The width of the camera sensor, in mm}
#'   \item{Aircraft}{An identifier for the unoccupied aerial system (UAS) the 
#'         image and measurements are from}
#' }
'calibration2'

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

#' Photogrammetric measurements of whales
#'
#' A dataset containing Photogrammetric measurements of whales.  In particular,
#' the dataset includes measurements for a whale's total length and it's width 
#' along its body, at 5% increments of total length.
#'
#' @format A data frame with 29 rows and 28 variables:
#' \describe{
#'   \item{Animal_ID}{Unique identifier for the whale}
#'   \item{Image}{Name of image measurements are taken from}
#'   \item{BaroAlt}{The altitude (in meters) at which the image was 
#'         taken, according to the onboard barometer}
#'   \item{LaserAlt}{The altitude (in meters) at which the image was 
#'         taken, according to the attached laser altimeter}
#'   \item{Focal_Length}{The focal length of the lens when the image was taken, 
#'         in mm}
#'   \item{Iw}{The width of the image, in pixels}
#'   \item{Sw}{The width of the camera sensor, in mm}
#'   \item{Aircraft}{An identifier for the unoccupied aerial system (UAS) the 
#'         image and measurements are from}
#'   \item{TL}{Total length of whale in image (m), pre-computed from pixels
#'         using the reported laser altimeter measurement}
#'   \item{TL.10.0..Width}{Width of whale (m), pre-computed from pixels using 
#'         the reported laser altimeter measurement.  Width is taken at a 
#'         cross-section perpendicular to the whale's center line, running
#'         from the middle of the rostrum (loosely, the whale's beak/nose) to 
#'         the middle of the peduncle (the point where the tail connects to the 
#'         rest of the body).  The cross-section is taken 10% of the distance 
#'         from the animal's rostrum to its peduncle.}
#'   \item{TL.15.0..Width}{Same as \code{TL.10.0..Width}, but taken at a 
#'         cross-section that is 15% of the distance from the animal's rostrum 
#'         to its peduncle.}
#'   \item{TL.20.0..Width}{Same as \code{TL.10.0..Width}, but taken at a 
#'         cross-section that is 20% of the distance from the animal's rostrum 
#'         to its peduncle.}
#'   \item{TL.25.0..Width}{Same as \code{TL.10.0..Width}, but taken at a 
#'         cross-section that is 25% of the distance from the animal's rostrum 
#'         to its peduncle.}
#'   \item{TL.30.0..Width}{Same as \code{TL.10.0..Width}, but taken at a 
#'         cross-section that is 30% of the distance from the animal's rostrum 
#'         to its peduncle.}
#'   \item{TL.35.0..Width}{Same as \code{TL.10.0..Width}, but taken at a 
#'         cross-section that is 35% of the distance from the animal's rostrum 
#'         to its peduncle.}
#'   \item{TL.40.0..Width}{Same as \code{TL.10.0..Width}, but taken at a 
#'         cross-section that is 40% of the distance from the animal's rostrum 
#'         to its peduncle.}
#'   \item{TL.45.0..Width}{Same as \code{TL.10.0..Width}, but taken at a 
#'         cross-section that is 45% of the distance from the animal's rostrum 
#'         to its peduncle.}
#'   \item{TL.50.0..Width}{Same as \code{TL.10.0..Width}, but taken at a 
#'         cross-section that is 50% of the distance from the animal's rostrum 
#'         to its peduncle.}
#'   \item{TL.55.0..Width}{Same as \code{TL.10.0..Width}, but taken at a 
#'         cross-section that is 55% of the distance from the animal's rostrum 
#'         to its peduncle.}
#'   \item{TL.60.0..Width}{Same as \code{TL.10.0..Width}, but taken at a 
#'         cross-section that is 60% of the distance from the animal's rostrum 
#'         to its peduncle.}
#'   \item{TL.65.0..Width}{Same as \code{TL.10.0..Width}, but taken at a 
#'         cross-section that is 65% of the distance from the animal's rostrum 
#'         to its peduncle.}
#'   \item{TL.70.0..Width}{Same as \code{TL.10.0..Width}, but taken at a 
#'         cross-section that is 70% of the distance from the animal's rostrum 
#'         to its peduncle.}
#'   \item{TL.75.0..Width}{Same as \code{TL.10.0..Width}, but taken at a 
#'         cross-section that is 75% of the distance from the animal's rostrum 
#'         to its peduncle.}
#'   \item{TL.80.0..Width}{Same as \code{TL.10.0..Width}, but taken at a 
#'         cross-section that is 80% of the distance from the animal's rostrum 
#'         to its peduncle.}
#'   \item{TL.85.0..Width}{Same as \code{TL.10.0..Width}, but taken at a 
#'         cross-section that is 85% of the distance from the animal's rostrum 
#'         to its peduncle.}
#'   \item{TL.90.0..Width}{Same as \code{TL.10.0..Width}, but taken at a 
#'         cross-section that is 90% of the distance from the animal's rostrum 
#'         to its peduncle.}
#'   \item{TL.95.0..Width}{Same as \code{TL.10.0..Width}, but taken at a 
#'         cross-section that is 95% of the distance from the animal's rostrum 
#'         to its peduncle.}
#'   \item{TL.5.0..Width}{Same as \code{TL.10.0..Width}, but taken at a 
#'         cross-section that is 5% of the distance from the animal's rostrum 
#'         to its peduncle.}
#' }
'body_condition_measurements'

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

#' Sample MCMC output
#' 
#' Posterior estimates for lengths and widths of a whale.  See 
#' \code{help("body_condition")} for computation details.
#'
#' @format A list with 5 elements:
#' \describe{
#'   \item{altimeters}{Posterior samples and summaries for altimeters}
#'   \item{images}{Posterior samples and summaries for images}
#'   \item{pixel_error}{Posterior samples and summaries for pixel error 
#'     component of measurement error model}
#'   \item{objects}{Posterior samples and summaries for unknown object lengths 
#'     that were estimated}
#'  \item{summaries}{\code{data.frame}s with posterior summaries, collated from
#'     all other list elements.}
#' }
'body_condition_measurement_estimates'
