#' Get the best workflow for each time series
#' 
#' @description obtains the best workflow for each time series based on a performance metric.
#'
#' @param .table a tibble that comes from the output of the `modeltime_wfs_multifit()` or `modeltime_wfs_multiforecast()` 
#'               functions. For the `modeltime_wfs_multifit()` function, the 'table_time' object must be selected 
#'               from the output.
#' @param .metric a string of evaluation metric, the following symmetrical can be supplied: 'mae', 'mape','mase',
#'                'smape','rmse','rsq'.
#' @param .minimize boolean (default = TRUE), TRUE if the error metric should be minimized, FALSE in order to maximize it.
#'
#' @return a tibble, corresponds to the same tibble supplied in the '.table' parameter but with the 
#'         selection of the best workflow for each series.
#' @export
#'
#' @examples
#' library(dplyr)
#' library(earth)
#' 
#' df <- sknifedatar::emae_series
#' 
#' datex <- '2020-02-01'
#' df_emae <- df %>%
#'   dplyr::filter(date <= datex) %>% 
#'   tidyr::nest(nested_column=-sector) %>% 
#'   head(2)
#' 
#' receta_base <- recipes::recipe(value ~ ., data = df %>% select(-sector))
#' 
#' mars <- parsnip::mars(mode = 'regression') %>% parsnip::set_engine('earth')
#' 
#' wfsets <- workflowsets::workflow_set(
#'   preproc = list(
#'     R_date = receta_base),
#'   models  = list(M_mars = mars),
#'   cross   = TRUE)
#' 
#' wfsets_fit <- modeltime_wfs_multifit(.wfs = wfsets,
#'                                      .prop = 0.8, 
#'                                      serie = df_emae)
#' 
#' sknifedatar::modeltime_wfs_multibestmodel(.table = wfsets_fit$table_time,
#'                                           .metric = "rmse",
#'                                           .minimize = TRUE)
#' 
modeltime_wfs_multibestmodel <- function(.table, .metric = NULL, .minimize = TRUE){
  
  #Select optimization
  if(.minimize == TRUE){
    .optimization <- "dplyr::slice_min"
  } else {
    .optimization <- "dplyr::slice_max"
  }
  
  #Select metric
  if(is.null(.metric)) .metric = "rmse"
  if(!.metric %in% c("mae", "mape", "mase", "smape", "rmse", "rsq")) cat("A metric is being supplied that is outside of those defined by defalutl(mae, mape, mase, smape, rmse, rsq)")
 
   #Select best model on series
  calibration_table_best <- .table %>%
    
    dplyr::mutate(
      best_model = purrr::map(calibration, 
                              function(table_time = calibration){
                                
        table_time %>%
          modeltime::modeltime_accuracy() %>%
          eval(parse(text = .optimization))(eval(parse(text = .metric)), n = 1) %>% head(1) %>% dplyr::pull(.model_id)  
                                
      })) %>% 
    
    dplyr::mutate(
      
      calibration = purrr::map2(calibration, best_model, 
                                function(x,y) x  %>% dplyr::filter(.model_id == y))
    )
  
  if('nested_forecast' %in% names(calibration_table_best) == TRUE){
    
    calibration_table_best <- calibration_table_best %>% 
      
      dplyr::mutate(nested_forecast = purrr::map2(nested_forecast, best_model,
                                                  ~ .x %>% dplyr::filter(.model_id %in% c(NA, .y))))
    
  }
  
  return(calibration_table_best)
  
}