#' @title Evaluación de múltiples métricas y predicciones
#'
#' @description Para un conjunto de predicciones de distintos modelos, permite evaluar múltiples métricas y devolver los resultados en un formato tabular que facilita la comparación de las predicciones.
#'
#' @seealso \href{https://rafael-zambrano-blog-ds.netlify.app/posts/2020-12-22-prediccin-de-delitos-en-caba/#modelos-de-series-de-tiempo}{Predicción de delitos/multieval}
#'
#' @param .dataset data frame con las predicciones, debe tener como mínimo la columna con los datos observados y al menos una columna que haga referencia a las predicciones de un modelo.
#' @param .observed string con el nombre de la columna que contiene los datos observados.
#' @param .predictions string o vector de strings las columnas donde se almacenan las predicicones.
#' @param .metrics métrica o conjunto de métricas que se desean evaluar, las métricas hacen referencias a las permitidas por
#'   el paquete \href{https://yardstick.tidymodels.org/}{yardstick} de tidymodels.
#' @param value_table TRUE para mostrar las métricas desagregadas.
#'
#' @importFrom rlang .data
#'
#' @return data frame con 4 columnas, siendo las mismas las métricas de evaluación, el estimador usado, el valor de la métrica y el nombre del modelo.
#' @export
#'
#' @example man/examples/multieval_example.R
multieval = function(.dataset , .observed, .predictions, .metrics, value_table = FALSE){
  
  fucntion_aux = function(.dataset , .observed, .predictions, .metrics){
    
    names(.predictions) = .predictions
    
    purrr::map2(.metrics, .predictions, function(x = .metrics, y = .predictions) {
      
      x(data = .dataset,
        truth = .dataset[[.observed]],
        estimate = .dataset[[y]],
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
