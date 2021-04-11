#' @title Modeltime workflowsets fit
#'
#' @description It allows working with workflow sets and modeltime. Combination of recipes and models are trained and evaluation metrics are returned.
#'
#' @details Given a workflow_set containing multiple time series recipes and models, modeltime_wfs_fit adjusts all the possible combinations on a time series. 
#'          It uses a split proportion in order to train on a time series partition and evaluate metrics on the testing partition.
#'
#' @seealso \href{https://rafzamb.github.io/sknifedatar/}{sknifedatar website}
#'
#' @param .wfsets  workflow_set object, generated with the workflow_set function from the workflowsets package.
#' @param .split_prop time series split proportion
#' @param .serie time series dataframe
#'
#' @return tbl_df containing the model id (based on workflow_set), model description and metrics on the time series testing dataframe. 
#'         Also, a .fit_model column is included, which contains each fitted model. 
#'
#' @export
#'
#' @examples
#'
#'
#'library(sknifedatar)
#'library(recipes)
#'library(modeltime)
#'library(workflowsets)
#'library(workflows)
#'library(parsnip)
#'library(timetk)
#'
#'df <- sknifedatar::data_avellaneda %>% 
#'   mutate(date=as.Date(date)) %>% 
#'   filter(date<'2011-01-01')
#'
#'recipe_date <- recipe(value ~ ., data = df) %>% 
#'  step_date(date, features = c('quarter', 'semester', 'month', 'year')) 
#'
#'recipe_date_lag <- recipe_date %>% 
#'  step_lag(value, lag = 1) %>% 
#'  step_ts_impute(all_numeric(), period=365)
#'
#'prophet_boost <- prophet_boost(mode = 'regression') %>%
#'  set_engine("prophet_xgboost")
#'
#'mars <- mars(mode = 'regression') %>%
#'  set_engine('earth')
#'
#'wfsets <- workflow_set(
#'  preproc = list(
#'    R_date = recipe_date,
#'    R_date_lag = recipe_date_lag
#'  ),
#'  models  = list(
#'    M_prophet = prophet_boost, 
#'    M_mars = mars
#'  ),
#'  cross   = TRUE
#')
#'
#'wffits <- modeltime_wfs_fit(.wfsets = wfsets, 
#'                            .split_prop = 0.8, 
#'                            .serie=df)
#'wffits
modeltime_wfs_fit <- function(.wfsets, .split_prop, .serie) {
  list_models <- .wfsets %>% split(.$wflow_id)
  
  n <- length(list_models)
  pb <- dplyr::progress_estimated(n = n)
  
  # Fit models in splits
  table_wfsets <-
    purrr::map(list_models,
               function(.wf = .x,
                        .splits = rsample::initial_time_split(.serie, prop = .split_prop)) {
                 pb$tick()$print()
                 
                 cli::cli_h3(paste0('MODEL: ', .wf %>% dplyr::pull(wflow_id)))
                 
                 # If model can't be mapped with certain recipe: error. Ignore this:
                 tryCatch({
                   # Get workflow, fit and convert to modeltime_table
                   .model <- .wf %>%
                     dplyr::pull(info) %>%
                     purrr::pluck(1, 'workflow', 1) %>%
                     fit(.splits %>% rsample::training()) %>%
                     modeltime::modeltime_table()
                   
                   cli::cli_alert_success('Training finished OK.')
                   
                   # Generate modeltime_accuracy metrics
                   .models_table <- .model %>%
                     modeltime::modeltime_accuracy(new_data = .splits %>% rsample::testing())
                   
                   # Include a column with the fitted model
                   .models_table <- .models_table %>%
                     dplyr::mutate(.fit_model = list(.model))
                   
                   .models_table
                   
                 }, error = function(x) {
                   cli::cli_alert_warning(paste0(
                     "Warninng: the model raised an error,it will be ignored \n", x))
                   NULL
                 })
               })
  
  # Convert lists to table:
  table_wfsets <- dplyr::bind_rows(table_wfsets, .id = ".model_id")
  cli::cat_line()
  cli::cli_h1(paste0(nrow(table_wfsets), ' models fitted ', cli::symbol$heart))
  cli::cli_h2(paste0(
    length(list_models) - nrow(table_wfsets),
    ' models deleted ',
    cli::symbol$cross
  ))
  return(table_wfsets)
}







