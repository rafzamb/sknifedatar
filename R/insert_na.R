#' @title Función para agregar valores NA a un data frame
#'
#' @description Esta función permite agregar valores NA a un data frame, pudiendo seleccionar las columnas
#'    y la propòrcion de NAs deseados.
#'
#' @param data data frame
#' @param columnas vector que indica el nombre de las columnas donde se agregaran los valores NA, ejemplo de formato c("X1","X2").
#' @param p valor entre 0 y 1, indica la proporción de valores NA que se agregaran.
#' @param seed semilla de números aleatorios.
#'
#' @return El data frame original suministrado a data, pero con los valores NA agregados en las columnas indicadas.
#' @export
#'
#' @examples
#' insert_na(data = iris, columnas = c("Sepal.Length","Petal.Length"), p = 0.25)
insert_na = function(data , columnas, p = 0.01 , seed = 123){

  set.seed(seed)
  q = 1-p

  data_na = purrr::map_df(data %>%  dplyr::select(columnas), function(x) {
    x[sample(c(TRUE, NA),
             prob = c(q, p),
             size = length(x),
             replace = TRUE)]})

  dplyr::bind_cols(data %>% dplyr::select(-columnas),
                   data_na) %>%
    tibble::as_tibble()

}
