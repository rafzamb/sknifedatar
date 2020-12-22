#' Pertenencia de localizaciones
#'
#' @param data : dataframe con las columnas de geolocalización nombradas como "long" y "lat"
#' @param referencia : dataframe con las columnas de geolocalización nombradas como "long" y "lat"
#' @param metros : distancia en metros
#'
#' @return
#' @export
#'
#' @examples
pertenencia_punto = function(data,referencia,metros){

  crime = data %>%
    dplyr::select(long,lat) %>%
    split(1:nrow(.))

  esquinas = referencia[,c("long","lat")]

  vector_esquinas= c()

  Esquina = parallel::mclapply(crime, function(x){

    for (i in 1:nrow(esquinas)) {

      #print(i)

      vector_localizacion = geosphere::distm(x,  esquinas[i,], fun = geosphere::distHaversine)

      vector_esquinas[i] = vector_localizacion
    }

    vector = which(vector_esquinas <= metros)

    n_total = ifelse(length(vector) == 0, 0, vector)
  })
  return(Esquina)
}
