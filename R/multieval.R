#' @title Evaluación de múltiples métricas y predicciones
#'
#' @description Para un conjunto de predicciones de distintos modelos, permite evaluar múltiples métricas y devolver los resultados en un formato tabular que facilita la comparación de las predicciones.
#'
#' @seealso \href{https://rafael-zambrano-blog-ds.netlify.app/posts/2020-12-22-prediccin-de-delitos-en-caba/#modelos-de-series-de-tiempo}{Predicción de delitos/multieval}
#'
#' @param data data frame con las predicciones, debe tener como mínimo la columna con los datos observados y al menos una columna que haga referencia a las predicciones de un modelo.
#' @param observed string con el nombre de la columna que contiene los datos observados.
#' @param predictions string o vector de strings las columnas donde se almacenan las predicicones.
#' @param metrica métrica o conjunto de métricas que se desean evaluar, las métricas hacen referencias a las permitidas por
#'   el paquete \href{https://yardstick.tidymodels.org/}{yardstick} de tidymodels.
#' @param plot_view TRUE para hacer un gráfico de las métricas resultantes.
#' @param value_table TRUE para mostrar las métricas desagregadas.
#'
#' @importFrom rlang .data
#'
#' @return data frame con 4 columnas, siendo las mismas las métricas de evaluación, el estimador usado, el valor de la métrica y el nombre del modelo.
#' @export
#'
#' @example man/examples/multieval_example.R
multieval = function(data , observed, predictions, metrica ,plot_view = TRUE, value_table = TRUE){

  names(predictions) = predictions

  table_values = mlapply(function(x, y ){

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

  summary_table =
    table_values %>%
    dplyr::select(-".estimator") %>%
    tidyr::pivot_wider(names_from = .data$.metric, values_from = .data$.estimate)

  if(plot_view == "TRUE"){

    plot_metrics = table_values %>%
      ggplot2::ggplot(ggplot2::aes(x= .data$model, y= .data$.estimate)) +
      ggplot2::geom_segment(ggplot2::aes(x=.data$model, xend=.data$model, y=0, yend=.data$.estimate, color = .data$model)) +
      ggplot2::geom_point(size=3, color="red", alpha=0.5, shape=21, stroke=1) +
      ggplot2::coord_flip()+
      ggplot2::xlab("") +
      ggplot2::facet_wrap(~ .metric, nrow = 1, scales = "free") +
      ggplot2::theme_minimal() +
      ggplot2::theme(axis.text.y = ggplot2::element_blank(),
                     axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust=1),
                     strip.text = ggplot2::element_text(face = "bold", size = 10)) +
      ggplot2::scale_y_continuous(label= scales::comma)

  }else{

    plot_metrics = NULL
  }

  if(value_table == FALSE){

    table_values = NULL
  }

  list(table_values = table_values,
       summary_table = summary_table,
       plot_metrics =  plot_metrics) %>%
    purrr::compact()
}
