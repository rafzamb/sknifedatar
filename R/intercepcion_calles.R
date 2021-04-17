#' Dataset of the intersection of the main streets and avenues of the city of Buenos Aires, Argentina.
#'
#' Data set that records the date, time slot, type of crime and geolocation of crimes that occurred between 2017 and 2019
#' The data was obtained from the \href{https://www.openstreetmap.org/}{Openstreetmap}  using the
#' \href{https://docs.ropensci.org/osmdata}{osmdata} package, later they were transformed until obtaining the tabular structure that is presented here.
#'
#' @format A data frame with 2417 rows y 3 columns:
#' \describe{
#'   \item{id}{corner id}
#'   \item{lat}{latitude}
#'   \item{long}{longitude}
#'   ...
#' }
#' @source \url{https://rafzamb.github.io/sknifedatar/}
"intercepcion_calles"
