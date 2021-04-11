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
#' library(sknifedatar)
#' library(recipes)
#' library(modeltime)
#' library(workflowsets)
#' library(workflows)
#' library(parsnip)
#' library(timetk)
#' 
#' data <- sknifedatar::data_avellaneda %>% 
#'   mutate(date=as.Date(date)) %>% 
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
#' 
#' wfrefit <- modeltime_wfs_refit(.wfs_results = wffits,
#'                                .serie=data)
#' wfrefit
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
