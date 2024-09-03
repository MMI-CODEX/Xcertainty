#' Gray whale metadata
#'
#' Gray whale information and metadata that pairs with 'whales' data by "Subject"
#'
#' @format ## `whale_info`
#' A data frame with 293 rows and 5 columns:
#' \describe{
#'   \item{Year}{year}
#'   \item{Subject}{unique ID for individuals}
#'   \item{Group}{sex; Male, Female (F), or NA}
#'   \item{ObservedAge}{age in years}
#'   \item{AgeType}{either 'known age' if individual was seen as a calf, or 'min age' from the date of date sighting}
#'   ...
#' }
#' @source <https://doi.org/10.1111/gcb.17366> 
"whale_info"