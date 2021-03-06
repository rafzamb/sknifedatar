#' @title Time series of the monthly estimator of Argentine economic activity, grouped by sector
#'
#' @description The EMAE is an indicator that reflects the monthly evolution of the economic activity of all the
#'              productive sectors nationwide for Argentina, for more 
#'              details: \href{https://www.indec.gob.ar/indec/web/Nivel4-Tema-3-9-48}{EMAE indicator}. 
#'              Data was obtained from all the sectoral EMAE series, from January 2004 to October 2020, 
#'              from \href{https://datos.gob.ar/dataset/jgm_3/archivo/jgm_3.13}{Time Series (API)}
#'               from the Government Open Data Portal. 
#'
#' @format A data frame with 3104 rows and 3 columns, the variable "date" represents the monthly date, 
#' "value" the monthly value of the indicator and the sector column indicates the id or economic sector of the series.
#'
#' @source \url{https://datos.gob.ar/dataset/jgm_3/archivo/jgm_3.13}
"emae_series"
