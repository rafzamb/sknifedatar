#' Muestra la intercepciòn de las principales calles y avenidas de la ciudad de Buenos Aires
#'
#' Conjunto de datos que registra la fecha, franja horaria, tipo de delito y geolocalización de crimenes ocurridos entre el 2017 y 2019
#' diamonds.  Los datos fueron extraídos del repositorio de \href{https://www.openstreetmap.org/}{Openstreetmap}  a través del
#'  paquete \href{https://docs.ropensci.org/osmdata}{osmdata}, posteriormente fueron transformados hasta obtener la estructura tabular
#'   que acá se presenta.
#'
#' @format A data frame con 2417 filas y 3 columnas:
#' \describe{
#'   \item{id}{id de la esquina}
#'   \item{lat}{latitud}
#'   \item{long}{longitud}
#'   ...
#' }
#' @source \url{https://rafzamb.github.io/sknifedatar/}
"intercepcion_calles"
