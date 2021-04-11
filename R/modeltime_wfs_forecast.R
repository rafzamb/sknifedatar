#' Modeltime workflow sets forecast
#' 
#' @description Forecast from a set of recipes and models trained by modeltime_wfs_fit
#' 
#' @details Since it uses the modeltime_forecast() function from modeltime, either the forecast can be made on new data or on a number of periods. 
#' 
#' @param .wfs_results tibble of combination of recipes and models fitted, generated with the modeltime_wfs_fit function
#' @param .series time series dataframe
#' @param .split_prop time series split proportion
#' @param .h time series horizon from the modeltime_forecast() function
#'
#' @return a tibble containing the forecast for each model
#' @export
#'
#' @examples
#' library(sknifedatar)
#' library(recipes)
#' library(modeltime)
#' library(workflowsets)
#' library(workflows)
#' library(parsnip)
#' library(timetk)
#' data <- sknifedatar::data_avellaneda %>% 
#' mutate(date=as.Date(date)) %>% 
#'   filter(date<'2012-01-01')
#' 
#' recipe_date <- recipe(value ~ ., data = data) %>% 
#'   step_date(date, features = c('week','month', 'quarter', 'semester', 'year')) 
#' 
#' recipe_date_lag <- recipe_date %>% 
#'   step_lag(value, lag = 1) %>% 
#'   step_ts_impute(all_numeric(), period=365)
#' 
#' mars <- mars(mode = 'regression') %>%
#'   set_engine('earth')
#' 
#' wfsets <- workflow_set(
#'   preproc = list(
#'     R_date = recipe_date,
#'     R_date_lag = recipe_date_lag),
#'   models  = list(M_mars = mars),
#'   cross   = TRUE)
#' 
#' wffits <- modeltime_wfs_fit(.wfsets = wfsets, 
#'                             .split_prop = 0.8, 
#'                             .serie=data)
#' wfforecast <- modeltime_wfs_forecast(.wfs_results=wffits, 
#'                                      .series = data,
#'                                      .split_prop = 0.8) 
#' wfforecast
modeltime_wfs_forecast <- function(.wfs_results, .series, .split_prop = NULL, .h = NULL){
  
  .new_data_cal <- rsample::initial_time_split(.series, prop = .split_prop) %>% 
    rsample::testing()

  .new_data <- if (is.null(.h)) {
    
    rsample::initial_time_split(.series, prop = .split_prop) %>% 
      rsample::testing()
    
  } else { NULL}
  
  if('mdl_time_tbl' %in% class(.wfs_results) == TRUE){
    
    .forecast <- .wfs_results %>% 
      modeltime::modeltime_calibrate(new_data = .new_data_cal) %>% 
      dplyr::mutate(.model_desc = "") 
    
  } else {
    
    list_models <- .wfs_results %>% split(.$.model_id)
    
    table_forecast <- purrr::map(list_models, function( .wf = list_models){
      
      .model_table <- .wf$.fit_model[[1]] %>%  
        modeltime::modeltime_calibrate(new_data = .new_data_cal) %>% 
        dplyr::mutate(.model_desc = "") 
    })
    
    # Convert list to table
    .forecast <- dplyr::bind_rows(table_forecast, .id = ".model_id")
  }
  
  .forecast %>% 
    modeltime::modeltime_forecast(h = .h, 
                                  actual_data = .series, 
                                  .new_data = .new_data)
}