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
#' @param input_data tibble with at least 2 columns, one for the title of the tabs and another with
#'                    the output to be displayed.
#' @param panel_name column with the ID variable.
#' @param ... nested columns that contain outputs to display.
#' @param tabset_title string title of the .tabset 
#' @param tabset_props string defining .tabset properties
#' @param chunk_props named list with additional parameters that correspond to all those available in rmarkdown chunks
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
#' automagic_tabs(input_data = dataset, panel_name = ID, numbers, plots)
#'
#' unlink("figure", recursive = TRUE)
#'
automagic_tabs <- function(input_data, panel_name, ..., tabset_title = '', tabset_props = '.tabset-fade .tabset-pills', 
                            chunk_props = list(echo = F, fig.align = "'center'")){
  
  # Quosures
  dataset_name <- rlang::enquo(input_data) %>% rlang::as_name()
  panel_col <- rlang::enquo(panel_name)
  vars <- rlang::enquos(..., .named = TRUE) %>% names()
  
  # Parse Columns to extract
  subsets <- paste0(dataset_name, '$', vars)
  
  # Parse Chunk options
  .chunk_props <- paste0(paste(names(chunk_props), unname(chunk_props), sep = ' = '), collapse = ', ')  
  
  # Loop variables
  chunks <- list()
  for(rown in 1:nrow(input_data)){
    
    .panel_output <- sprintf('%s[[%s]]', subsets, rown) %>% paste0(collapse = ' \n ')
    .panel_name <- input_data %>% dplyr::slice(rown) %>% dplyr::pull(!!panel_col)
    
    # Create Individual Chunks
    individual_chunk <- sprintf('::: {}\n
### %s \n
```{r `r automagic_chunk_%s_%s`, %s} \n %s \n ``` \n
:::', .panel_name, dataset_name, .panel_name, .chunk_props, .panel_output)
    
    chunks <- c(chunks, individual_chunk)
    
  }
  
  # Create tabset panel
  final_chunk <- sprintf('::::: {}\n
## %s {.tabset %s} \n
%s \n
:::::', tabset_title, tabset_props, paste0(chunks, collapse = '\n'))
  
  knitr::knit(text = final_chunk)
  
}
