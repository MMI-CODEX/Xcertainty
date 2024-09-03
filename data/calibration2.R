#' Calibration (training) data from Duke University's Marine Robotics and Remote Sensing (MaRRS) Lab
#'
#' Photogrammetric measurements of known-sized calibration objects to be used as training data.
#'
#' @format ## `calibration2`
#' A data frame with 46 rows and 9 columns:
#' \describe{
#'   \item{L_train}{the true length of the calibration object (m)}
#'   \item{RRR.px}{length measurement (px)}
#'   \item{Images}{image name}
#'   \item{Baro...Ht}{the barometer altitude adjusted for the launch height of the dronet}
#'   \item{Laser_Alt}{the altitude recorded by the laser (LiDAR) altimeter}
#'   \item{Focal.length}{focal length of the camera (mm)}
#'   \item{Iw}{image width (px)} 
#'   \item{Sw}{sensor width (mm)}
#'   \item{Aircraft}{the unoccupied aircraft system (UAS), or drone, used in data collection}
#'   ...
#' }
#' @source <https://doi.org/10.3389/fmars.2021.749943> 
"calibration2"