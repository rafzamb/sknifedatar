#' Modeltime workflowsets heatmap plot
#'
#' @description generate a heatmap for each recipe and model on a object generated with the `modeltime_wfs_fit()` function.
#' @details assumes that the workflows included in the 'workflow_set' object are named M_{name_of_model},
#'          since the .model_id is {recipe_name}_M_{name_of_model} and the '_M_' is used to separate the 
#'          recipe from the model name. 
#' @param .wfs_results a tibble generated with the `modeltime_wfs_fit()` function.
#' @param metric a metric the metric used for the heatmap values: 'mae', 'mape','mase','smape','rmse','rsq'.
#' @param low_color color for the worst metric (highest error or lowest rsq).
#' @param high_color color for the better metric (lowest error or highest rsq).
#'
#' @return a ggplot heatmap.
#' @export
#' 
#' @examples
#' library(modeltime)
#' library(dplyr)
#' library(parsnip)
#' 
#' data <- sknifedatar::data_avellaneda %>% mutate(date=as.Date(date)) %>% filter(date<'2011-01-01')
#' 
#' recipe_date <- recipes::recipe(value ~ ., data = data) %>% 
#'   recipes::step_date(date, features = c('dow','doy','week','month','year')) 
#' 
#' mars_backward <- mars(prune_method ='backward', mode = 'regression') %>% set_engine('earth')
#' 
#' mars_forward <- mars(prune_method = 'forward', mode = 'regression') %>% set_engine('earth')
#' 
#' wfsets <- workflowsets::workflow_set(
#'   preproc = list(
#'     date = recipe_date),
#'   models  = list(M_mars_backward = mars_backward, 
#'                  M_mars_forward = mars_forward),
#'   cross   = TRUE)
#' 
#' wffits <- sknifedatar::modeltime_wfs_fit(.wfsets = wfsets, 
#'                                          .split_prop = 0.6, 
#'                                          .serie=data)
#' 
#' sknifedatar::modeltime_wfs_heatmap(wffits, 'rsq')
#' 
modeltime_wfs_heatmap <- function(.wfs_results, metric='rsq', 
                                  low_color = '#c7e9b4',high_color = '#253494'){
  
  data <- .wfs_results %>% dplyr::select(-.fit_model) %>%
    tidyr::separate(.model_id,
                    c('recipe', 'model'),
                    sep = '_M_',
                    remove = FALSE)
    
  
  data <- data %>% 
    tidyr::expand(.data$recipe,  .data$model) %>% 
    dplyr::left_join(data, by = c('recipe', 'model')) %>%
    dplyr::mutate(na_text = ifelse(is.na(.model_id), 'Not fitted', ''))
  
  if (metric != 'rsq') {
    
    data <- data %>%
      dplyr::select(.data$recipe, .data$model, metric = !!metric, .data$na_text) %>%
      dplyr::mutate(metric_color = metric * (-1))
    
  } else{
    
    data <- data %>%
      dplyr::select(.data$recipe, .data$model, metric = !!metric, .data$na_text) %>%
      dplyr::mutate(metric_color = metric)
    
  }
  
  ggplot2::ggplot(data,
                  ggplot2::aes(x = .data$recipe,y = .data$model,
                               fill = .data$metric_color,
                               label = round(metric, 2)
                  )) +
    ggplot2::geom_tile() +
    ggplot2::geom_text(color = "white", size = 4) +
    ggplot2::geom_text(ggplot2::aes(label = .data$na_text),
                       color = "white",
                       size = 4) +
    ggplot2::labs(x = "Recipe", y = "Model",
                  title = paste0("Workflow sets: ",metric)) +
    ggplot2::scale_fill_gradient(low = low_color,
                                 high = high_color,
                                 na.value = 'grey') +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(
        hjust = 1,
        angle = 45,
        size = 10
      ),
      axis.text.y = ggplot2::element_text(hjust = 1, size =
                                            10),
      axis.title = ggplot2::element_text(size = 12),
      panel.grid = ggplot2::element_blank(),
      legend.position = 'none'
    )
}