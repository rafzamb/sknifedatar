#' @title mapply for all combinations of arguments or lapply for multiple vectors/lists of arguments
#'
#' @description mapply for all combinations of arguments or lapply for multiple vectors/lists of arguments.
#'   This function was extracted from \href{https://github.com/alekrutkowski}{Alek Rutkowski's} Gist GitHub public repository,
#'   it can be found published through the
#'   following \href{https://gist.github.com/alekrutkowski/e46fae4dc079bf6c871b517e47404421}{repository}.
#'
#'
#' @author \href{https://github.com/alekrutkowski}{Alek Rutkowski}
#'
#' @seealso \href{https://gist.github.com/alekrutkowski/e46fae4dc079bf6c871b517e47404421}{Gist GitHub repository where the original code is located.}
#'
#' @param .Fun function to apply
#' @param ... parameteres
#' @param .Cluster Cluster
#' @param .parFun function of "parallel::"
#'
#' @return list with the result of applying a function to all combinations
#' @export
#'
#' @examples
#' mlapply(function(x, y ) paste(x,"+",y,"=", x+y) ,
#'         x = 1:3, y = 3:1)
mlapply <- function(.Fun, ..., .Cluster=NULL, .parFun=parallel::parLapply) {
  `--List--` <-
    list(...)
  names(`--List--`) <-
    names(`--List--`) %>%
    `if`(is.null(.),
         rep.int("", length(`--List--`)),
         .) %>%
    ifelse(.=="", # for unnamed args in ...
           seq_along(.) %>%
             paste0(ifelse(.==1 | .>20 & .%%10==1, 'st', ""),
                    ifelse(.==2 | .>20 & .%%10==2, 'nd', ""),
                    ifelse(.==3 | .>20 & .%%10==3, 'rd', ""),
                    ifelse(.>3 & .<=20 | !(.%%10 %in% 1:3), 'th', "")) %>%
             paste("argument in mlapply's ..."),
           .)
  `--metadata--` <-
    data.frame(Name = paste0("`",names(`--List--`),"`"),
               Len = lengths(`--List--`),
               OriginalOrder = seq_len(length(`--List--`)),
               stringsAsFactors=FALSE)
  eval(Reduce(function(previous,x)
    paste0('unlist(lapply(`--List--`$',x,',',
           'function(',x,')', previous,'),recursive=FALSE)'),
    x =
      `--metadata--` %>%
      `[`(order(.$Len),) %>%
      `$`(Name),
    init =
      `--metadata--` %>%
      `[`(order(.$OriginalOrder),) %>%
      `$`(Name) %>%
      ifelse(grepl("argument in mlapply's ...",.,fixed=TRUE),
             ., paste0(.,'=',.)) %>%
      paste(collapse=',') %>%
      paste0('list(.Fun(',.,'))')) %>%
      ifelse(.Cluster %>% is.null,
             .,
             sub('lapply(',
                 '.parFun(.Cluster,',
                 ., fixed=TRUE)) %>%
      parse(text=.))
}
