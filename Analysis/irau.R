#' Inverse RAU

# % IRAU   rationalized arcsine transform
# % IRAU(RAU,N) transforms the RAU values to the percent correct scores (0..100%) 
# % using the rationalized arcsine transform. N gives the number of repetitions.
# % 
# % The formula are based on Sherbecoe and Studebaker,
# % Int. J. of Audiology 2004; 43; 442-448
# % 
# % See also RAU.
#
# % 30.8.2007, Piotr Majdak
# % 15.07.2026, Lars Bramsløw ported from Matlab


irau <- function(rau, N) {
  
  # Input validation
  stopifnot(is.numeric(rau))
  stopifnot(is.numeric(N))
  
  # Main code
  th <- (pi/146*(rau+23))
  X <- 50*(1-(sqrt(N*(N+2)-(1/tan(th))^2)/N)*cos(th));
  
  # Return result
  return(X)
}