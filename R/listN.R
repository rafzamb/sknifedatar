#' Agregación automática del nombre de elementos de una lista
#'
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
listN <- function(...){
  dots <- list(...)
  inferred <- sapply(substitute(list(...)), function(x) deparse(x)[1])[-1]
  if(is.null(names(inferred))){
    names(dots) <- inferred
  } else {
    names(dots)[names(inferred) == ""] <- inferred[names(inferred) == ""]
  }
  dots
}
