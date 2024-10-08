% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{gw_data}
\alias{gw_data}
\title{Gray whale measurement data}
\format{
A tibble with 15 rows and 34 columns:
\describe{
  \item{whale_ID}{unique individual}
  \item{image}{image name}
  \item{year}{Year}
  \item{DOY}{Day of Year}
  \item{uas}{the unoccupied aircraft system (UAS), or drone, used in data collection}
  \item{Focal_Length}{focal length of the camera (mm)}
  \item{Focal_Length_adj}{the adjusted focal length (mm) to account for internal processing that corrects for barrel distortion}
  \item{Sw}{sensor width (mm)}
  \item{Iw}{image width (px)}
  \item{Baro_raw}{raw altitude recorded by the barometer altimeter}
  \item{Launch_Ht}{the launch height of the drone}
  \item{Baro_Alt}{the barometer altitude adjusted for the launch height of the drone: Baro_raw + Launch_Ht}
  \item{Laser_Alt}{the altitude recorded by the laser (LiDAR) altimeter}
  \item{CO.ID}{the calibration object ID in training data}
  \item{TL_px}{total body length measurement (px)}
  \item{TL_w05.00_px}{Body width measurement (px) at 5\% of total length}
  \item{TL_w10.00_px}{Body width measurement (px) at 10\% of total length}
  \item{TL_w15.00_px}{Body width measurement (px) at 15\% of total length}
  \item{TL_w20.00_px}{Body width measurement (px) at 20\% of total length}
  \item{TL_w25.00_px}{Body width measurement (px) at 25\% of total length}
  \item{TL_w30.00_px}{Body width measurement (px) at 30\% of total length}
  \item{TL_w35.00_px}{Body width measurement (px) at 35\% of total length}
  \item{TL_w40.00_px}{Body width measurement (px) at 40\% of total length}
  \item{TL_w45.00_px}{Body width measurement (px) at 45\% of total length}
  \item{TL_w50.00_px}{Body width measurement (px) at 50\% of total length}
  \item{TL_w55.00_px}{Body width measurement (px) at 55\% of total length}
  \item{TL_w60.00_px}{Body width measurement (px) at 60\% of total length}
  \item{TL_w65.00_px}{Body width measurement (px) at 65\% of total length}
  \item{TL_w70.00_px}{Body width measurement (px) at 70\% of total length}
  \item{TL_w75.00_px}{Body width measurement (px) at 75\% of total length}
  \item{TL_w80.00_px}{Body width measurement (px) at 80\% of total length}
  \item{TL_w85.00_px}{Body width measurement (px) at 85\% of total length}
  \item{TL_w90.00_px}{Body width measurement (px) at 90\% of total length}
  \item{TL_w95.00_px}{Body width measurement (px) at 95\% of total length}
}
}
\source{
<https://mmi.oregonstate.edu/gemm-lab>
}
\usage{
gw_data
}
\description{
An example dataset of gray whale measurements from drone-based photogrammetry.
}
\keyword{datasets}
