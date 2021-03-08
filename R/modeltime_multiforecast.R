#' @title Forecasting de multiples modelos sobre multiples series
#'
#' @description Esta funcion permite ralizar un forecating sobre multiples series de tiempo a partir de multiples modelos
#'              entrenados.
#'
#' @details Esta funcion toma el objeto table_time de la salida de la funcion "modeltime_multifit", posteriomente
#'          aplica la funcion "modeltime_forecast" a cada uno de los multiples modelos sobre multiples series.
#'
#' @param models_table tibble que proviene del objeto table_time de la salida de la funcion "modeltime_multifit".
#' @param .h horizonte de predicción de la funcion "modeltime_forecast".
#' @param .prop proporción de la partición de splits de als series de tiempo. En caso de no especificar "h", esta funcion
#'              proyecta en la particion de testing.
#'
#' @return tibble correspondiente al mismmo suministardo en el parametro "models_table", agregando una nueva columna llamada
#'         "nested_forecast" donde se guardan las predicciones.
#' @export
#'
#' @examples
#' library(sknifedatar)
#' data("table_time")
#'
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
                                    function(calibration, nested_column){
                                      calibration %>%
                                        modeltime::modeltime_forecast(
                                          new_data    =  if (is.null(.h)) {

                                            rsample::initial_time_split(nested_column, prop = .prop) %>% rsample::testing()

                                          } else {
                                            NULL
                                          },
                                          h=.h,
                                          actual_data = nested_column) %>%
                                        dplyr::mutate(
                                          .model_details = .model_desc,
                                          .model_desc = stringr::str_replace_all(.model_desc,
                                                                        "[[:punct:][:digit:][:cntrl:]]", "")
                                        ) %>%
                                        dplyr::mutate(.model_desc = ifelse(stringr::str_detect(.model_desc, "ARIMA"),
                                                                    "ARIMA"
                                                                    , .model_desc))
                                    }))
  }
