#' Modeltime best workflow from a set of models
#' 
#' @description Get best combination of model and recipe based on a a wffits object generated from the modeltime_wfs_fit function
#' 
#' @details The best model is selected based on a specific metric ('mae', 'mape','mase','smape','rmse','rsq'). The default is to minimize the metric. However, if the model is being selected based on rsq minimize should be FALSE. 
#'
#' @param .wfs_results a tibble generated from the modeltime_wfs_fit function
#' @param .model model to select best model from
#' @param .metric metric to get best model from ('mae', 'mape','mase','smape','rmse','rsq')
#' @param .minimize a boolean indicating whether to minimize (TRUE) or maximize (FALSE) the metric
#'
#' @return a tibble containing the best model based on the selected metric
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
#' mutate(date=as.Date(date)) %>% 
#'   filter(date<'2012-06-01')
#' 
#' recipe_date <- recipe(value ~ ., data = data) %>% 
#'   step_date(date, features = c('dow','doy','week','month','year')) 
#' 
#' recipe_date_lag <- recipe_date %>% 
#'   step_lag(value, lag = 7) %>% 
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
#' wfbest <- modeltime_wfs_bestmodel(.wfs_results = wffits,
#'                       .metric='rsq',
#'                       .minimize = FALSE)
#'wfbest
modeltime_wfs_bestmodel <- function(.wfs_results, .model = NULL, .metric = "rmse", .minimize = TRUE){
  # Rank models
  rank_models <- sknifedatar::modeltime_wfs_rank(.wfs_results, 
                                             rank_metric = .metric, 
                                             minimize = .minimize)
  #Select model
  if(is.null(.model)){
    best_model <- rank_models %>% head(1)
    .model <- best_model$.model_id
  }
  
  #All models
  if(.model == "all") .model <- nrow(rank_models)
  
  #Select number top models 
  if(is.numeric(.model)){
    if(.model > nrow(rank_models)) stop('The number of top models requested is higher than the number of models supplied') 
    best_model <- rank_models %>% head(.model)
    .model <- best_model$.model_id
  }
  
  #Select top models with top sting
  top_str_val <- tolower(.model) 
  top_str_val <- trimws(top_str_val)
  top_str_val <- gsub("\\s+"," ",top_str_val)
  top_str_val <- strsplit(top_str_val, " ") %>% unlist()
  
  if(length(.model) == 1 & top_str_val[1] == "top") {
    if(is.na(top_str_val[2])) stop('Enter a number that accompanies the word "top"')
    if(is.na(top_str_val[2] %>% as.numeric())) stop('the word that accompanies the word "top" is not a number')
    if(top_str_val[2] %>% as.numeric() > nrow(rank_models)) stop('The number of top models requested is higher than the number of models supplied') 
    best_model <- rank_models %>% head(top_str_val[2] %>% as.numeric())
    .model <- best_model$.model_id
  }
  
  #Validation of models names
  if(any(!.model %in% rank_models$.model_id )) stop('some of the model names passed in the ".model" argument do not match the model names in the supplied workflow set object')
  
  #Select models def
  
  rank_models %>% 
    dplyr::filter(.model_id %in% .model) %>% 
    dplyr::select(.model_id, rank, .model_desc, .fit_model)
  
}


