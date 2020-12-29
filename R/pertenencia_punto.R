#' @title Puntos geolocalizados dentro de un radio de metros de cercanía
#'
#' @description Dado dos conjuntos de puntos geolocalizados, esta función permite determinar para cada punto del primer conjunto de datos, cuál o cuáles de los puntos del segundo conjunto de datos están dentro de un radio de metros determinado.
#'
#' @seealso \href{https://rafael-zambrano-blog-ds.netlify.app/posts}{Blog Posts Rafael Zambrano}
#'
#' @param data data frame que representa los puntos del primer conjunto de datos,
#' @param referencia data frame que representa los segundos puntos de datos, sobre los cuales se evaluará cuáles de ellos están dentro del radio de cercanía de los puntos del primer conjunto de datos, las columnas de geolocalización deben estar nombradas como "long" y "lat".
#' @param metros radio en metros para evaluar la cercanía.
#'
#' @details Las columnas de geolocalización de ambos conjuntos de datos deben estar nombradas como "long" y "lat".
#'
#' @importFrom rlang .data
#' @return Una lista del mismo tamaño que el primer conjunto de datos, cada elemento tiene como valor el o los
#'   puntos del segundo conjunto de datos que estén dentro del radio de cercanía.
#'
#' @export
#'
#' @examples
#' pertenencia_punto(data = crimes, referencia = intercepcion_calles, metros = 150)
pertenencia_punto = function(data, referencia, metros){

  crime = data %>%
    dplyr::select(.data$long,.data$lat) %>%
    split(1:nrow(data))

  esquinas = referencia[,c("long","lat")]

  vector_esquinas= c()

  Esquina = parallel::mclapply(crime, function(x){

    for (i in 1:nrow(esquinas)) {

      vector_localizacion = geosphere::distm(x,  esquinas[i,], fun = geosphere::distHaversine)

      vector_esquinas[i] = vector_localizacion
    }

    vector = which(vector_esquinas <= metros)

    n_total = ifelse(length(vector) == 0, 0, vector)
  })
  return(Esquina)
}
