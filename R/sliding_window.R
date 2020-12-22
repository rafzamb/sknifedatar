#' Implemnetacion de sliding window
#'
#' @param data dataframe
#' @param inicio vector
#' @param pliegues vector
#' @param variables vector
#'
#' @return A list
#' @export
#'
#' @examples
sliding_window = function(data, inicio, pliegues, variables){

  list_data = lapply(variables, function(x){data %>% dplyr::select(1,dplyr::contains(x))}) # Seleccion de variables (Id y variables de un tipo)

  list_sliding_window = lapply(list_data, function(y){

    splits = lapply(pliegues, function(x){

      nombre = names(y)[2]
      nombre = sub("_.*", "", nombre)
      #nombre = deparse(substitute(y))

      a = y %>%
        dplyr::transmute(
          esquina,
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
    dplyr::relocate(id,pliegue)
}
