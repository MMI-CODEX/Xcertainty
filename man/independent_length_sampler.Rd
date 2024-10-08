% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/independent_length_sampler.R
\name{independent_length_sampler}
\alias{independent_length_sampler}
\title{MCMC sampler for individuals with independent measurements.}
\usage{
independent_length_sampler(data, priors, package_only = FALSE)
}
\arguments{
\item{data}{Photogrammetric data formatted for Xcertainty models, required to
be an object with class \code{obs.parsed}, which can be obtained by running
\code{parse_observations()}}

\item{priors}{\code{list} with components that define the model's prior 
distribution.  See \code{help("flatten_data")} for more details.}

\item{package_only}{\code{TRUE} to return the formatted data used to build 
the sampler, otherwise \code{FALSE} to return the sampler}
}
\value{
outputs a function to run a sampler, the function arguments are: 
\describe{
 \item{niter}{set the number of iterations}
 \item{burn}{set the number samples to discard}
 \item{thin}{set the thinning rate}
 }
}
\description{
Build an MCMC sampler that uses calibration data to estimate independent,
unknown measurements. This model assumes all Subject/Measurement/Timepoint 
combinations are independent. So, this sample is well suited for data 
containing individuals that either have no replicate samples or 
have replicate samples that are independent over time, such as body condition 
which can increase or decrease over time, as opposed to length which should 
be stable or increase over time. It can also be used to estimate lengths 
when there are replicate measurements. However, since the model assumes all 
Subject/Measurement/Timepoint combinations are independent, no strength will 
be borrowed across temporal replication of a subject's measurements, 
for example.
}
\examples{
# load example wide-format data
data("calibration")
data("whales")
data("whale_info")

# parse calibration study
calibration_data = parse_observations(
  x = calibration, 
  subject_col = 'CO.ID',
  meas_col = 'Lpix', 
  tlen_col = 'CO.L', 
  image_col = 'image', 
  barometer_col = 'Baro_Alt',
  laser_col = 'Laser_Alt', 
  flen_col = 'Focal_Length', 
  iwidth_col = 'Iw', 
  swidth_col = 'Sw',
  uas_col = 'uas'
)

# parse field study
whale_data = parse_observations(
  x = whales, 
  subject_col = 'whale_ID',
  meas_col = 'TL.pix', 
  image_col = 'Image', 
  barometer_col = 'AltitudeBarometer',
  laser_col = 'AltitudeLaser', 
  flen_col = 'FocalLength', 
  iwidth_col = 'ImageWidth', 
  swidth_col = 'SensorWidth', 
  uas_col = 'UAS',
  timepoint_col = 'year'
)

# build sampler
sampler_data = independent_length_sampler(
  data = combine_observations(calibration_data, whale_data),
  priors = list(
    image_altitude = c(min = 0.1, max = 130),
    altimeter_bias = rbind(
      data.frame(altimeter = 'Barometer', mean = 0, sd = 1e2),
      data.frame(altimeter = 'Laser', mean = 0, sd = 1e2)
    ),
    altimeter_variance = rbind(
      data.frame(altimeter = 'Barometer', shape = .01, rate = .01),
      data.frame(altimeter = 'Laser', shape = .01, rate = .01)
    ),
    altimeter_scaling = rbind(
      data.frame(altimeter = 'Barometer', mean = 1, sd = 1e1),
      data.frame(altimeter = 'Laser', mean = 1, sd = 1e1)
    ),
    pixel_variance = c(shape = .01, rate = .01),
    object_lengths = c(min = .01, max = 20)
  ),
  # set to false to return sampler function
  package_only = TRUE
)
}
