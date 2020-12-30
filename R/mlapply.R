#' Title
#'
#' @param .Fun asADSa
#' @param ... asas
#' @param .Cluster dasd
#' @param .parFun dasasda
#'
#' @return saSa
#' @export
#'
#' @examples
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
