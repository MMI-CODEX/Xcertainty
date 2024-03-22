# Break function (required in models)
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
