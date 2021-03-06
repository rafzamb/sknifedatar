% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/intercepcion_calles.R
\docType{data}
\name{intercepcion_calles}
\alias{intercepcion_calles}
\title{Dataset of the intersection of the main streets and avenues of the city of Buenos Aires, Argentina.}
\format{
A data frame with 2417 rows y 3 columns:
\describe{
\item{id}{corner id}
\item{lat}{latitude}
\item{long}{longitude}
...
}
}
\source{
\url{https://rafzamb.github.io/sknifedatar/}
}
\usage{
intercepcion_calles
}
\description{
Data set that records the date, time slot, type of crime and geolocation of crimes that occurred between 2017 and 2019
The data was obtained from the \href{https://www.openstreetmap.org/}{Openstreetmap}  using the
\href{https://docs.ropensci.org/osmdata/}{osmdata} package, later they were transformed until obtaining the
tabular structure that is presented here.
}
\keyword{datasets}
