#' @title Automatic Generation of Tabs with multiple outputs
#'
#' @description It allows to automatically generate the code necessary to group multiple Rmarkdown chunks
#'              into tabs. Concatenating all the chunks into a string that can be later knitted and rendered.
#'
#' @details Given a tiblle, which must contain an "ID" column (representing the title of the tabs) and other
#'          columns that stores output to be generated (plot, text, code, ...), a string is automatically
#'          generated which can be later rendered in a Rmarkdown document.
#'
#' @seealso \href{https://rafzamb.github.io/sknifedatar/}{sknifedatar website}
#'
#' @param input_data Ungrouped tibble with at least 2 columns, one for the title of the tabs and another with
#'                    the output to be displayed.
#' @param panel_name column with the ID variable.
#' @param ... nested columns that contain outputs to display.
#' @param tabset_title string title of the .tabset 
#' @param tabset_props string defining .tabset properties. Only works with is_output_distill = F
#' @param chunk_props named list with additional parameters that correspond to all those available in rmarkdown chunks
#'            (fig.align, fig.width, ...).
#' @param is_output_distill boolean. is output a distill article?
#'
#' @return concatenated string of all automatically generated chunks.
#'
#' @export
#'
#' @examples
#'
#' library(dplyr)
#' library(sknifedatar)
#' library(ggplot2)
#'
#' dataset <- iris %>% 
#'   group_by(Species) %>% 
#'   tidyr::nest() %>% 
#'   mutate(
#'     .plot = purrr::map(data, ~ ggplot(.x, aes(x = Sepal.Length, y = Petal.Length)) + geom_point()),
#'     .table = purrr::map(data, ~ summary(.x) %>% knitr::kable())
#'   ) %>% 
#'   ungroup()
#'
#' automagic_tabs2(input_data = dataset, panel_name = Species, .plot, .table)
#' 
#' unlink("figure", recursive = TRUE)
#'
automagic_tabs2 <- function(input_data, panel_name, ..., tabset_title = '', tabset_props = '.tabset-fade .tabset-pills', 
                            chunk_props = list(echo = FALSE, fig.align = "center"), is_output_distill = TRUE){
  
  # Quosures
  dataset_name <- rlang::enquo(input_data) %>% rlang::as_name()
  panel_col <- rlang::enquo(panel_name)
  vars <- rlang::enquos(..., .named = TRUE) %>% names()
  
  if(dplyr::is_grouped_df(input_data)){stop('input_data must be ungrouped')}
  
  # Parse Columns to extract
  subsets <- paste0(dataset_name, '$', vars)
  
  # Parse Chunk options
  if(purrr::is_empty(chunk_props)){
    warning('chunk_props can not be empty, adding echo = FALSE to every chunk in this tabset')
    chunk_props <- list(echo = F)
  }
  
  chunk_props_values <- unname(chunk_props) %>% purrr::map_if(is.character, ~sprintf("'%s'", .x))
  .chunk_props <- paste0(paste(names(chunk_props), chunk_props_values, sep = ' = '), collapse = ', ')  
  
  # Distill Output
  if(is_output_distill){
    aux_1 <- ''
    aux_2 <- '.panelset'
    aux_3 <- '.panel'
  } else{
    aux_1 <- '.tabset'
    aux_2 <- ''
    aux_3 <- ''
    
  }
  
  # Loop variables
  chunks <- list()
  for(rown in 1:nrow(input_data)){
    
    .panel_output <- sprintf('%s[[%s]]', subsets, rown) %>% paste0(collapse = ' \n ')
    .panel_name <- input_data %>% dplyr::slice(rown) %>% dplyr::pull(!!panel_col)
    
    # Create Individual Chunks
    individual_chunk <- sprintf('::: {%s}\n
### %s \n
```{r `r automagic_chunk_%s_%s`, %s} \n %s \n ``` \n
:::', aux_3, .panel_name, dataset_name, .panel_name, .chunk_props, .panel_output)
    
    chunks <- c(chunks, individual_chunk)
    
  }
  
  # Create tabset panel
  final_chunk <- sprintf('## %s {%s %s} \n
::::: {%s}\n
%s \n
:::::', tabset_title, aux_1, tabset_props, aux_2, paste0(chunks, collapse = '\n'))
  
  knitr::knit(text = final_chunk)
  
}
