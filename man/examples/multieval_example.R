set.seed(123)
predictions =
  data.frame(truth = runif(100),
             predict_model_1 = rnorm(100, mean = 1,sd =2),
             predict_model_2 = rnorm(100, mean = 0,sd =2))

multieval(data = predictions,
          observed = "truth",
          predictions = c("predict_model_1","predict_model_2"),
          metrica = list(rmse = yardstick::rmse,
                         rsq = yardstick::rsq,
                         mae = yardstick::mae))

# Output ----------------------
#  A tibble: 6 x 4
#  .metric .estimator .estimate model
#  <chr>   <chr>          <dbl> <chr>
#1 mae     standard    1.59     predict_model1
#2 mae     standard    1.61     predict_model2
#3 rmse    standard    1.99     predict_model1
#4 rmse    standard    1.95     predict_model2
#5 rsq     standard    0.000704 predict_model1
#6 rsq     standard    0.00115  predict_model2


# Alternativa utilizando "erer::listn" en lugar de
# "list" para pasar las méticas como argumentos
#
# install.packages("erer")
#
# multieval(data = predictions,
#          observed = "truth",
#          predictions = c("predict_model1","predict_model2"),
#          metrica = erer::listn(rmse, rsq, mae))
