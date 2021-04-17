#' @title Function to obtain the best model from a modeltime table
#'
#' @description This feature allows you to select the best model for each series, based on a specific evaluation metric.
#'
#' @details This function takes the object "** table_time **" from the output of the function "** modeltime_multifit **",
#'          and selects the best model based on the selected metric. 
#'
#' @param .table "**table_time**" tibble generated with the "**modeltime_multifit**" function.
#' @param .metric evaluation metric, from "**modeltime_accuracy**": 'mae', 'mape','mase','smape','rmse','rsq'.
#' @param .minimize boolean (default = TREUE), TRUE if the error metric should be minimized, FALSE in order to maximize it. 
#'
#' @return table_time tibble filtered by the best model. 
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
      calibration = purrr::map2(calibration, best_model, function(x,y) x  %>% dplyr::filter(.model_id == y))
    )
  
  return(calibration_table_best)
}
