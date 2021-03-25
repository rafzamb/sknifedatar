#' @title Función para obtener el mejor modelo a partir de una modeltime table
#'
#' @description Esta función permite seleccionar el mejor modelo para cada serie, en función de determinada métrica de evaluación.
#'
#' @details Esta función toma el objeto "**table_time**" de la salida de la función "**modeltime_multifit**",
#'          posteriomente se selecciona el mejor modelo en función de la métrica seleccionada.
#'
#' @param .table tibble que proviene del objeto "**table_time**" de la salida de la función "**modeltime_multifit**".
#' @param .metric métrica de evaluación, proviene de "**modeltime_accuracy**": 'mae', 'mape','mase','smape','rmse','rsq'.
#' @param .optimization Es posible minimizar una métrica de error ('which.min') o maximizar el rsq ('which.max').
#'
#' @return tibble table_time filtrada por el mejor modelo.
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
#' # best_model_emae
#' best_model_emae <- modeltime_multibestmodel(.table=table_time,
#'                                             .metric=rmse,
#'                                             .optimization = which.min)
#'
#' best_model_emae
modeltime_multibestmodel <- function(.table,
                                     .metric = 'mase',
                                     .optimization = which.min){

  calibration_table_best = .table %>%
    dplyr::mutate(
      best_model = purrr::map(calibration, .f = function(.x){
        .x %>%
          modeltime::modeltime_accuracy() %>%
          dplyr::slice(rlang::expr(!!.optimization)(!!rlang::enquo(.metric))) %>%
          dplyr::pull(.model_id)
      }),
      calibration = purrr::pmap(list(calibration, best_model), .f = function(col = calibration, m = best_model){
        col %>%
          dplyr::filter(.model_id == m)
      })
    )

  return(calibration_table_best)
}
