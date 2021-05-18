#' Fit a workflow_set object over multiple time series
#' 
#' @description allows a workflow_set object to be fitted over multiple time series, using models
#'              from the 'modeltime' package.
#'
#' @param serie  nested time series.
#' @param .prop series train/test partition ratio.
#' @param .wfs worklows_set object.
#'
#' @return A list of 2 items. The first component is a tibble with a first column that contains the
#'         name of the series, and a second column called 'nested_column' that stores the time series,
#'         then a column for each workflow for each series are stored.
#'         The last 2 columns, 'nested_model' and 'calibration', store the 'n' trained workflows for each
#'         series and the adjustment metrics on the test partition.
#'         The second element is a tibble saved with the name of 'models_accuracy', it allows to visualize 
#'         the performance of each workflow for each series according to a set of metrics.
#' @export
#'
#' @examples
#' library(dplyr)
#' 
#' df <- sknifedatar::emae_series
#' 
#' datex <- '2020-02-01'
#' df_emae <- df %>%
#' dplyr::filter(date <= datex) %>% 
#' tidyr::nest(nested_column=-sector) %>% 
#' head(2)
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
#' sknifedatar::modeltime_wfs_multifit(.wfs = wfsets,
#'                                     .prop = 0.8, 
#'                                     serie = df_emae)
#' 
modeltime_wfs_multifit <- function(serie, .prop, .wfs){
  
  # Function fit
  nest_fit <- function(serie, model, .proportion = .prop){
    if (tune::is_workflow(model) == TRUE) {
      
      tryCatch({
        
        nest_fit_out <- model %>%
          
          parsnip::fit(data = rsample::training(rsample::initial_time_split(serie, prop = .proportion)))
        
        cli::cli_alert_success('Workflow training finished OK.')
        
        nest_fit_out
        
      }, error = function(x){
        
        cli::cli_alert_warning(paste0("Warninng: the workflow raised an error,it will be ignored \n",x)) 
        NULL
      }
      )
    }
    else {
      
      tryCatch({
        
        model %>%
          
          parsnip::fit(value ~ date, data = rsample::training(rsample::initial_time_split(serie, prop = .proportion)))
        
        cli::cli_alert_success('Model training finished OK.')
        
      }, error = function(x){
        
        cli::cli_alert_warning(paste0("Warninng: the model raised an error,it will be ignored \n",x)) 
        NULL
      }
      )
    }
  }
  
  # Naming of multiple arguments
  
  list_wfs <- .wfs %>% split(.wfs$wflow_id)
  list_model <- purrr::map(list_wfs, ~ .x %>% pull(2) %>% purrr::pluck(1, 'workflow', 1))
  nombres <- names(list_model)
  
  # Multiple setting function
  models_fits <- mapply(function(modelo, name_model, prop){
    tabla <- serie %>%
      
      dplyr::mutate("{name_model}" := purrr::map(nested_column,
                                                 ~ nest_fit(serie = .x , 
                                                            model = modelo,
                                                            .proportion = prop))) %>%
      
      dplyr::select(3)
    
  },list_model, nombres, prop = .prop, SIMPLIFY = F)
  
  time_data <- dplyr::bind_cols(serie, models_fits)
  
  # Validation models NULL
  validation_col <- purrr::map(time_data, 
                               function(x) purrr::map(x, is.null) %>% unlist() %>% any()) %>% unlist() %>% which() %>% unname()
  
  if(!length(validation_col) == 0) time_data <- time_data[,-validation_col]
  
  # Table of modeltime_table
  # Capture the expression list(model_1, model_2, model_3,....)
  number_models_fit <-length(3:ncol(time_data))
  exp1 <- colnames(time_data)[3:ncol(time_data)]
  exp2 <- paste("list(",paste(exp1, collapse = ","),")")
  exp3 <- parse(text = exp2)
  
  # New column with all models per series
  table_time <- time_data %>%
    
    dplyr::mutate(nested_model = purrr::pmap(eval(exp3), .f = function(...) {modeltime::modeltime_table(...)})) %>% 
    
    dplyr::mutate(calibration = purrr::pmap(list(nested_model, nested_column), function(x = nested_model, y = nested_column) {
      x %>%
        modeltime::modeltime_calibrate(new_data = rsample::testing(rsample::initial_time_split(y, prop = .prop)))
    }))
  
  # Name the items in the calibration list
  # Metrics of models
  models_accuracy <- mapply(function(calibracion, name_ts) {
    
    calibracion %>%
      
      modeltime::modeltime_accuracy() %>%
      
      dplyr::mutate(name_serie = name_ts) %>%
      
      dplyr::relocate(.data$name_serie)
    
  }, table_time$calibration, table_time[[1]], SIMPLIFY = F) %>% dplyr::bind_rows()
  
  
  cnames <- colnames(table_time)
  model_names <- cnames[3:(which(cnames == "nested_model") - 1)]
  n_series <- models_accuracy$name_serie %>% unique() %>% length()
  model_names <- rep(x = model_names, times = n_series)
  
  models_accuracy <- models_accuracy %>% 
    
    dplyr::mutate(.model_names = model_names) %>% 
    
    dplyr::relocate(.model_names, .after = .model_id )
  
  
  # Number models fit and drop
  cli::cli_h1(paste0(number_models_fit,' models fitted ',cli::symbol$heart))
  cli::cli_h2(paste0(nrow(.wfs) - number_models_fit,' models deleted ',cli::symbol$cross))
  
  return(list(table_time = table_time,
              models_accuracy = models_accuracy)
  )
}