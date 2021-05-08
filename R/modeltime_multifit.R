#' @title  Fit Multiple Models to Multiple Time Series
#'
#' @description This function allows multiple models to be adjusted over multiple time series, using models
#'              from the \href{https://business-science.github.io/modeltime/}{modeltime} package.
#'
#' @details The focus of this function is not related to panel series, it is oriented to multiple individual
#'          series. Receiving as the first argument "series" a set of nested series (for example through the
#'          nest function), then specifying a desired train/test partition ratio for series. The
#'          final input to the function are the models to be trained, simply by typing the name
#'          of the models separated by commas. The function admits as many models as required.
#'
#' @importFrom rlang .data
#'
#' @seealso \href{https://rafzamb.github.io/sknifedatar/}{sknifedatar website}
#'
#'
#' @param serie nested time series.
#' @param .prop series train/test partition ratio.
#' @param ... models or workflows to train (model_1, model2, ...).
#'
#' @return A list of 2 items. The first component is a tibble with a first column that contains the
#'         name of the series, and a second column called "nested_column" that stores the time series,
#'         then a column for each model where the trained models or workflows for each series are stored.
#'         The last 2 columns, "nested_model" and "calibration", store the "n" trained models for each
#'         series and the adjustment metrics on the test partition.
#'
#' @export
#'
#' @examples
#'
#' # Generate "table_time" object
#'
#' ## Data
#' library(modeltime)
#' nested_serie <- 
#' tidyr::nest(dplyr::filter(sknifedatar::emae_series, date < '2006-02-01'),
#'             nested_column = -sector)
#'
#' ## Models
#' m_ets <- parsnip::set_engine(modeltime::exp_smoothing(), 'ets')
#'
#' m_nnetar <- parsnip::set_engine(modeltime::nnetar_reg(), "nnetar")
#'
#' # modeltime_multifit
#' sknifedatar::modeltime_multifit(serie = head(nested_serie,2),
#'                                 .prop = 0.97,
#'                                 m_ets,
#'                                 m_nnetar)
#'
modeltime_multifit <- function(serie, .prop, ...){
  
  variables <- serie %>% dplyr::select(nested_column) %>% purrr::pluck(1,1) %>% names()
  if('value' %in% variables == FALSE) stop("No 'value' column was found. Please specify a column named 'value'.")
  

  #Fit Function
  nest_fit <- function(serie, model, .proportion = .prop){

    if (tune::is_workflow(model) == TRUE) {

      model %>% parsnip::fit(data = rsample::training(rsample::initial_time_split(serie, prop= .proportion)))

    }else{
      model %>%

        parsnip::fit(value ~ date, data = rsample::training(rsample::initial_time_split(serie, prop=.proportion)))
    }
  }

  #Naming of multiple arguments
  exprs <- substitute(list(...))
  list_model <- list(...)
  names(list_model) <- vapply(as.list(exprs), deparse, "")[-1]
  names_list_model <- names(list_model)

  #Multiple fit function
  models_fits <- mapply(function(.model, name_model, prop){

    table_models <- serie %>%
      dplyr::mutate("{name_model}" := purrr::map(.data$nested_column, ~ nest_fit(serie = .x , model = .model, .proportion = prop))) %>%
      dplyr::select(3)

  },list_model, names_list_model, prop = .prop, SIMPLIFY = F)

  time_data <- dplyr::bind_cols(serie, models_fits)

  #modeltime_table table
  #Expression capture list(model_1, model_2, model_3,....)
  exp1 <- colnames(time_data)[3:ncol(time_data)]
  exp2 <- paste("list(",paste(exp1, collapse = ","),")")
  exp3 <- parse(text = exp2)

  # New column with all models per series
  table_time <- time_data %>%

    dplyr::mutate(nested_model = purrr::pmap(eval(exp3),
                                             .f = function(...) {modeltime::modeltime_table(...)})
                  ) %>% 

    dplyr::mutate(calibration = purrr::pmap(list(.data$nested_model, .data$nested_column),
                                            .f = function(x = .data$nested_model, y = .data$nested_column) {

                    x %>%

                      modeltime::modeltime_calibrate(new_data = rsample::testing(rsample::initial_time_split(y, prop = .prop)))

                  }))

  #Models metrics
  models_accuracy <- mapply(function(calibracion, name_ts) {

    calibracion %>%
      modeltime::modeltime_accuracy() %>%
      dplyr::mutate(name_serie = name_ts) %>%
      dplyr::relocate(.data$name_serie)

  }, table_time$calibration, table_time[[1]], SIMPLIFY = F) %>% dplyr::bind_rows()
  
  cli::cat_line()
  cli::cli_h1(paste0(nrow(table_time), ' models fitted ', cli::symbol$heart))

  list(table_time = table_time,
       models_accuracy = models_accuracy)
}