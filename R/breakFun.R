#' Break function (required in models)
#' 
#' Implements Heaviside step function for use in nimble models, H(B) = 1 if 
#' B <= delta. For internal use only.  Not intended to be called directly by users.
#' 
#' 
#' 
#' @export
#' 
#' @param B argument to evaluate function at
#' @param delta breakpoint location
#' 
#' @importFrom nimble nimbleFunction
#'
#' @return 1 if \code{B <= delta}, and 0 otherwise  
#'
#' @examples breakFun(B = 1, delta = 0) 
#' 
breakFun <- nimble::nimbleFunction(
  run = function(B = double(0), delta = double(0)) {
    if (B <= delta) {
      ans <- 1
    } else {
      ans <- 0
    }
    return(ans)
    returnType(double(0)) 
  }
)
