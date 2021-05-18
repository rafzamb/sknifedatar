#' Buenos Aires crimes data
#'
#' @description 
#' Data set that records the date, time, type of crime and geolocation of crimes that occurred between 2017 and 2019.
#' The data was extracted from the public repository of \href{http://data.buenosaires.gob.ar/dataset/delitos}{GCBA}
#'
#' @format data frame with 100 rows y 9 columns:
#' \describe{
#'   \item{id:}{id}
#'   \item{fecha:}{date}
#'   \item{franja_horaria:}{hour from 0 to 23}
#'   \item{tipo_delito:}{crime type}
#'   \item{subtipo_delito:}{crime subtype}
#'   \item{comuna:}{commune}
#'   \item{barrio:}{neighborhood}
#'   \item{lat:}{latitude}
#'   \item{long:}{longitude}
#'   ...
#' }
#'
#' @source \url{http://data.buenosaires.gob.ar/dataset/delitos}
"crimes"
