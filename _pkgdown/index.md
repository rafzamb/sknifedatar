
# **sknifedatar** 📦 “Swiss Knife of Data for R” <img src="man/figures/logo.png" align="right" height="139" />

<!-- badges: start -->

[![made-with-R](https://img.shields.io/badge/Made%20with-R-1f425f.svg)](https://www.r-project.org/)
[![GitHub
license](https://img.shields.io/github/license/Naereen/StrapDown.js.svg)](https://github.com/rafzamb/sknifedatar/blob/master/LICENSE)
<!-- badges: end -->

**sknifedatar** is a package that serves primarily as an extension to
the [modeltime](https://business-science.github.io/modeltime/) 📦
ecosystem. In addition, it includes some functionalities for spatial
data and visualization.

## Installation

Not on CRAN yet.

``` r
#install.packages("sknifedatar")
```

Or install the development version from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("rafzamb/sknifedatar")
```

### Multiple models on multiple series functions 📈

<img src="man/figures/diagrama_resumen.png" width="100%" style="display: block; margin: auto;" />

#### modeltime\_multifit

Esta funcion permite ajusatr multiples mdoelos sobre multiples series de
tiempo, utilizando los modelos del paquete
[modeltime](https://business-science.github.io/modeltime/).

``` r
 # libraries
 library(modeltime)
 library(rsample)
 library(parsnip)
 library(recipes)
 library(workflows)
 library(dplyr)
 library(tidyr)
 library(sknifedatar)
```

``` r
# Data
 data("emae_series")
 nested_serie = emae_series %>% filter(date < '2020-02-01') %>% nest(nested_column=-sector)

 # Recipes
 recipe_1 = recipe(value ~ ., data = emae_series %>% select(-sector)) %>%
 step_date(date, features = c("month", "quarter", "year"), ordinal = TRUE)

 # Models
 m_auto_arima <- arima_reg() %>% set_engine('auto_arima')

 m_stlm_arima <- seasonal_reg() %>%
   set_engine("stlm_arima")

 m_nnetar <- workflow() %>%
   add_recipe(recipe_1) %>%
   add_model(nnetar_reg() %>% set_engine("nnetar"))

 # modeltime_multifit
 model_table_emae = modeltime_multifit(serie = nested_serie %>% head(3),
                                       .prop = 0.8,
                                       m_auto_arima,
                                       m_stlm_arima,
                                       m_nnetar)

 model_table_emae
#> $table_time
#> # A tibble: 3 x 7
#>   sector       nested_column   m_auto_arima m_stlm_arima m_nnetar nested_model  
#>   <chr>        <list>          <list>       <list>       <list>   <list>        
#> 1 Comercio     <tibble [193 ×… <fit[+]>     <fit[+]>     <workfl… <model_time […
#> 2 Enseñanza    <tibble [193 ×… <fit[+]>     <fit[+]>     <workfl… <model_time […
#> 3 Administrac… <tibble [193 ×… <fit[+]>     <fit[+]>     <workfl… <model_time […
#> # … with 1 more variable: calibration <list>
#> 
#> $models_accuracy
#> # A tibble: 9 x 10
#>   name_serie  .model_id .model_desc  .type   mae  mape   mase smape  rmse    rsq
#>   <chr>           <int> <chr>        <chr> <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl>
#> 1 Comercio            1 ARIMA(0,1,1… Test   8.54  5.55  0.656  5.69 10.7  0.588 
#> 2 Comercio            2 SEASONAL DE… Test   9.33  6.28  0.717  6.24 11.2  0.415 
#> 3 Comercio            3 NNAR(1,1,10… Test   9.17  6.12  0.705  6.16 11.0  0.464 
#> 4 Enseñanza           1 ARIMA(1,1,1… Test   5.38  3.35  3.90   3.28  6.00 0.730 
#> 5 Enseñanza           2 SEASONAL DE… Test   5.56  3.46  4.03   3.38  6.21 0.726 
#> 6 Enseñanza           3 NNAR(1,1,10… Test   2.96  1.84  2.15   1.82  3.26 0.902 
#> 7 Administra…         1 ARIMA(0,1,1… Test   6.10  3.96 12.6    3.86  7.05 0.0384
#> 8 Administra…         2 SEASONAL DE… Test   6.45  4.19 13.4    4.07  7.61 0.0480
#> 9 Administra…         3 NNAR(1,1,10… Test   6.40  4.16 13.3    4.06  7.04 0.0581
```

#### modeltime\_multiforecast

Esta funcion permite ralizar un forecating sobre multiples series de
tiempo a partir de multiples modelos entrenados.

``` r
data("table_time")
forecast_emae <- modeltime_multiforecast(table_time,
                                        .prop=0.8)

forecast_emae
#> # A tibble: 3 x 8
#>   sector       nested_column   m_auto_arima m_stlm_arima m_nnetar nested_model  
#>   <chr>        <list>          <list>       <list>       <list>   <list>        
#> 1 Comercio     <tibble [193 ×… <fit[+]>     <fit[+]>     <workfl… <model_time […
#> 2 Enseñanza    <tibble [193 ×… <fit[+]>     <fit[+]>     <workfl… <model_time […
#> 3 Administrac… <tibble [193 ×… <fit[+]>     <fit[+]>     <workfl… <model_time […
#> # … with 2 more variables: calibration <list>, nested_forecast <list>
```

#### modeltime\_multirefit

Esta función permite aplicar la función “**modeltime\_refit**” de
[modeltime](https://business-science.github.io/modeltime/) a múltiples
series y modelos.

``` r
data("table_time")
table_time_refit <- modeltime_multirefit(models_table = table_time)

table_time_refit
#> # A tibble: 3 x 7
#>   sector       nested_column   m_auto_arima m_stlm_arima m_nnetar nested_model  
#>   <chr>        <list>          <list>       <list>       <list>   <list>        
#> 1 Comercio     <tibble [193 ×… <fit[+]>     <fit[+]>     <workfl… <model_time […
#> 2 Enseñanza    <tibble [193 ×… <fit[+]>     <fit[+]>     <workfl… <model_time […
#> 3 Administrac… <tibble [193 ×… <fit[+]>     <fit[+]>     <workfl… <model_time […
#> # … with 1 more variable: calibration <list>
```

#### modeltime\_multibestmodel

Esta función permite seleccionar el mejor modelo para cada serie, en
función de determinada métrica de evaluación.

``` r
data("table_time")

best_model_emae <- modeltime_multibestmodel(.table=table_time,
                                           .metric=rmse,
                                           .optimization = which.min)

best_model_emae
#> # A tibble: 3 x 8
#>   sector       nested_column   m_auto_arima m_stlm_arima m_nnetar nested_model  
#>   <chr>        <list>          <list>       <list>       <list>   <list>        
#> 1 Comercio     <tibble [193 ×… <fit[+]>     <fit[+]>     <workfl… <model_time […
#> 2 Enseñanza    <tibble [193 ×… <fit[+]>     <fit[+]>     <workfl… <model_time […
#> 3 Administrac… <tibble [193 ×… <fit[+]>     <fit[+]>     <workfl… <model_time […
#> # … with 2 more variables: calibration <list>, best_model <list>
```

### Other functions 🌀

#### Función multieval

Para un conjunto de predicciones de distintos modelos, permite evaluar
múltiples métricas y devolver los resultados en un formato tabular que
facilita la comparación de las predicciones.

``` r
library(yardstick)
library(erer)

set.seed(123)
predictions =
  data.frame(truth = runif(100),
             predict_model_1 = rnorm(100, mean = 1,sd =2),
             predict_model_2 = rnorm(100, mean = 0,sd =2))

tibble(predictions)
#> # A tibble: 100 x 3
#>     truth predict_model_1 predict_model_2
#>     <dbl>           <dbl>           <dbl>
#>  1 0.288            1.51            1.58 
#>  2 0.788            0.943           1.54 
#>  3 0.409            0.914           0.664
#>  4 0.883            3.74           -2.02 
#>  5 0.940            0.548          -0.239
#>  6 0.0456           4.03           -0.561
#>  7 0.528           -2.10            1.13 
#>  8 0.892            2.17           -0.745
#>  9 0.551            1.25            1.95 
#> 10 0.457            1.43           -0.749
#> # … with 90 more rows
```

``` r
multieval(data = predictions,
          observed = "truth",
          predictions = c("predict_model_1","predict_model_2"),
          metrica = listn(rmse, rsq, mae))
#> $table_values
#> # A tibble: 6 x 4
#>   .metric .estimator .estimate model          
#>   <chr>   <chr>          <dbl> <chr>          
#> 1 mae     standard    1.59     predict_model_1
#> 2 mae     standard    1.61     predict_model_2
#> 3 rmse    standard    1.99     predict_model_1
#> 4 rmse    standard    1.95     predict_model_2
#> 5 rsq     standard    0.000704 predict_model_1
#> 6 rsq     standard    0.00115  predict_model_2
#> 
#> $summary_table
#> # A tibble: 2 x 4
#>   model             mae  rmse      rsq
#>   <chr>           <dbl> <dbl>    <dbl>
#> 1 predict_model_1  1.59  1.99 0.000704
#> 2 predict_model_2  1.61  1.95 0.00115 
#> 
#> $plot_metrics
```

<img src="man/figures/README-unnamed-chunk-10-1.png" width="100%" />

#### Función pertenencia\_punto

Dado dos conjuntos de puntos geolocalizados, esta función permite
determinar para cada punto del primer conjunto de datos, cuál o cuáles
de los puntos del segundo conjunto de datos están dentro de un radio de
metros determinado.

-   Muestra de 100 crimenes ocurridos en CABA.

``` r
head(crimes)
#> # A tibble: 6 x 9
#>       id fecha      franja_horaria tipo_delito    subtipo_delito comuna barrio  
#>    <dbl> <date>              <dbl> <chr>          <chr>           <dbl> <chr>   
#> 1 341734 2018-08-29              0 Robo (con vio… <NA>                5 Boedo   
#> 2 257029 2018-09-17             15 Hurto (sin vi… <NA>                6 Caballi…
#> 3 307285 2018-03-16             18 Robo (con vio… <NA>               14 Palermo 
#> 4 314525 2018-02-12             12 Robo (con vio… <NA>                3 Balvane…
#> 5 347997 2018-06-15              9 Robo (con vio… <NA>                7 Parque …
#> 6 240042 2017-12-12             14 Robo (con vio… <NA>               13 Nuñez   
#> # … with 2 more variables: lat <dbl>, long <dbl>
```

-   2023 esquinas de CABA uniformemente distribuidas sobre la ciudad.

``` r
head(intercepcion_calles)
#>   id      long       lat
#> 1  1 -58.47533 -34.53936
#> 2  2 -58.49107 -34.54576
#> 3  3 -58.46640 -34.53487
#> 4  4 -58.49474 -34.54741
#> 5  5 -58.39515 -34.57223
#> 6  6 -58.38185 -34.59158
```

-   Para cada delito, se determina la esquina que está dentro de un
    radio de cercanía inferior a 150 metros.

``` r
esquina = data.frame(pertenencia_esquina = pertenencia_punto(data = crimes[1:10,], 
                                                             referencia = intercepcion_calles[1:300,],
                                                             metros = 150) %>% 
                       unlist())
```

-   Data frame con los delitos y sus esquinas de cercaria.

``` r
crimes[1:10,] %>% 
  select(id) %>% 
  bind_cols(esquina)
#> # A tibble: 10 x 2
#>        id pertenencia_esquina
#>  *  <dbl>               <dbl>
#>  1 341734                   0
#>  2 257029                   0
#>  3 307285                 241
#>  4 314525                   0
#>  5 347997                   0
#>  6 240042                   0
#>  7 420664                   0
#>  8 304656                   0
#>  9 253948                   0
#> 10 265219                   0
```

#### Función sliding\_window

Esta función permite aplicar una transformación de ventana deslizante
móvil mensual sobre un conjunto de datos. Se define el número de
pliegues y los tipos de variables a calcular. Para ver una explicación
detallada y un caso de uso de esta función con código R, consultar
[Predicción de ocurrencia de delitos /
sliding\_window](https://rafael-zambrano-blog-ds.netlify.app/posts/2020-12-22-prediccin-de-delitos-en-caba/#aplicaci%C3%B3n-de-ventanas-deslizantes).

``` r
pliegues = 1:13
names(pliegues) = pliegues

variables = c("delitos", "temperatura", "mm_agua", "lluvia", "viento")
names(variables) = variables

sliding_window(data = data_longer_crime %>% dplyr::select(-c(long,lat)),
               inicio = 13,
               pliegues = pliegues,
               variables = variables)
#> # A tibble: 26,299 x 32
#>    id     pliegue delitos_last_ye… delitos_last_12 delitos_last_6 delitos_last_3
#>    <chr>    <int>            <dbl>           <dbl>          <dbl>          <dbl>
#>  1 esqui…       1                1              73             41             20
#>  2 esqui…       1                5             106             47             19
#>  3 esqui…       1                4              25             11              4
#>  4 esqui…       1                0               4              1              1
#>  5 esqui…       1                0              31             16              7
#>  6 esqui…       1                1              11              6              3
#>  7 esqui…       1                1              16             11              4
#>  8 esqui…       1                1              19              8              5
#>  9 esqui…       1                0               9              6              4
#> 10 esqui…       1                3              27             14             10
#> # … with 26,289 more rows, and 26 more variables: delitos_last_1 <dbl>,
#> #   delitos <dbl>, temperatura_last_year <dbl>, temperatura_last_12 <dbl>,
#> #   temperatura_last_6 <dbl>, temperatura_last_3 <dbl>,
#> #   temperatura_last_1 <dbl>, temperatura <dbl>, mm_last_year <dbl>,
#> #   mm_last_12 <dbl>, mm_last_6 <dbl>, mm_last_3 <dbl>, mm_last_1 <dbl>,
#> #   mm <dbl>, dias_last_year <dbl>, dias_last_12 <dbl>, dias_last_6 <dbl>,
#> #   dias_last_3 <dbl>, dias_last_1 <dbl>, dias <dbl>, veloc_last_year <dbl>,
#> #   veloc_last_12 <dbl>, veloc_last_6 <dbl>, veloc_last_3 <dbl>,
#> #   veloc_last_1 <dbl>, veloc <dbl>
```

#### Función insert\_na

Esta función permite agregar valores NA a un data frame, pudiendo
seleccionar las columnas y la propòrcion de NAs deseados.

``` r
insert_na(data = iris, columnas = c("Sepal.Length","Petal.Length"), p = 0.25)
#> # A tibble: 150 x 5
#>    Sepal.Width Petal.Width Species Sepal.Length Petal.Length
#>          <dbl>       <dbl> <fct>          <dbl>        <dbl>
#>  1         3.5         0.2 setosa           5.1         NA  
#>  2         3           0.2 setosa          NA            1.4
#>  3         3.2         0.2 setosa           4.7          1.3
#>  4         3.1         0.2 setosa          NA            1.5
#>  5         3.6         0.2 setosa          NA            1.4
#>  6         3.9         0.4 setosa           5.4          1.7
#>  7         3.4         0.3 setosa           4.6          1.4
#>  8         3.4         0.2 setosa          NA            1.5
#>  9         2.9         0.2 setosa           4.4          1.4
#> 10         3.1         0.1 setosa           4.9          1.5
#> # … with 140 more rows
```

## Use cases

To consult projects where this package was used, visit:

-   [Blog Posts / Rafael
    Zambrano](https://rafael-zambrano-blog-ds.netlify.app/blog.html)
-   [Blog Posts / Karina
    Bartolome](https://karbartolome-blog.netlify.app/)
