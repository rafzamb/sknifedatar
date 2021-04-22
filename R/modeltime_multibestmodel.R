#' @title Function to obtain the best model from a modeltime table
#'
#' @description This feature allows you to select the best model for each series, based on a specific evaluation metric.
#'
#' @details This function takes the object "** table_time **" from the output of the function "** modeltime_multifit **",
#'          and selects the best model based on the selected metric. 
#'
#' @param .table "**table_time**" tibble generated with the "**modeltime_multifit**" function.
#' @param .metric evaluation metric, from "**modeltime_accuracy**": 'mae', 'mape','mase','smape','rmse','rsq'.
#' @param .minimize boolean (default = TRUE), TRUE if the error metric should be minimized, FALSE in order to maximize it. 
#' @param .forecast boolean (default = TRUE), If it is TRUE, it indicates that the "**modeltime_multi forecast**" 
#' function has already been applied to the object that enters the "**.table**" parameter.
#'  This is evaluated by the existence of the column "nested_forecast". 
#'
#' @return table_time tibble filtered by the best model. 
#' @export
#' @importFrom utils head
#'
#' @examples
#' 
#' # Data
#' data_serie <- sknifedatar::table_time
#'                                       
#' # best_model_emae
#' sknifedatar::modeltime_multibestmodel(.table = data_serie$table_time,
#'                                       .metric = "rmse",
#'                                       .minimize = TRUE,
#'                                       .forecast = FALSE)
#' 
modeltime_multibestmodel <- function(.table,
                                     .metric = NULL,
                                     .minimize = TRUE,
                                     .forecast = TRUE){
  
  if(.forecast == TRUE & "nested_forecast" %in% colnames(.table) == FALSE) stop('The object entered in the parameter 
  ".table" was not applied the "modeltime_multiforecast" function, therefore it does not have the column "nested_forecast"
  and the best forecasting cannot be selected, change the parameter from ".forecast" to "FALSE"')
  
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
      
      best_model = purrr::map(.data$calibration, 
                              function(table_time = .data$calibration){
                                
                                table_time %>%
                                  
                                  modeltime::modeltime_accuracy() %>%
                                  
                                  eval(parse(text = .optimization))(eval(parse(text = .metric)), n = 1) %>% 
                                  
                                  head(1) %>% 
                                  
                                  dplyr::pull(.model_id)})
      ) %>% 
    
    dplyr::mutate(
      
      calibration = purrr::map2(.data$calibration, .data$best_model, function(x,y) x  %>% dplyr::filter(.model_id == y))
      
    )
  
  if(.forecast == TRUE) {
    
    calibration_table_best <- calibration_table_best %>% 
      
      dplyr::mutate(
        
        nested_forecast = purrr::map2(.data$nested_forecast, .data$best_model, function(x,y) x %>% dplyr::filter(.model_id %in% c(NA, y)))
     
     )
 }
  
  return(calibration_table_best)
  
}
