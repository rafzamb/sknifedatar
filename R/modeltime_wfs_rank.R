#' Modeltime workflow sets ranking based on a metric
#' 
#' @description generates a ranking of models generated with `modeltime_wfs_fit()` function. 
#' 
#' @details the ranking depends on the metric selected.
#'
#' @seealso \href{https://rafzamb.github.io/sknifedatar/}{sknifedatar website}
#'
#' @param .wfs_results a tibble generated with the `modeltime_wfs_fit()` function.
#' @param rank_metric the metric used to generate the ranking 'mae', 'mape','mase','smape','rmse','rsq'.
#' @param minimize a boolean indicating whether to minimize (TRUE) or maximize (FALSE) the metric
#'
#' @return a tibble containing the models ranked by a specific metric.
#' @export
#'
#' @examples
#' library(dplyr)
#' library(modeltime)
#' 
#' data <- sknifedatar::data_avellaneda %>% 
#'   mutate(date=as.Date(date)) %>% 
#'   filter(date<'2012-06-01')
#' 
#' recipe_date <- recipes::recipe(value ~ ., data = data) %>% 
#'   recipes::step_date(date, features = c('dow','doy','week','month','year')) 
#' 
#' mars <- parsnip::mars(mode = 'regression') %>% parsnip::set_engine('earth')
#' 
#' wfsets <- workflowsets::workflow_set(
#'   preproc = list(
#'     R_date = recipe_date),
#'   models  = list(M_mars = mars),
#'   cross   = TRUE)
#' 
#' wffits <- sknifedatar::modeltime_wfs_fit(.wfsets = wfsets, 
#'                                          .split_prop = 0.8, 
#'                                          .serie = data)
#' 
#' sknifedatar::modeltime_wfs_rank(.wfs_results = wffits,
#'                                 rank_metric = 'rsq',
#'                                 minimize = FALSE)
#'                                 
modeltime_wfs_rank <- function(.wfs_results , rank_metric = NULL, minimize = TRUE){
  
  #Select metric
  if(is.null(rank_metric)) rank_metric = "rmse"
  
  if(!rank_metric %in% c("mae", "mape", "mase", "smape", "rmse", "rsq")) cat("A metric is being supplied that is outside of those defined by defaluutl(mae, mape, mase, smape, rmse, rsq)")
  
  #Rank models
  if(minimize == TRUE) {
    table_rank <- .wfs_results %>% 
      dplyr::arrange(eval(parse(text = rank_metric))) %>% 
      dplyr::mutate(rank = 1:nrow(.))
  } else {
    table_rank <- .wfs_results %>% 
      dplyr::arrange(-eval(parse(text = rank_metric))) %>% 
      dplyr::mutate(rank = 1:nrow(.))
  }
  
  table_rank %>% 
    dplyr::relocate(.model_id, rank)
  
}

