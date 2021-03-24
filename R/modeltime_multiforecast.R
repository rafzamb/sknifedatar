#' @title Forecasting de múltiples modelos sobre múltiples series de tiempo
#'
#' @description Esta función permite realizar un forecasting sobre múltiples series de tiempo a partir de
#'              múltiples modelos entrenados.
#'
#' @details Esta función toma el objeto "**table_time**" de la salida de la función "**modeltime_multifit**", posteriormente
#'          aplica la función "**modeltime_forecast**" del paquete de \href{https://business-science.github.io/modeltime/}{**modeltime**}
#'          a cada uno de los múltiples modelos sobre múltiples series.
#'
#' @param models_table tibble que proviene del objeto "**table_time de la salida**" de la función "**modeltime_multifit**".
#' @param .h horizonte de predicción de la función "**modeltime_forecast**".
#' @param .prop proporción de la partición de splits de las series de tiempo. En caso de no especificar "h", esta función
#'              predice sobre la particion de testing.
#'
#' @return tibble correspondiente al mismmo suministardo en el parámetro "models_table", agregando una nueva columna llamada
#'         "nested_forecast" donde se guardan las predicciones.
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
#' m_naive_reg <- naive_reg() %>%  set_engine("naive")
#'
#' m_nnetar <- workflow() %>%
#'   add_model(nnetar_reg() %>% set_engine("nnetar")) %>%
#'   add_recipe(recipe_1)
#'
#' ## modeltime_multifit
#' model_table_emae <- modeltime_multifit(serie = nested_serie %>% head(2),
#'                                        .prop = 0.8,
#'                                        m_naive_reg ,
#'                                        m_nnetar)
#'
#' table_time <- model_table_emae$table_time
#'
#' # Forecast
#' forecast_emae <- modeltime_multiforecast(table_time,
#'                                          .prop=0.8)
#'
#'
#' forecast_emae
modeltime_multiforecast <- function(models_table,
                                    .h=NULL,
                                    .prop = NULL) {

  models_table %>%
    dplyr::mutate(nested_forecast = purrr::pmap(list(calibration, nested_column),
                                                function(x = calibration, y = nested_column){
                                                  x %>%
                                                    modeltime::modeltime_forecast(
                                                      new_data    =  if (is.null(.h)) {

                                                        rsample::initial_time_split(y, prop = .prop) %>% rsample::testing()

                                                      } else {
                                                        NULL
                                                      },
                                                      h=.h,
                                                      actual_data = y) %>%
                                                    dplyr::mutate(
                                                      .model_details = .model_desc,
                                                      .model_desc = stringr::str_replace_all(.model_desc,
                                                                                             "[[:punct:][:digit:][:cntrl:]]", "")
                                                    )
                                                }))
}
