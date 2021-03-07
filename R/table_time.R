#' @title Modelos ajustados para el indicador EMAE
#'
#' @description Conjunto de modelos ajustados sobre el "emae_series" dataset, este objeto proviene de la salida de la funcion
#'              modeltime_multifit (object = modeltime_multifit; object$table_time)
#'
#' @format un tibble que contiene una primera columna con el nombre de las series, seguidamente la comuna "nested_column" que almacena las series de tiempo, luego una columna para cada
#'         modelo suministrado donde se almacenanan los modelos o workflows entrenados para cada series. Finalmente las columnas "nested_model" y "calibration" que guardan los "n" modelos entrenados para cada serie y las metricas de ajuste sobre la
#'         particion de test.
#'
#' @source \url{https://rafzamb.github.io/sknifedatar}
"table_time"

