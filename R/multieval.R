#' @title Evaluación de múltiples métricas y predicciones
#'
#' @description Para un conjunto de predicciones de distintos modelos, permite evaluar múltiples métricas y devolver los resultados en un formato tabular que facilita la comparación de las predicciones.
#'
#' @seealso \href{https://rafael-zambrano-blog-ds.netlify.app/posts}{Aplicación de la función en un proyecto de ciencia de datos}
#'
#' @param data data frame con las predicciones, debe tener como mínimo la columna con los datos observados y al menos una columna que haga referencia a las predicciones de un modelo.
#' @param observed string con el nombre de la columna que contiene los datos observados.
#' @param predictions string o vector de strings las columnas donde se almacenan las predicicones.
#' @param metrica métrica o conjunto de métricas que se desean evaluar, las métricas hacen referencias a las permitidas por
#'   el paquete \href{https://yardstick.tidymodels.org/}{yardstick} de tidymodels.
#'
#' @return data frame con 4 columnas, siendo las mismas las métricas de evaluación, el estimador usado, el valor de la métrica y el nombre del modelo.
#' @export
#'
#' @example man/examples/multieval_example.R
multieval = function(data , observed, predictions, metrica){

  names(predictions) = predictions

  mlapply(function(x, y ){

    x(data = data,
      truth    = .data[[observed]],
      estimate = .data[[y]],
      na_rm    = TRUE) %>%
      dplyr::mutate(model = y)
  },
  metrica,predictions
  ) %>%
    dplyr::bind_rows() %>%
    dplyr::arrange(.data$.metric)
}
