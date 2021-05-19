#' Forecast of a workflow set on multiple time series
#' 
#' @description generates forecasts of a workflow set object over multiple time series.
#'
#' @param models_table a tibble that comes from the output of the `modeltime_wfs_multifit()`, `modeltime_wfs_multirefit()`,
#'                     `modeltime_wfs_multibestmodel()` functions. For the `modeltime_wfs_multifit()` function, 
#'                     the 'table_time' object must be selected from the output.
#' @param .h prediction horizon of the `modeltime_forecast()` function of the 'modeltime' package.
#' @param .prop decimal number, time series split partition ratio. If ".h" is specified, this function 
#'              predicts on the testing partition.
#'
#' @return a tibble, corresponds to the same tibble supplied in the 'models_table' parameter but with an additional 
#'         column called 'nested_forecast' where the nested previews of the workflows on all the time series are stored.
#' 
#' @export 
#'
#' @examples
#' library(dplyr)
#' library(earth)
#' 
#' df <- sknifedatar::emae_series
#' 
#' datex <- '2020-02-01'
#' df_emae <- df %>%
#'   dplyr::filter(date <= datex) %>% 
#'   tidyr::nest(nested_column=-sector) %>% head(2)
#' 
#' receta_base <- recipes::recipe(value ~ ., data = df %>% select(-sector))
#' 
#' mars <- parsnip::mars(mode = 'regression') %>% parsnip::set_engine('earth')
#' 
#' wfsets <- workflowsets::workflow_set(
#'   preproc = list(
#'     R_date = receta_base),
#'   models  = list(M_mars = mars),
#'   cross   = TRUE)
#' 
#' wfsets_fit <- sknifedatar::modeltime_wfs_multifit(.wfs = wfsets,
#'                                                   .prop = 0.8, 
#'                                                   serie = df_emae)
#' 
#' sknifedatar::modeltime_wfs_multiforecast(wfsets_fit$table_time,
#'                                          .prop=0.8)
#' 
modeltime_wfs_multiforecast <- function(models_table,
                                        .h = NULL,
                                        .prop = NULL) {
  
  .models_table <- models_table %>%
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
                                                      .model_details = .model_desc)
                                                  
                                                }))
  
  list_forecast <- .models_table %>% purrr::pluck('nested_forecast')
  
  list_nested_forecast <-
    purrr::map(list_forecast, function(y = list_forecast){
      
      models_series <- y %>% 
        dplyr::group_by(models_freq = .model_id) %>% 
        dplyr::summarise(freq = dplyr::n()) %>% 
        dplyr::ungroup() %>% 
        dplyr::slice(nrow(.),1:(nrow(.)-1))
      
      exp1 <- colnames(.models_table)
      exp2 <- c("ACTUAL", exp1[3:(which(exp1 == "nested_model") - 1)])
      exp3 <- data.frame(models_freq = c(NA,1:(length(exp2)-1)),
                         .model_descs = exp2)
      
      models_series2 <- models_series %>% dplyr::left_join(exp3)
      
      model_desc <- purrr::map2(models_series2$freq,models_series2$.model_descs, ~rep(x = .y, times = .x)) %>% unlist()
      
      y %>% dplyr::mutate(.model_desc = model_desc)
      
    })
  
  .models_table %>% dplyr::mutate(nested_forecast = list_nested_forecast)
  
}