#' Muestra de delitos ocurridos en la ciudad de Buenos Aires
#'
#' Conjunto de datos que registra la fecha, franja horaria, tipo de delito y geolocalización de crimenes ocurridos entre el 2017 y 2019.
#'
#' @format data frame con 100 filas y 9 columnas:
#' \describe{
#'   \item{id:}{id}
#'   \item{fecha:}{fecha}
#'   \item{franja_horaria:}{horas del 0 al 23}
#'   \item{tipo_delito:}{tipo_delito}
#'   \item{subtipo_delito:}{subtipo_delito}
#'   \item{comuna:}{comuna de CABA}
#'   \item{barrio:}{barrio de CABA}
#'   \item{lat:}{latitud}
#'   \item{long:}{longitud}
#'   ...
#' }
#'
#' @source \url{https://data.buenosaires.gob.ar/dataset/delitos/}
"crimes"
