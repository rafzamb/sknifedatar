#' @title  Ajuste de multiples modelos a multiples series de tiempo
#'
#' @description Esta funcion permite ajusatr multiples mdoelos sobre multiples series de tiempo,
#'              utilizando los modelos del paquete \href{https://business-science.github.io/modeltime/}{modeltime}.
#'
#' @details El enfoque de esta función no esta relacionado con series de panel, esta orientada a multiples series individuales.
#'          Recibeindo como primer argumento "serie" un conjunto de series anidadas (por ejemplo a traves de la funcion nest),
#'          luego especificando una proporcion deseada para particionar cada una de las series en train/test.
#'
#'
#'          Por ultimo se deben suministrar los modelos a entrenar, siemplente escribiendo el nombre de los modelos separados
#'          por comas, la funcion admite tantos modelos como se requierean.
#'
#' @importFrom rlang .data
#'
#' @seealso \href{https://rafzamb.github.io/sknifedatar/}{sknifedatar website}
#'
#'
#' @param serie series de tiempo anidadas
#' @param .prop proporción de partición de las series en train/test
#' @param ... modelos o workflows a entrenar (model_1,model2,...)
#'
#' @return una lista con 2 elementos. El primer componnete es un tibble que contiene una primera columna que contiene el nombre
#'         de las series, seguidamente la comuna "nested_column" que almacena las series de tiempo, luego una columna para cada
#'         modelo suministrado donde se almacenanan los modelos o workflows entrenados para cada series.
#'
#'         Finalmente las columnas "nested_model" y "calibration" que guardan los "n" modelos entrenados para cada serie y las metricas de ajuste sobre la
#'         particion de test.
#'
#' @export
#'
#' @examples
#' # libraries
#' library(modeltime)
#' library(rsample)
#' library(parsnip)
#' library(recipes)
#' library(workflows)
#' library(dplyr)
#' library(tidyr)
#' library(sknifedatar)
#'
#' # Data
#' data("emae_series")
#' nested_serie = emae_series %>% nest(nested_column=-sector)
#'
#' # Recipes
#' recipe_1 = recipe(value ~ ., data = emae_series %>% select(-sector)) %>%
#' step_date(date, features = c("month", "quarter", "year"), ordinal = TRUE)
#'
#' # Models
#' m_auto_arima <- arima_reg() %>% set_engine('auto_arima')
#'
#' m_stlm_arima <- seasonal_reg() %>%
#'   set_engine("stlm_arima")
#'
#' m_nnetar <- workflow() %>%
#'   add_recipe(recipe_1) %>%
#'   add_model(nnetar_reg() %>% set_engine("nnetar"))
#'
#' # modeltime_multifit
#' model_table_emae = modeltime_multifit(serie = nested_serie %>% head(3),
#'                                       .prop = 0.8,
#'                                       m_auto_arima,
#'                                       m_stlm_arima,
#'                                       m_nnetar)
#'
#' model_table_emae
modeltime_multifit = function(serie, .prop, ...){

  # Funcion de ajuste
  nest_fit = function(serie, model, .proporcion = .prop){

    if(class(model)[1] == "workflow"){

      model %>% parsnip::fit(data = rsample::training(rsample::initial_time_split(serie, prop= .proporcion)))

    }else{
      model %>%

        parsnip::fit(value ~ date, data = rsample::training(rsample::initial_time_split(serie, prop=.proporcion)))
    }
  }

  # Nombrado de multiples argumentos
  exprs = substitute(list(...))
  list_model = list(...)
  names(list_model) = vapply(as.list(exprs), deparse, "")[-1]
  nombres = names(list_model)

  #Funcion de ajuste multiple
  models_fits = mapply(function(modelo, name_model, prop){

    tabla = serie %>%
      dplyr::mutate("{name_model}" := purrr::map(.data$nested_column, nest_fit, model = modelo, .proporcion = prop)) %>%
      dplyr::select(3)

  },list_model, nombres, prop = .prop, SIMPLIFY = F)

  time_data = dplyr::bind_cols(serie, models_fits)

  # Tabla de modeltime_table
  # Captura de la expresion list(model_1, model_2, model_3,....)
  exp1 = colnames(time_data)[3:ncol(time_data)]
  exp2 = paste("list(",paste(exp1, collapse = ","),")")
  exp3 = parse(text = exp2)

  # Nueva columna con todos los modelos por serie
  table_time = time_data %>%

    dplyr::mutate(nested_model = purrr::pmap(eval(exp3), .f = function(...) {modeltime::modeltime_table(...)}),

           calibration = purrr::pmap(list(nested_model, nested_column), function(nested_model, nested_column) {

             nested_model %>%

               modeltime::modeltime_calibrate(new_data = rsample::testing(rsample::initial_time_split(nested_column, prop = 0.9)))

             }))

  # Nombre a los elementos de la lista de calibration
  #names(table_time$calibration) = table_time[,1]

  # Metricas de los modelos
  models_accuracy = mapply(function(calibracion, name_ts) {

    calibracion %>%
      modeltime::modeltime_accuracy() %>%
      dplyr::mutate(name_serie = name_ts) %>%
      dplyr::relocate(.data$name_serie)

  }, table_time$calibration, table_time$sector, SIMPLIFY = F) %>% dplyr::bind_rows()

  list(table_time = table_time,
       models_accuracy = models_accuracy)
}
