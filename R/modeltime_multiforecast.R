#' @title Forecasting of multiple models over multiple time series
#'
#' @description This function allows forecasting on multiple time series from multiple fitted models
#'
#' @details This function takes the "**table_time**" object generated with the "**modeltime_multifit**" function, the "**modeltime_forecast**"
#'          from the package \href{https://business-science.github.io/modeltime/}{**modeltime**} is applied to each model for each series. 
#'
#' @param models_table "**table_time**" tibble generated with the "**modeltime_multifit**" function.
#' @param .h prediction horizon of the "**modeltime_forecast**" function.
#' @param .prop time series split partition ratio. If "h" is specified, this function predicts on the testing partition. 
#'
#' @return "models_table" tibble with a new column called "nested_forecast" where the predictions are stored.
#' @export
#'
#' @examples
#'
#' # Data
#' data_serie <- sknifedatar::table_time
#'                                      
#' # Forecast
#' sknifedatar::modeltime_multiforecast(data_serie$table_time, .prop=0.8)
#'
modeltime_multiforecast <- function(models_table,
                                    .h = NULL,
                                    .prop = NULL) {

  models_table %>%
    
    dplyr::mutate(
      
      nested_forecast = purrr::pmap(list(calibration, nested_column),
                                    
                                    function(x = calibration, y = nested_column){
                                      
                                      x %>% modeltime::modeltime_forecast(
                                        
                                        new_data = if (is.null(.h)) {
                                          
                                          rsample::initial_time_split(y, prop = .prop) %>% rsample::testing()
                                          
                                          } else {NULL},
                                        
                                        h = .h,
                                        
                                        actual_data = y) %>%
                                        
                                        dplyr::mutate(
                                          
                                          .model_details = .model_desc,
                                          
                                          .model_desc = gsub("[[:punct:][:digit:][:cntrl:]]","", .model_desc)
                                          )
                                      }
                                    )
    )
  }
