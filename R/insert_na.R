#' @title Function para agregar valores NA a un data frame
#'
#' @description Esta función permite agregar valores NA a un data frame, pudiendo seleccionar las columnas
#'    y la propòrcion de NAs deseados.
#'
#' @param .dataset data frame
#' @param columns vector que indica el nombre de las columnas donde se agregaran los valores NA, ejemplo de formato c("X1","X2").
#' @param .p valor entre 0 y 1, indica la proporción de valores NA que se agregaran.
#' @param seed semilla de números aleatorios.
#'
#' @return El data frame original suministrado a data, pero con los valores NA agregados en las columnas indicadas.
#' @export
#'
#' @examples
#' insert_na(.dataset = iris, columns = c("Sepal.Length","Petal.Length"), .p = 0.25)
insert_na <- function(.dataset , columns, .p = 0.01 , seed = 123){

  set.seed(seed)
  q <- 1-.p

  data_na <- purrr::map_df(.dataset %>%  dplyr::select(columns), function(x) {
    x[sample(c(TRUE, NA),
             prob = c(q, .p),
             size = length(x),
             replace = TRUE)]})

  dplyr::bind_cols(.dataset %>% dplyr::select(-columns),
                   data_na) %>%
    tibble::as_tibble()

}
