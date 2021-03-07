#' @title Trasnformación de ventana deslizante movil
#'
#' @description Esta función permite aplicar una trasnformación de ventana deslizante movil mensual sobre un
#'   conjunto de datos.
#'
#' @details  El funcionamiento es el siguiente, es seleccionado el mes intermedio “t” de todo el periodo de estudio,
#'   posteriormente se calcula el número de eventos ocurridos para cada obervacion  en el mes anterior,
#'   en los últimos 3 meses, 6 meses, 12 meses y el mismo mes del año anterior.
#'
#'
#'   El procedimiento descrito anteriormente es replicado de manera móvil, es decir, rodando la ventana temporal
#'    desde t+1 hasta n, siendo n el último mes de estudio. Para ver un caso de uso real,
#'    visitar \href{https://rafael-zambrano-blog-ds.netlify.app/posts/2020-12-22-prediccin-de-delitos-en-caba/#aplicaci%C3%B3n-de-ventanas-deslizantes}{Crime analysis with tidymodels}
#'
#' @importFrom rlang .data
#' @importFrom rlang :=
#'
#' @seealso \href{https://rafzamb.github.io/sknifedatar/}{sknifedatar website}
#'
#'
#' @param data data frame que contiene conteos históricos de distintos eventos en espacios de tiempo mensuales.
#'   Cada fila es una observación única y las columnas corresponden a los distintos meses de estudio. Las
#'   variables deben tener palabras claves para poder seleccionarlas en conjunto. Para ver un ejemplo de la estructura de
#'   los datos, puede consultarse el dataset tal contenido en este paquete.
#' @param inicio mes inicial, formato numerico entero
#' @param pliegues vector que inicia en 1 y termina en el número de periodos que se desee recorrer.
#' @param variables una palabra o vector que permita seleccionar las variables en conjunto e implementar la función
#'   para cada grupo
#'
#' @return Un data frame con el ID de la observaciones y los distintos espacios de tiempo de conteo calculados por
#'   variables
#' @export
#'
#' @examples
#' pliegues = 1:13
#' names(pliegues) = pliegues
#'
#' variables = c("delitos", "temperatura", "mm_agua", "lluvia", "viento")
#' names(variables) = variables
#'
#' data("data_longer_crime")
#'
#' sliding_window(data = data_longer_crime %>% dplyr::select(-c(long,lat)),
#'                inicio = 13,
#'                pliegues = pliegues,
#'                variables = variables)
sliding_window = function(data, inicio, pliegues, variables){

  list_data = lapply(variables, function(x){data %>% dplyr::select(1,dplyr::contains(x))}) # Seleccion de variables (Id y variables de un tipo)

  list_sliding_window = lapply(list_data, function(y){

    splits = lapply(pliegues, function(x){

      nombre = names(y)[2]
      nombre = sub("_.*", "", nombre)
      #nombre = deparse(substitute(y))

      a = y %>%
        dplyr::transmute(
          .data$esquina,
          "{nombre}_last_year" := rowSums(.[(inicio + x -12)]),
          "{nombre}_last_12" := rowSums(.[(inicio + x -12):(inicio + x -1)]),
          "{nombre}_last_6" := rowSums(.[(inicio + x -6):(inicio + x -1)]),
          "{nombre}_last_3" := rowSums(.[(inicio + x -3):(inicio + x -1)]),
          "{nombre}_last_1" := rowSums(.[(inicio + x -1)]),
          "{nombre}" := rowSums(.[(inicio + x)]),
          pliegue = x
        )
    })
    splits
  })

  data_sliding_window = purrr::map(list_sliding_window,dplyr::bind_rows)

  drop_pliegue = ncol(data_sliding_window[[1]])

  id = data_sliding_window[[1]][[1]]

  id_pliegue = data_sliding_window[[1]][[drop_pliegue]]

  data_def = do.call(dplyr::bind_cols, lapply(data_sliding_window, `[`, -c(1,drop_pliegue))) %>%
    dplyr::mutate(
      id = id,
      pliegue = id_pliegue
    ) %>%
    dplyr::relocate(id,.data$pliegue)

  return(data_def)
}
