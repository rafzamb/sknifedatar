#' @title Fitted models for the EMAE indicator
#'
#' @description set of models fitted on the "emae_series" dataset, this object comes from the output of the
#'              `modeltime_multifit()` function. For example, if object = modeltime_multifit then 'object$table_time' 
#'              is the fitted models table.
#'
#' @format a tibble that contains a first column with the name of the series, then the "nested_column" column 
#'         that stores the time series, then a column for each supplied model where the models or trained workflows
#'         for each series are stored. Finally the columns "nested_model" and "calibration" that store the "n" 
#'         trained models for each series and the adjustment metrics on the test partition.
#'
#' @source \url{https://rafzamb.github.io/sknifedatar/}
"table_time"
