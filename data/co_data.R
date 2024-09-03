#' Calibration (training) data for gray whale example
#'
#' Photogrammetric measurements of known-sized calibration objects to be used as training data.
#'
#' @format ## `co_data`
#' A data frame with 118 rows and 15 columns:
#' \describe{
#'   \item{uas}{the unoccupied aircraft system (UAS), or drone, used in data collection}
#'   \item{CO.ID}{the calibration object ID in training data}
#'   \item{CO.L}{the true length of the calibration object (m)}
#'   \item{year}{Year}
#'   \item{image}{image name}
#'   \item{date}{Date}
#'   \item{Sw}{sensor width (mm)}
#'   \item{Iw}{image width (px)}
#'   \item{Focal_Length}{focal length of the camera (mm)}
#'   \item{Focal_Length_adg}{the adjusted focal length (mm) to account for internal processing that corrects for barrel distortion}
#'   \item{Baro_raw}{raw altitude recorded by the barometer altimeter}
#'   \item{Launch_Ht}{the launch height of the drone}
#'   \item{Baro_Alt}{the barometer altitude adjusted for the launch height of the drone: Baro_raw + Launch_Ht}
#'   \item{Laser_Alt}{the altitude recorded by the laser (LiDAR) altimeter}
#'   \item{L_px}{length measurement (px)}
#'   ...
#' }
#' @source <https://doi.org/10.1139/dsa-2023-0051> 
"co_data"