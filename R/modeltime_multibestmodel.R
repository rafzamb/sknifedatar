#' @title Función para obtener el mejor modelo a partir de una modeltime table
#'
#' @description Esta función permite seleccionar el mejor modelo para cada serie, en función de determinada métrica de evaluación.
#'
#' @details Esta función toma el objeto "**table_time**" de la salida de la función "**modeltime_multifit**",
#'          posteriomente se selecciona el mejor modelo en función de la métrica seleccionada.
#'
#' @param .table tibble que proviene del objeto "**table_time**" de la salida de la función "**modeltime_multifit**".
#' @param .metric métrica de evaluación, proviene de "**modeltime_accuracy**": 'mae', 'mape','mase','smape','rmse','rsq'.
#' @param .minimize valor logico, TRUE para minimizar la métrica de error, FALSE para maximizar, por defeto es TRUE.
#'
#' @return tibble table_time filtrada por el mejor modelo.
#' @export
#' @importFrom utils head
#'
#' @examples
#'
#' ## libraries
#' library(modeltime)
#' library(sknifedatar)
#' 
#' # Data
#' data_serie <- sknifedatar::table_time
#'                                       
#' # best_model_emae
#' best_model_emae <- modeltime_multibestmodel(.table = data_serie$table_time,
#'                                             .metric = "rmse",
#'                                             .minimize = TRUE)
#' 
#' best_model_emae
#' 
modeltime_multibestmodel <- function(.table,
                                     .metric = NULL,
                                     .minimize = TRUE){
  
  #Select optimization
  if(.minimize == TRUE){
    .optimization <- "dplyr::slice_min"
  } else {
    .optimization <- "dplyr::slice_max"
  }
  
  #Select metric
  if(is.null(.metric)) .metric = "rmse"
  
  if(!.metric %in% c("mae", "mape", "mase", "smape", "rmse", "rsq")) cat("A metric is being supplied that is outside of those defined by defaluutl(mae, mape, mase, smape, rmse, rsq)")
  
  #Select best model on series
  calibration_table_best <- .table %>%
    dplyr::mutate(
      best_model = purrr::map(calibration, function(table_time = calibration){
        table_time %>%
          modeltime::modeltime_accuracy() %>%
          eval(parse(text = .optimization))(eval(parse(text = .metric)), n = 1) %>% head(1) %>% dplyr::pull(.model_id)   
      })) %>% 
    dplyr::mutate(
      calibrationx = purrr::map2(calibration, best_model, ~ function(x,y) x  %>% dplyr::filter(.model_id == y))
    )
  
  return(calibration_table_best)
}
