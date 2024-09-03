#' Gray whale measurement data
#'
#' An example dataset of gray whale measurements from drone-based photogrammetry.
#'
#' @format ## `gw_data`
#' A tibble with 15 rows and 34 columns:
#' \describe{
#'   \item{whale_ID}{unique individual}
#'   \item{image}{image name}
#'   \item{year}{Year}
#'   \item{DOY}{Day of Year}
#'   \item{uas}{the unoccupied aircraft system (UAS), or drone, used in data collection}
#'   \item{Focal_Length}{focal length of the camera (mm)}
#'   \item{Focal_Length_adg}{the adjusted focal length (mm) to account for internal processing that corrects for barrel distortion}
#'   \item{Sw}{sensor width (mm)}
#'   \item{Iw}{image width (px)}
#'   \item{Baro_raw}{raw altitude recorded by the barometer altimeter}
#'   \item{Launch_Ht}{the launch height of the drone}
#'   \item{Baro_Alt}{the barometer altitude adjusted for the launch height of the drone: Baro_raw + Launch_Ht}
#'   \item{Laser_Alt}{the altitude recorded by the laser (LiDAR) altimeter}
#'   \item{CO.ID}{the calibration object ID in training data}
#'   \item{TL_px}{total body length measurement (px)}
#'   \item{TL_w05.00_px, TL_w10.00_px,TL_w15.00_px, TL_w20.00_px, TL_w25.00_px, TL_w30.00_px, TL_w35.00_px, TL_w40.00_px, TL_w45.00_px, TL_w50.00_px, TL_w55.00_px, TL_w60.00_px, TL_w65.00_px, TL_w70.00_px, TL_w75.00_px, TL_w80.00_px, TL_w85.00_px, TL_w90.00_px, TL_w95.00_px}{% body width measusurement (px) of total length}
#'   ...
#' }
#' @source <https://mmi.oregonstate.edu/gemm-lab> 
"gw_data"
   