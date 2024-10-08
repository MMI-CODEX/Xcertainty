% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{whale_info}
\alias{whale_info}
\title{Gray whale metadata}
\format{
A data frame with 293 rows and 5 columns:
\describe{
  \item{Year}{year}
  \item{Subject}{unique ID for individuals}
  \item{Group}{sex; Male, Female (F), or NA}
  \item{ObservedAge}{age in years}
  \item{AgeType}{either 'known age' if individual was seen as a calf, or 'min age' from the date of date sighting}
}
}
\source{
<https://doi.org/10.1111/gcb.17366>
}
\usage{
whale_info
}
\description{
Gray whale information and metadata that pairs with 'whales' data by "Subject"
}
\keyword{datasets}
