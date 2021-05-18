#' @title Refit the model or models for multiple time series
#'
#' @description applies the `modeltime_refit()` function from the 'modeltime' package to multiple series and models.
#'
#' @details it takes the 'table_time' tibble generated with the  `modeltime_multifit()` function and 
#'          returns the same object but with the models fitted for the complete period. 
#'
#' @param models_table 'table_time' tibble generated from the `modeltime_multifit()` function.
#'
#' @return retrained 'table_time' object.
#' @export
#'
#' @examples
#' # Data
#' library(modeltime)
#' data_serie <- sknifedatar::table_time
#' table_time <- data_serie$table_time
#'
#' # modeltime_multirefit
#' sknifedatar::modeltime_multirefit(models_table = table_time)
#'
modeltime_multirefit <- function(models_table){

  t_calibration <- models_table$calibration
  t_serie <- models_table$nested_column

  m_refit <- mapply(function(t_calibration, t_serie){
    
    t_calibration %>% modeltime::modeltime_refit(t_serie)
    
    }, t_calibration, t_serie, SIMPLIFY = F)

  output_def <- models_table
  output_def$calibration <- m_refit

  output_def
}
