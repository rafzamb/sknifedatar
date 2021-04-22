#' @title Mobile sliding window transformation
#'
#' @description This function allows to apply a monthly moving sliding window transformation on a data set.
#' 
#' @details  The operation is as follows, the intermediate month "t" of the entire study period is selected, then the number of events that occurred for each observation in the previous month is calculated, in the last 3 months, 6 months, 12 months and the same month of the previous year.
#'
#'   The procedure described above is replicated in a mobile manner, that is, rolling the time window from t + 1 to n, where n is the last month of study. To see a real use case, visit \href{https://rafael-zambrano-blog-ds.netlify.app/posts/2020-12-22-prediccin-de-delitos-en-caba/#aplicaci%C3%B3n-de-ventanas-deslizantes}{Crime analysis with tidymodels}
#'
#' @importFrom rlang .data
#' @importFrom rlang :=
#'
#' @seealso \href{https://rafzamb.github.io/sknifedatar/}{sknifedatar website}
#'
#'
#' @param data dataframe that contains historical counts of different events in monthly time frames.
#' Each row is a unique observation and the columns corresponding to the different months of study. The
#' variables must have keywords to be able to select them together. To see an example of the structure of
#' the data, the dataset such contained in this package can be used

#' @param inicio initial month, integer numeric format
#' @param pliegues vector that starts at 1 and ends in the number of periods to be traversed.
#' @param variables a word or vector that allows you to select the variables together and implement the function
#' for each group
#'
#' @return A data frame with the ID of the observations and the different counting time slots calculated by
#' variables

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
sliding_window <- function(data, inicio, pliegues, variables){

  list_data <- lapply(variables, function(x){data %>% dplyr::select(1,dplyr::contains(x))}) # Seleccion de variables (Id y variables de un tipo)

  list_sliding_window <- lapply(list_data, function(y){

    splits <- lapply(pliegues, function(x){

      nombre <- names(y)[2]
      nombre <- sub("_.*", "", nombre)
      #nombre = deparse(substitute(y))

      a <- y %>%
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

  data_sliding_window <- purrr::map(list_sliding_window, dplyr::bind_rows)

  drop_pliegue <- ncol(data_sliding_window[[1]])

  id <- data_sliding_window[[1]][[1]]

  id_pliegue <- data_sliding_window[[1]][[drop_pliegue]]

  data_def <- do.call(dplyr::bind_cols, lapply(data_sliding_window, `[`, -c(1,drop_pliegue))) %>%
    dplyr::mutate(
      id = id,
      pliegue = id_pliegue
    ) %>%
    dplyr::relocate(id, .data$pliegue)

  return(data_def)
}
