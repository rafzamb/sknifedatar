#' @title Función para reajustar el o los modelos para múltiples series de tiempo
#'
#' @description Esta función permite aplicar la función "**modeltime_refit()**" de \href{https://business-science.github.io/modeltime/}{**modeltime**}
#'              a múltiples series y modelos.
#'
#' @details Toma como input el objeto "**table_time**" de la salida de la función "**modeltime_multifit**" y
#'          devuelve el mismo objeto pero entrenado en todo el período.
#'
#' @param models_table tibble que proviene del objeto "**table_time**" de la salida de la función "**modeltime_multifit**".
#'
#' @return Devuelve el objeto "**table_time**" recalibrado.
#' @export
#'
#' @examples
#'
#' # Generate "table_time" object
#' ## libraries
#' library(modeltime)
#' library(rsample)
#' library(parsnip)
#' library(recipes)
#' library(workflows)
#' library(dplyr)
#' library(tidyr)
#' library(sknifedatar)
#'
#' ## Data
#' emae_series <- sknifedatar::emae_series
#' nested_serie <- emae_series %>% filter(date < '2008-02-01') %>% nest(nested_column=-sector)
#'
#' ## Recipes
#' recipe_1 = recipe(value ~ ., data = emae_series %>% select(-sector)) %>%
#'   step_date(date, features = c("month", "quarter", "year"), ordinal = TRUE)
#'
#' ## Models
#' m_ets <- workflow() %>%
#'   add_model(exp_smoothing() %>% set_engine('ets')) %>%
#'   add_recipe(recipe_1)
#'
#' m_nnetar <- workflow() %>%
#'   add_model(nnetar_reg() %>% set_engine("nnetar")) %>%
#'   add_recipe(recipe_1)
#'
#' # modeltime_multifit
#' model_table_emae = modeltime_multifit(serie = nested_serie %>% head(2),
#'                                       .prop = 0.8,
#'                                       m_ets,
#'                                       m_nnetar)
#'
#' table_time <- model_table_emae$table_time
#'
#' # modeltime_multirefit
#' table_time_refit <- modeltime_multirefit(models_table = table_time)
#'
#' table_time_refit
modeltime_multirefit <- function(models_table){

  t_calibration <- models_table$calibration
  t_serie <- models_table$nested_column

  m_refit = mapply(function(t_calibration, t_serie){

    t_calibration %>%
      modeltime::modeltime_refit(t_serie)

  },t_calibration, t_serie, SIMPLIFY = F)

  output_def = models_table
  output_def$calibration = m_refit

  output_def
}
