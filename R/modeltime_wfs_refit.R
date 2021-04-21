#' Modeltime workflow sets refit
#' 
#' @description This function applies the modeltime_refit() function from modeltime to the wffits object generated from the modeltime_wfs_fit function (or the filtered version after the modeltime_wfs_bestmodel is applied)
#' 
#' @details Each model is now re-trained using all the available data. 
#' 
#' @param .wfs_results tibble of combination of recipes and models fitted, generated with the modeltime_wfs_fit function
#' @param .serie a time series dataframe
#'
#' @return a tibble containing the re-trained models
#' @export
#'
#' @examples
#' 
#' library(modeltime)
#' library(dplyr)
#' 
#' data <- sknifedatar::data_avellaneda %>% 
#'   mutate(date=as.Date(date)) %>% 
#'   filter(date<'2012-06-01')
#' 
#' recipe_date <- recipes::recipe(value ~ ., data = data) %>% 
#'   recipes::step_date(date, features = c('dow','doy','week','month','year')) 
#' 
#' recipe_date_lag <- recipe_date %>% 
#'   recipes::step_lag(value, lag = 7) %>% 
#'   timetk::step_ts_impute(all_numeric(), period=365)
#' 
#' mars <- parsnip::mars(mode = 'regression') %>%
#'   parsnip::set_engine('earth')
#' 
#' wfsets <- workflowsets::workflow_set(
#'   preproc = list(
#'     R_date = recipe_date,
#'     R_date_lag = recipe_date_lag),
#'   models  = list(M_mars = mars),
#'   cross   = TRUE)
#' 
#' wffits <- sknifedatar::modeltime_wfs_fit(.wfsets = wfsets, 
#'                                          .split_prop = 0.8, 
#'                                          .serie = data)
#' 
#' sknifedatar::modeltime_wfs_refit(.wfs_results = wffits,
#'                                  .serie = data)
#'                                
modeltime_wfs_refit  <- function(.wfs_results, .serie){
  
  list_models <- .wfs_results %>% split(.$.model_id)
  
  # Refit on whole dataset
  table_refit <- purrr::map(list_models, function(.model = list_models, .df=.serie){
    
    .models_table <- .model %>% 
      purrr::pluck('.fit_model',1) %>% 
      modeltime::modeltime_refit(data = .serie)
    
  })
  
  # Convert lists to table
  table_wfs <- dplyr::bind_rows(table_refit, .id = ".model_id") 
  
  return(table_wfs)
  
}
