set.seed(123)
library(yardstick) # métricas
library(erer) # función listn

predictions <-
  data.frame(truth = runif(100),
             predict_model_1 = rnorm(100, mean = 1,sd =2),
             predict_model_2 = rnorm(100, mean = 0,sd =2),
             predict_model_3 = rnorm(100, mean = 0,sd =3))

multieval(.dataset = predictions,
          .observed = "truth",
          .predictions = c("predict_model_1","predict_model_2","predict_model_3"),
          .metrics = listn(rmse, rsq, mae),
          value_table = TRUE)

# Output ----------------------
# A tibble: 9 x 4
# .metric .estimator .estimate model
# <chr>   <chr>          <dbl> <chr>
#   1 mae     standard     1.45    predict_model_1
# 2 mae     standard     1.67    predict_model_2
# 3 mae     standard     2.43    predict_model_3
# 4 rmse    standard     1.78    predict_model_1
# 5 rmse    standard     2.11    predict_model_2
# 6 rmse    standard     3.01    predict_model_3
# 7 rsq     standard     0.00203 predict_model_1
# 8 rsq     standard     0.0158  predict_model_2
# 9 rsq     standard     0.00254 predict_model_3

#$summary_table
# A tibble: 3 x 4
#  model             mae  rmse     rsq
#  <chr>           <dbl> <dbl>   <dbl>
#  1 predict_model_1  1.45  1.78 0.00203
#  2 predict_model_2  1.67  2.11 0.0158
#  3 predict_model_3  2.43  3.01 0.00254
