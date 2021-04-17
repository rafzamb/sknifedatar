#' @title Automatic Generation of Tabs
#'
#' @description It allows to automatically generate the code necessary to group multiple Rmarkdown chunks
#'              into tabs. Concatenating all the chunks into a string that can be later knitted and rendered.
#'
#' @details given a tibble, which must contain an "ID" column (representing the title of the tabs) and another
#'          column that stores the output to be generated (plot, text, code, ...), a string is automatically
#'          generated which can be later rendered in a Rmarkdown document.
#'
#' @seealso \href{https://rafzamb.github.io/sknifedatar/}{sknifedatar website}
#'
#' @param input_data  tibble with at least 2 columns, one for the title of the tabs and another with
#'                    the output to be displayed.
#' @param panel_name string with the name of the ID column.
#' @param .output string with the name of the column of the output.
#' @param .layout string that represents the layout of the tabs, can take the values "l-body",
#'                "l-body-outset", "l-page" and "l-screen". By default the value is NULL and takes
#'                "l-body" as parameter.
#' @param ... additional parameters that correspond to all those available in rmarkdown chunks
#'            (fig.align, fig.width, ...).
#'
#' @return concatenated string of all automatically generated chunks.
#'
#' @export
#'
#' @examples
#'
#' library(dplyr)
#' library(ggplot2)
#' library(purrr)
#' library(sknifedatar)
#'
#' dataset <-
#'  tibble::tibble(ID = c("A","B"),
#'                 numbers = list(rnorm(5), runif(5))) %>%
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
