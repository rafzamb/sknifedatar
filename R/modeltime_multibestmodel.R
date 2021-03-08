#' @title Función para obtener el mejor modelo a partir de una modeltime table
#'
#' @description Esta funcion permite seleccionar el mejor modelo para cada serie, en función de determinada métrica de evaluación
#'
#' @details Esta funcion toma el objeto table_time de la salida de la funcion "modeltime_multifit", posteriomente se selecciona el mejor modelo en función de la métrica seleccionada
#'
#' @param .table tibble que proviene del objeto table_time de la salida de la funcion "modeltime_multifit".
#' @param .metric métrica de evaluación, proviene de modeltime_accuracy: 'mae', 'mape','mase','smape','rmse','rsq'
#' @param .optimization Es posible minimizar una métrica de error ('which.min') o maximizar el rsq ('which.max')
#'
#' @return tibble table_time filtrada por el mejor modelo
#' @export
#'
#' @examples
#'
#' library(sknifedatar)
#' data("table_time")
#'
#' best_model_emae <- modeltime_multibestmodel(.table=table_time,
#'                                             .metric=rmse,
#'                                             .optimization = which.min)
#'
#' best_model_emae
modeltime_multibestmodel <- function(.table,
                                     .metric = 'mase',
                                     .optimization = which.min){

  calibration_table_best = .table %>%
    dplyr::mutate(
      best_model = purrr::map(.data$calibration, .f=function(col){
        col %>%
          modeltime::modeltime_accuracy() %>%
          dplyr::slice(rlang::expr(!!.optimization)(!!rlang::enquo(.metric))) %>%
          dplyr::pull(.model_id)
      }),
      calibration = purrr::pmap(list(calibration, best_model), .f=function(col, m){
        col %>%
          dplyr::filter(.model_id == m)
      })
    )

  return(calibration_table_best)
}
