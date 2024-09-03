#' Calibration (training) data
#'
#' Photogrammetric measurements of known-sized calibration objects to be used as training data.
#'
#' @format ## `calibration`
#' A data frame with 657 rows and 10 columns:
#' \describe{
#'   \item{CO.ID}{the calibration object ID in training data}
#'   \item{L_px}{length measurement (px)}
#'   \item{CO.L}{the true length of the calibration object (m)}
#'   \item{image}{image name}
#'   \item{Baro_Alt}{the barometer altitude adjusted for the launch height of the drone: Baro_raw + Launch_Ht}
#'   \item{Laser_Alt}{the altitude recorded by the laser (LiDAR) altimeter}
#'   \item{Focal_Length}{focal length of the camera (mm)}
#'   \item{Iw}{image width (px)} 
#'   \item{Sw}{sensor width (mm)}
#'   \item{uas}{the unoccupied aircraft system (UAS), or drone, used in data collection}
#'   ...
#' }
#' @source <https://doi.org/10.1111/gcb.17366> 
"calibration"