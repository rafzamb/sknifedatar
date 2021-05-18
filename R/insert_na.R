#' @title Add NA values to a dataframe
#'
#' @description allows adding NA values to a data frame, selecting the columns
#'              and the proportion of desired NAs.
#'
#' @param .dataset data frame.
#' @param columns vector that indicates the name of the columns where the NA values will be added, 
#'                in the format: c("X1", "X2") for variables X1, X2.
#' @param .p value between 0 and 1, indicating the proportion of NA values that will be added.
#' @param seed random number seed.
#'
#' @return the original data frame, but with the NA values added in the indicated columns.
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
