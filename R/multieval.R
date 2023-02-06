#' @title Evaluation of multiple metrics and predictions
#'
#' @description for a set of predictions from different models, evaluate multiple metrics and return the results
#'              in a tabular format that makes it easy to compare the predictions.
#'
#' @seealso \href{https://rafael-zambrano-blog-ds.netlify.app/posts/2020-12-22-prediccin-de-delitos-en-caba/#modelos-de-series-de-tiempo}{Crime prediction /multieval}
#'
#' @param .dataset data frame with the predictions, it must have at least the column with the observed data and at
#'                 least one column that refers to the predictions of a model.
#' @param .observed string with the name of the column that contains the observed data.
#' @param .predictions string or vector of strings the columns where the predictions are stored.
#' @param .metrics metric or set of metrics to be evaluated, the metrics refer to those allowed by the package 
#'                 'yardstick' from 'tidymodels'.
#' @param value_table TRUE to display disaggregated metrics.
#'
#' @importFrom rlang .data
#'
#' @return data frame with 4 columns: the evaluation metrics, the estimator used, the value of the metric and the name of the model.
#' @export
#'
#' @example man/examples/multieval_example.R
multieval = function(.dataset , .observed, .predictions, .metrics, value_table = FALSE){
  
  fucntion_aux = function(.dataset , .observed, .predictions, .metrics){
    
    names(.predictions) = .predictions
    
    purrr::map2(.metrics, .predictions, function(x = .metrics, y = .predictions) {
      
      x(data = .dataset,
        truth = {{ .observed }},
        estimate = {{ y }},
        na_rm = TRUE) %>% 
        dplyr::mutate(modelo = y) 
    }) %>% 
      dplyr::bind_rows()
  }
  
  list_metrics = list()
  
  for (i in 1:length(.metrics)) {
    
    list_metrics[[i]] = fucntion_aux(.dataset  , .observed, .predictions, .metrics = .metrics[i])
  }
  
  table_values <- list_metrics %>% dplyr::bind_rows()
  
  summary_table <-
    table_values %>%
    dplyr::select(-".estimator") %>%
    tidyr::pivot_wider(names_from = .data$.metric, values_from = .data$.estimate)
  
  if(value_table == FALSE){
    
    table_values = NULL
  }
  
  list(table_values = table_values,
       summary_table = summary_table) %>%
    purrr::compact()
}
