# sknifedatar 0.0.0.9003 (development version)

# sknifedatar 0.0.0.9002 (2021-05-16)

## Major changes

* create `automagic_tabs2` to include more outputs in tabsets

* removed dependency on `xaringanExtra::use_panelset` before call `automagic_tabs` for html_document output.

* 'workflowsets' compatibility with 'modeltime' by creating `modeltime_wfs_bestmodel` , `modeltime_wfs_fit` , `modeltime_wfs_forecast` , `modeltime_wfs_rank` , `modeltime_wfs_refit` functions.

* 'workflowsets' compatibility with 'modeltime', allows to adjust a workflow set over multiple time series by means of the `modeltime_wfs_multibestmodel` , `modeltime_wfs_multifit` , `modeltime_wfs_multiforecast` , `modeltime_wfs_multirefit` functions.

## Bug fixes

* `modeltime_multifit` corrected a name of nested serie column.


# sknifedatar 0.0.0.9001 (2021-04-02)

## Major changes

* `multieval` no longer generates a graph for calculated metrics.

* `mlapply` was removed, a reduced version is included internally within the `multieval` function.

* `pertenencia_punto` was removed.

* removed dependency on `stringr`, `stringi`, `yardstick`, `ggplot2` and `parallel` packages.

## Bug fixes

* `modeltime_multibestmodel` corrected a detail in the code that was not selecting the best models correctly.


# sknifedatar 0.0.0.9000 (2021-03-28) 

* Added a `NEWS.md` file to track changes to the package.