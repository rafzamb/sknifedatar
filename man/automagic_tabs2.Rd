% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/automagic_tabs2.R
\name{automagic_tabs2}
\alias{automagic_tabs2}
\title{Automatic Generation of Tabs with multiple outputs}
\usage{
automagic_tabs2(
  input_data,
  panel_name,
  ...,
  tabset_title = "",
  tabset_props = ".tabset-fade .tabset-pills",
  chunk_props = list(echo = FALSE, fig.align = "center"),
  is_output_distill = TRUE
)
}
\arguments{
\item{input_data}{Ungrouped tibble with at least 2 columns, one for the title of the tabs and another with
the output to be displayed.}

\item{panel_name}{column with the ID variable.}

\item{...}{nested columns that contain outputs to display.}

\item{tabset_title}{string title of the .tabset}

\item{tabset_props}{string defining .tabset properties. Only works with is_output_distill = F}

\item{chunk_props}{named list with additional parameters that correspond to all those available in rmarkdown chunks
(fig.align, fig.width, ...).}

\item{is_output_distill}{boolean. is output a distill article.}
}
\value{
concatenated string of all automatically generated chunks.
}
\description{
It allows to automatically generate the code necessary to group multiple Rmarkdown chunks
into tabs. Concatenating all the chunks into a string that can be later knitted and rendered.
}
\details{
given a tiblle, which must contain an "ID" column (representing the title of the tabs) and other
columns that stores output to be generated (plot, text, code, ...), a string is automatically
generated which can be later rendered in a Rmarkdown document.
}
\examples{
library(dplyr)
library(sknifedatar)
library(ggplot2)

dataset <- iris \%>\% 
  group_by(Species) \%>\% 
  tidyr::nest() \%>\% 
  mutate(
    .plot = purrr::map(data, ~ ggplot(.x, aes(x = Sepal.Length, y = Petal.Length)) + geom_point()),
    .table = purrr::map(data, ~ summary(.x) \%>\% knitr::kable())
  ) \%>\% 
  ungroup()

automagic_tabs2(input_data = dataset, panel_name = Species, .plot, .table)

unlink("figure", recursive = TRUE)
}
\seealso{
\href{https://rafzamb.github.io/sknifedatar/}{sknifedatar website}
}
