#' @title Generacion automatica de tabs
#'
#' @description Permite generar automáticamente el código necesario para agrupar múltiples chunks de Rmarkdown en tabs.
#'              Concatenando todos los chunks en un string que puede ser posteriormente tejido y renderizado.
#'
#' @details dado un tiblle, que debe contener una columna de “ID” (representará al título de las tabs) y otra columna
#'          que almacena la salida que se desee generar (gráfico, texto, código, ...), se genera automáticamente un
#'          string que posteriormente puede ser renderizado en un documento Rmarkdown.
#'
#' @seealso \href{https://rafzamb.github.io/sknifedatar/}{sknifedatar website}
#'
#' @param input_data  tibble con al menos 2 columnas, una para el título de las tabs y otra con la salida a mostrar.
#' @param panel_name string con el nombre de la columna de ID.
#' @param .output string con el nombre de la columna del output.
#' @param .layout string que representa el layout de las tabs, puede tomar los valores "l-body" ,"l-body-outset",
#'                "l-page" y "l-screen". Por defecto el valor es NULL y toma como parámetro "l-body".
#' @param ... parámetros adicionales que corresponden a todos los disponibles en los chunks de
#'            rmarkdown (fig.align, fig.width, …)
#'
#' @return string que contiene concatenados todos los chunks generados automáticamente.
#'
#' @export
#'
#' @examples
#'
#' library(dplyr)
#' library(ggplot2)
#' library(purrr)
#'
#' dataset <-
#'  tibble::tibble(ID = c("A","B","C","D"),
#'                 numbers = list(rnorm(10), runif(10), rpois(10,2), rexp(10))) %>%
#'  mutate(plots = map(numbers,
#'                     ~ data.frame(plots = .x) %>% ggplot(aes(x=plots)) + geom_histogram()))
#'
#' dataset
#'
#' automagic_tabs(input_data = dataset, panel_name = "ID", .output = "plots")
#'
#' unlink("figure", recursive = TRUE)
#'
automagic_tabs <- function(input_data , panel_name, .output, .layout = NULL, ...){

  #Capture extra arguments
  list_arguments <- list(...)
  .arguments <- names(list_arguments)
  .inputs <- list_arguments %>% unlist() %>% unname()
  parse_extra_argumnets <- NULL
  if(!is.null(.arguments)) parse_extra_argumnets <- purrr::map2(.arguments,.inputs, ~paste(.x,.y, sep = " = ")
  ) %>% unlist() %>% paste(collapse=" , ")

  #Capture name of data
  data_name <- match.call()
  data_name <- as.list(data_name[-1])$input_data %>% as.character()

  #Layaout page
  if(is.null(.layout)) .layout <- "l-body"
  if(!.layout %in% c("l-body","l-body-outset","l-page","l-screen")) stop('the specified layout does not match those available. c("l-body","l-body-outset","l-page","l-screen")')
  layaout_code <- paste0("::: {.",.layout,"}\n::: {.panelset}\n")

  #knit code
  knit_code <- NULL
  for (i in 1:nrow(input_data)) {

    #Capture time to diference same chunks
    time_acual <- Sys.time() %>% as.character()

    knit_code_individual <- paste0(":::{.panel}\n### `r ", data_name,"$",panel_name,"[[",i,
                                   "]]` {.panel-name}\n```{r   `r ", time_acual," ", data_name,"$",panel_name,"[[",i,
                                   "]]`, echo=FALSE, layout='",.layout,"', ",
                                   parse_extra_argumnets,
                                   "}\n\n ",data_name,"$",.output,"[[",i,
                                   "]] \n\n```\n:::")

    knit_code <- c(knit_code, knit_code_individual)

  }

  #layout code + knit code + close ::: :::
  knit_code <- c(layaout_code,knit_code,"\n:::\n:::")

  #knirt code
  paste(knitr::knit(text = knit_code), collapse = '\n')

}
