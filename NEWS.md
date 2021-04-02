# sknifedatar 0.0.0.9001 (2021-04-02)

## Major changes

* `multieval` no longer generates a graph for calculated metrics.

* `mlapply` was removed, a reduced version is included internally within the `multieval` function.

* `pertenencia_punto` was removed.

* removed dependency on `stringr`, `stringi`, `yardstick`, `ggplot2` and `parallel` packages.

## Bug fixes

* `modeltime_multibestmode` corrected a detail in the code that was not selecting the best models correctly.

## Minor changes

* multieval change from "metric"" parameter to ".metrics".

# sknifedatar 0.0.0.9000 (2021-03-28) 

* Added a `NEWS.md` file to track changes to the package.