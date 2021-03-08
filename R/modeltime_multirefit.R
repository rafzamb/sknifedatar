#' @title Función para reajustar el o los modelos para múltiples series de tiempo
#'
#' @description Esta función permite aplicar la función "**modeltime_refit()**" de \href{https://business-science.github.io/modeltime/}{**modeltime**}
#'              a múltiples series y modelos.
#'
#' @details Toma como input el objeto "**table_time**" de la salida de la función "**modeltime_multifit**" y
#'          devuelve el mismo objeto pero entrenado en todo el período.
#'
#' @param models_table tibble que proviene del objeto "**table_time**" de la salida de la función "**modeltime_multifit**".
#'
#' @return Devuelve el objeto "**table_time**" recalibrado.
#' @export
#'
#' @examples
#' library(sknifedatar)
#' library(modeltime)
#'
#' data("table_time")
#'
#' table_time_refit <- modeltime_multirefit(models_table = table_time)
#'
#' table_time_refit
modeltime_multirefit <- function(models_table){

  t_calibration <- models_table$calibration
  t_serie <- models_table$nested_column

  m_refit = mapply(function(t_calibration, t_serie){

    t_calibration %>%
      modeltime::modeltime_refit(t_serie)

  },t_calibration, t_serie, SIMPLIFY = F)

  output_def = models_table
  output_def$calibration = m_refit

  output_def
}
