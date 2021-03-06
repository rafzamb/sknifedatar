% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/modeltime_multifit.R
\name{modeltime_multifit}
\alias{modeltime_multifit}
\title{Fit Multiple Models to Multiple Time Series}
\usage{
modeltime_multifit(serie, .prop, ...)
}
\arguments{
\item{serie}{nested time series.}

\item{.prop}{series train/test partition ratio.}

\item{...}{models or workflows to train (model_1, model2, ...).}
}
\value{
A list of 2 items. The first component is a tibble with a first column that contains the
name of the series, and a second column called "nested_column" that stores the time series,
then a column for each model where the trained models or workflows for each series are stored.
The last 2 columns, "nested_model" and "calibration", store the "n" trained models for each
series and the adjustment metrics on the test partition.
The second element is a tibble saved with the name of 'models_accuracy', it allows to visualize
the performance of each model for each series according to a set of metrics.
}
\description{
allows multiple models to be fitted over multiple time series, using models
from the 'modeltime' package.
}
\details{
the focus of this function is not related to panel series, it is oriented to multiple individual
series. Receiving as the first argument "series" a set of nested series (for example through the
\code{nest()} function), then specifying a desired train/test partition ratio for series. The
final input to the function are the models to be trained, simply by typing the name
of the models separated by commas. The function admits as many models as required.
}
\examples{
library(modeltime)
library(earth)
nested_serie <- 
tidyr::nest(dplyr::filter(sknifedatar::emae_series, date < '2007-02-01'),
            nested_column = -sector)

## Models
mars <- parsnip::mars(mode = 'regression') \%>\% parsnip::set_engine('earth')

# modeltime_multifit
sknifedatar::modeltime_multifit(serie = head(nested_serie,2),
                                .prop = 0.9,
                                mars)
}
\seealso{
\href{https://rafzamb.github.io/sknifedatar/}{sknifedatar website}
}
