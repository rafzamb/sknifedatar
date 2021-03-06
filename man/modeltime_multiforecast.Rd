% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/modeltime_multiforecast.R
\name{modeltime_multiforecast}
\alias{modeltime_multiforecast}
\title{Forecasting of multiple models over multiple time series}
\usage{
modeltime_multiforecast(models_table, .h = NULL, .prop = NULL)
}
\arguments{
\item{models_table}{'table_time' tibble generated with the \code{modeltime_multifit()} function.}

\item{.h}{prediction horizon of the \code{modeltime_forecast()} function.}

\item{.prop}{time series split partition ratio. If "h" is specified, this function predicts on the testing partition.}
}
\value{
'models_table' tibble with a new column called 'nested_forecast' where the predictions are stored.
}
\description{
allows forecasting on multiple time series from multiple fitted models.
}
\details{
this function takes the 'table_time' object generated with the \code{modeltime_multifit()} function,
the \code{modeltime_forecast()} from the package 'modeltime' is applied to each model for each series.
}
\examples{
# Data
data_serie <- sknifedatar::table_time
                                     
# Forecast
sknifedatar::modeltime_multiforecast(data_serie$table_time, .prop=0.8)

}
