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

#' Humpback whale measurement data from Duke University's Marine Robotics and Remote Sensing (MaRRS) Lab
#'
#' Photogrammetric measurements of humpback whales to estimate total body length and body condition.
#'
#' @format A data frame with 29 rows and 28 columns:
#' \describe{
#'   \item{Animal_ID}{unique ID for the individual whale}
#'   \item{TL}{total body length measurement (m)}
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
#'   \item{Image}{image name}
#'   \item{BaroAlt}{the barometer altitude adjusted for the launch height of the drone}
#'   \item{LaserAlt}{the altitude recorded by the laser (LiDAR) altimeter}
#'   \item{Focal_Length}{focal length of the camera (mm)}
#'   \item{Iw}{image width (px)} 
#'   \item{Sw}{sensor width (mm)}
#'   \item{Aircraft}{the unoccupied aircraft system (UAS), or drone, used in data collection}
#' }
#' @source <https://doi.org/10.3389/fmars.2021.749943> 
"body_condition_measurements"

#' Calibration (training) data
#'
#' Photogrammetric measurements of known-sized calibration objects to be used as training data.
#'
#' @format A data frame with 657 rows and 10 columns:
#' \describe{
#'   \item{CO.ID}{the calibration object ID in training data}
#'   \item{Lpix}{length measurement (px)}
#'   \item{CO.L}{the true length of the calibration object (m)}
#'   \item{image}{image name}
#'   \item{Baro_Alt}{the barometer altitude adjusted for the launch height of the drone: Baro_raw + Launch_Ht}
#'   \item{Laser_Alt}{the altitude recorded by the laser (LiDAR) altimeter}
#'   \item{Focal_Length}{focal length of the camera (mm)}
#'   \item{Iw}{image width (px)} 
#'   \item{Sw}{sensor width (mm)}
#'   \item{uas}{the unoccupied aircraft system (UAS), or drone, used in data collection}
#' }
#' @source <https://doi.org/10.1111/gcb.17366> 
"calibration"

#' Calibration (training) data from Duke University's Marine Robotics and Remote Sensing (MaRRS) Lab
#'
#' Photogrammetric measurements of known-sized calibration objects to be used as training data.
#'
#' @format A data frame with 46 rows and 9 columns:
#' \describe{
#'   \item{L_train}{the true length of the calibration object (m)}
#'   \item{RRR.pix}{length measurement (px)}
#'   \item{Images}{image name}
#'   \item{Baro...Ht}{the barometer altitude adjusted for the launch height of the dronet}
#'   \item{Laser_Alt}{the altitude recorded by the laser (LiDAR) altimeter}
#'   \item{Focal.length}{focal length of the camera (mm)}
#'   \item{Iw}{image width (px)} 
#'   \item{Sw}{sensor width (mm)}
#'   \item{Aircraft}{the unoccupied aircraft system (UAS), or drone, used in data collection}
#' }
#' @source <https://doi.org/10.3389/fmars.2021.749943> 
"calibration2"

#' Calibration (training) data for gray whale example
#'
#' Photogrammetric measurements of known-sized calibration objects to be used as training data.
#'
#' @format A data frame with 118 rows and 15 columns:
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
#'   \item{Focal_Length_adj}{the adjusted focal length (mm) to account for internal processing that corrects for barrel distortion}
#'   \item{Baro_raw}{raw altitude recorded by the barometer altimeter}
#'   \item{Launch_Ht}{the launch height of the drone}
#'   \item{Baro_Alt}{the barometer altitude adjusted for the launch height of the drone: Baro_raw + Launch_Ht}
#'   \item{Laser_Alt}{the altitude recorded by the laser (LiDAR) altimeter}
#'   \item{Lpix}{length measurement (px)}
#' }
#' @source <https://doi.org/10.1139/dsa-2023-0051> 
"co_data"

#' Gray whale measurement data
#'
#' An example dataset of gray whale measurements from drone-based photogrammetry.
#'
#' @format A tibble with 15 rows and 34 columns:
#' \describe{
#'   \item{whale_ID}{unique individual}
#'   \item{image}{image name}
#'   \item{year}{Year}
#'   \item{DOY}{Day of Year}
#'   \item{uas}{the unoccupied aircraft system (UAS), or drone, used in data collection}
#'   \item{Focal_Length}{focal length of the camera (mm)}
#'   \item{Focal_Length_adj}{the adjusted focal length (mm) to account for internal processing that corrects for barrel distortion}
#'   \item{Sw}{sensor width (mm)}
#'   \item{Iw}{image width (px)}
#'   \item{Baro_raw}{raw altitude recorded by the barometer altimeter}
#'   \item{Launch_Ht}{the launch height of the drone}
#'   \item{Baro_Alt}{the barometer altitude adjusted for the launch height of the drone: Baro_raw + Launch_Ht}
#'   \item{Laser_Alt}{the altitude recorded by the laser (LiDAR) altimeter}
#'   \item{CO.ID}{the calibration object ID in training data}
#'   \item{TL_px}{total body length measurement (px)}
#'   \item{TL_w05.00_px}{Body width measurement (px) at 5\% of total length}
#'   \item{TL_w10.00_px}{Body width measurement (px) at 10\% of total length}
#'   \item{TL_w15.00_px}{Body width measurement (px) at 15\% of total length}
#'   \item{TL_w20.00_px}{Body width measurement (px) at 20\% of total length}
#'   \item{TL_w25.00_px}{Body width measurement (px) at 25\% of total length}
#'   \item{TL_w30.00_px}{Body width measurement (px) at 30\% of total length}
#'   \item{TL_w35.00_px}{Body width measurement (px) at 35\% of total length}
#'   \item{TL_w40.00_px}{Body width measurement (px) at 40\% of total length}
#'   \item{TL_w45.00_px}{Body width measurement (px) at 45\% of total length}
#'   \item{TL_w50.00_px}{Body width measurement (px) at 50\% of total length}
#'   \item{TL_w55.00_px}{Body width measurement (px) at 55\% of total length}
#'   \item{TL_w60.00_px}{Body width measurement (px) at 60\% of total length}
#'   \item{TL_w65.00_px}{Body width measurement (px) at 65\% of total length}
#'   \item{TL_w70.00_px}{Body width measurement (px) at 70\% of total length}
#'   \item{TL_w75.00_px}{Body width measurement (px) at 75\% of total length}
#'   \item{TL_w80.00_px}{Body width measurement (px) at 80\% of total length}
#'   \item{TL_w85.00_px}{Body width measurement (px) at 85\% of total length}
#'   \item{TL_w90.00_px}{Body width measurement (px) at 90\% of total length}
#'   \item{TL_w95.00_px}{Body width measurement (px) at 95\% of total length}
#' }
#' @source <https://mmi.oregonstate.edu/gemm-lab> 
"gw_data"

#' Gray whale metadata
#'
#' Gray whale information and metadata that pairs with 'whales' data by "Subject"
#'
#' @format A data frame with 293 rows and 5 columns:
#' \describe{
#'   \item{Year}{year}
#'   \item{Subject}{unique ID for individuals}
#'   \item{Group}{sex; Male, Female (F), or NA}
#'   \item{ObservedAge}{age in years}
#'   \item{AgeType}{either 'known age' if individual was seen as a calf, or 'min age' from the date of date sighting}
#' }
#' @source <https://doi.org/10.1111/gcb.17366> 
"whale_info"

#' Gray whale metadata
#'
#' Gray whale information and metadata that pairs with 'whales' data by "Subject"
#'
#' @format A data frame with 826 rows and 14 columns:
#' \describe{
#'   \item{whale_ID}{unique individual}
#'   \item{sex}{Female, Male, or NA}
#'   \item{Age}{age in years}
#'   \item{AgeType}{either 'known age' if individual was seen as a calf, or 'min age' from the date of date sighting}
#'   \item{year}{Year}
#'   \item{date}{Date}
#'   \item{Image}{image name}
#'   \item{AltitudeBarometer}{the barometer altitude adjusted for the launch height of the drone}
#'   \item{AltitudeLaser}{the altitude recorded by the laser (LiDAR) altimeter}
#'   \item{FocalLength}{focal length of the camera (mm)}
#'   \item{ImageWidth}{image width (px)} 
#'   \item{SensorWidth}{sensor width (mm)}
#'   \item{UAS}{the unoccupied aircraft system (UAS), or drone, used in data collection}
#'   \item{TL.pix}{the total body length measurement in pixels}
#' }
#' @source <https://doi.org/10.1111/gcb.17366> 
"whales"
