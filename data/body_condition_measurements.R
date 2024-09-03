#' Humpback whale measurement data from Duke University's Marine Robotics and Remote Sensing (MaRRS) Lab
#'
#' Photogrammetric measurements of humpback whales to estimate total body length and body condition.
#'
#' @format ## `body_conditions_measurements`
#' A data frame with 29 rows and 28 columns:
#' \describe{
#'   \item{Animal_ID}{unique ID for the individual whale}
#'   \item{TL}{total body length measurement (m)}
#'   \item{TL.10.0..Width, TL.15.0..Width, TL.20.0..Width, TL.25.0..Width, TL.30.0..Width, TL.35.0..Width, TL.40.0..Width, TL.45.0..Width, TL.5.0..Width, TL.50.0..Width, TL.55.0..Width, TL.60.0..Width, TL.65.0..Width, TL.70.0..Width, TL.75.0..Width, TL.80.0..Width, TL.85.0..Width, TL.90.0..Width, TL.95.0..Width}{% body width measusurement (m) of total length}
#'   \item{Image}{image name}
#'   \item{BaroAlt}{the barometer altitude adjusted for the launch height of the drone}
#'   \item{LaserAlt}{the altitude recorded by the laser (LiDAR) altimeter}
#'   \item{Focal_Length}{focal length of the camera (mm)}
#'   \item{Iw}{image width (px)} 
#'   \item{Sw}{sensor width (mm)}
#'   \item{Aircraft}{the unoccupied aircraft system (UAS), or drone, used in data collection}
#'   ...
#' }
#' @source <https://doi.org/10.3389/fmars.2021.749943> 
"body_conditions_measurements"

 
 