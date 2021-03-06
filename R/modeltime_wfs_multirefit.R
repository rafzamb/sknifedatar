#' Refit one or more trained workflows to new data
#' 
#' @description It allows retraining a set of workflows trained on new data.
#'
#' @param models_table a tibble that comes from the output of the `modeltime_wfs_multifit()`, `modeltime_wfs_multiforecast()`,
#'                     `modeltime_wfs_multibestmodel()` functions. For the `modeltime_wfs_multifit` function, 
#'                     the 'table_time' object must be selected from the output.
#'
#' @return a tibble, corresponds to the same tibble supplied in the 'models_table' parameter but with the refit
#'         of the workflows saved in the 'nested_model' column.
#' 
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
#' sknifedatar::modeltime_wfs_multirefit(wfsets_fit$table_time)
#' 
modeltime_wfs_multirefit <- function(models_table){
  
  t_calibration <- models_table$calibration
  t_serie <- models_table$nested_column
  
  m_refit <- mapply(function(t_calibration, t_serie){
    
    t_calibration %>%
      modeltime::modeltime_refit(t_serie)
    
  },t_calibration, t_serie, SIMPLIFY = F)
  
  output_def <- models_table
  output_def$calibration <- m_refit
  
  output_def
}