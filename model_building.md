model\_building
================

Load in the data and divide into training and testing
    sets

``` r
library(caret)
```

    ## Loading required package: lattice

    ## Loading required package: ggplot2

``` r
library(tidyverse)
```

    ## ── Attaching packages ──────────────────────────────────────────────────────────────────────────────────── tidyverse 1.3.0 ──

    ## ✓ tibble  3.0.1     ✓ dplyr   1.0.2
    ## ✓ tidyr   1.1.0     ✓ stringr 1.4.0
    ## ✓ readr   1.3.1     ✓ forcats 0.5.0
    ## ✓ purrr   0.3.4

    ## ── Conflicts ─────────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()
    ## x purrr::lift()   masks caret::lift()

``` r
library(ROCR)

datacomplete = read_csv("./shiny/data/datacomplete.csv") %>%
  mutate_at(c("admitted", "ethnicity_race", "asthma", "diabetes", "gender"), as.factor) %>%
  select(admitted, age, gender, ses, bmi_value, systolic_bp_value, ethnicity_race, asthma, diabetes)
```

    ## Parsed with column specification:
    ## cols(
    ##   .default = col_double(),
    ##   admitted = col_character(),
    ##   gender = col_character(),
    ##   eventdatetime = col_character(),
    ##   icu_date_time = col_character(),
    ##   ethnicity_race = col_character(),
    ##   service = col_character(),
    ##   admission_dx = col_character(),
    ##   city = col_character()
    ## )

    ## See spec(...) for full column specifications.

``` r
train_data = 
  datacomplete %>%
  slice(1:250) 

test_data = 
  datacomplete %>%
  slice(251:375)
```

Random forest model

``` r
myFolds = createFolds(train_data$admitted, k = 5)
rfControl = trainControl(
    summaryFunction = twoClassSummary,
    classProbs = TRUE, 
    verboseIter = TRUE,
    savePredictions = TRUE,
    index = myFolds
)
  
rfmodel = caret::train(
    admitted ~., 
    data = train_data,
    metric = "ROC",
    method = "ranger",
    trControl = rfControl
 )
```

    ## + Fold1: mtry= 2, min.node.size=1, splitrule=gini 
    ## - Fold1: mtry= 2, min.node.size=1, splitrule=gini 
    ## + Fold1: mtry= 7, min.node.size=1, splitrule=gini 
    ## - Fold1: mtry= 7, min.node.size=1, splitrule=gini 
    ## + Fold1: mtry=12, min.node.size=1, splitrule=gini 
    ## - Fold1: mtry=12, min.node.size=1, splitrule=gini 
    ## + Fold1: mtry= 2, min.node.size=1, splitrule=extratrees 
    ## - Fold1: mtry= 2, min.node.size=1, splitrule=extratrees 
    ## + Fold1: mtry= 7, min.node.size=1, splitrule=extratrees 
    ## - Fold1: mtry= 7, min.node.size=1, splitrule=extratrees 
    ## + Fold1: mtry=12, min.node.size=1, splitrule=extratrees 
    ## - Fold1: mtry=12, min.node.size=1, splitrule=extratrees 
    ## + Fold2: mtry= 2, min.node.size=1, splitrule=gini 
    ## - Fold2: mtry= 2, min.node.size=1, splitrule=gini 
    ## + Fold2: mtry= 7, min.node.size=1, splitrule=gini 
    ## - Fold2: mtry= 7, min.node.size=1, splitrule=gini 
    ## + Fold2: mtry=12, min.node.size=1, splitrule=gini 
    ## - Fold2: mtry=12, min.node.size=1, splitrule=gini 
    ## + Fold2: mtry= 2, min.node.size=1, splitrule=extratrees 
    ## - Fold2: mtry= 2, min.node.size=1, splitrule=extratrees 
    ## + Fold2: mtry= 7, min.node.size=1, splitrule=extratrees 
    ## - Fold2: mtry= 7, min.node.size=1, splitrule=extratrees 
    ## + Fold2: mtry=12, min.node.size=1, splitrule=extratrees 
    ## - Fold2: mtry=12, min.node.size=1, splitrule=extratrees 
    ## + Fold3: mtry= 2, min.node.size=1, splitrule=gini 
    ## - Fold3: mtry= 2, min.node.size=1, splitrule=gini 
    ## + Fold3: mtry= 7, min.node.size=1, splitrule=gini 
    ## - Fold3: mtry= 7, min.node.size=1, splitrule=gini 
    ## + Fold3: mtry=12, min.node.size=1, splitrule=gini 
    ## - Fold3: mtry=12, min.node.size=1, splitrule=gini 
    ## + Fold3: mtry= 2, min.node.size=1, splitrule=extratrees 
    ## - Fold3: mtry= 2, min.node.size=1, splitrule=extratrees 
    ## + Fold3: mtry= 7, min.node.size=1, splitrule=extratrees 
    ## - Fold3: mtry= 7, min.node.size=1, splitrule=extratrees 
    ## + Fold3: mtry=12, min.node.size=1, splitrule=extratrees 
    ## - Fold3: mtry=12, min.node.size=1, splitrule=extratrees 
    ## + Fold4: mtry= 2, min.node.size=1, splitrule=gini 
    ## - Fold4: mtry= 2, min.node.size=1, splitrule=gini 
    ## + Fold4: mtry= 7, min.node.size=1, splitrule=gini 
    ## - Fold4: mtry= 7, min.node.size=1, splitrule=gini 
    ## + Fold4: mtry=12, min.node.size=1, splitrule=gini 
    ## - Fold4: mtry=12, min.node.size=1, splitrule=gini 
    ## + Fold4: mtry= 2, min.node.size=1, splitrule=extratrees 
    ## - Fold4: mtry= 2, min.node.size=1, splitrule=extratrees 
    ## + Fold4: mtry= 7, min.node.size=1, splitrule=extratrees 
    ## - Fold4: mtry= 7, min.node.size=1, splitrule=extratrees 
    ## + Fold4: mtry=12, min.node.size=1, splitrule=extratrees 
    ## - Fold4: mtry=12, min.node.size=1, splitrule=extratrees 
    ## + Fold5: mtry= 2, min.node.size=1, splitrule=gini 
    ## - Fold5: mtry= 2, min.node.size=1, splitrule=gini 
    ## + Fold5: mtry= 7, min.node.size=1, splitrule=gini 
    ## - Fold5: mtry= 7, min.node.size=1, splitrule=gini 
    ## + Fold5: mtry=12, min.node.size=1, splitrule=gini 
    ## - Fold5: mtry=12, min.node.size=1, splitrule=gini 
    ## + Fold5: mtry= 2, min.node.size=1, splitrule=extratrees 
    ## - Fold5: mtry= 2, min.node.size=1, splitrule=extratrees 
    ## + Fold5: mtry= 7, min.node.size=1, splitrule=extratrees 
    ## - Fold5: mtry= 7, min.node.size=1, splitrule=extratrees 
    ## + Fold5: mtry=12, min.node.size=1, splitrule=extratrees 
    ## - Fold5: mtry=12, min.node.size=1, splitrule=extratrees 
    ## Aggregating results
    ## Selecting tuning parameters
    ## Fitting mtry = 12, splitrule = extratrees, min.node.size = 1 on full training set

``` r
pred_rf = predict(rfmodel,test_data,type="prob")
pred_rf = pred_rf$yes
auc_rf = as.numeric(ROCR::performance(prediction(pred_rf,test_data$admitted),"auc")@y.values)
auc_rf
```

    ## [1] 0.6574022

GLM net model

``` r
glmnetControl = trainControl(
    method = "cv", 
    number = 10,
    summaryFunction = twoClassSummary,
    classProbs = TRUE, 
    verboseIter = TRUE
)

glmnetmodel = caret::train(
    admitted ~. , 
    data=train_data,
    tuneGrid = expand.grid(
      alpha=0:1,
      lambda=seq(0.0001,1, length=20)
    ),
    method = "glmnet",
    trControl = glmnetControl,
    preProcess= c("center","scale")
  )
```

    ## Warning in train.default(x, y, weights = w, ...): The metric "Accuracy" was not
    ## in the result set. ROC will be used instead.

    ## + Fold01: alpha=0, lambda=1 
    ## - Fold01: alpha=0, lambda=1 
    ## + Fold01: alpha=1, lambda=1 
    ## - Fold01: alpha=1, lambda=1 
    ## + Fold02: alpha=0, lambda=1 
    ## - Fold02: alpha=0, lambda=1 
    ## + Fold02: alpha=1, lambda=1 
    ## - Fold02: alpha=1, lambda=1 
    ## + Fold03: alpha=0, lambda=1 
    ## - Fold03: alpha=0, lambda=1 
    ## + Fold03: alpha=1, lambda=1 
    ## - Fold03: alpha=1, lambda=1 
    ## + Fold04: alpha=0, lambda=1 
    ## - Fold04: alpha=0, lambda=1 
    ## + Fold04: alpha=1, lambda=1 
    ## - Fold04: alpha=1, lambda=1 
    ## + Fold05: alpha=0, lambda=1 
    ## - Fold05: alpha=0, lambda=1 
    ## + Fold05: alpha=1, lambda=1 
    ## - Fold05: alpha=1, lambda=1 
    ## + Fold06: alpha=0, lambda=1 
    ## - Fold06: alpha=0, lambda=1 
    ## + Fold06: alpha=1, lambda=1 
    ## - Fold06: alpha=1, lambda=1 
    ## + Fold07: alpha=0, lambda=1 
    ## - Fold07: alpha=0, lambda=1 
    ## + Fold07: alpha=1, lambda=1 
    ## - Fold07: alpha=1, lambda=1 
    ## + Fold08: alpha=0, lambda=1 
    ## - Fold08: alpha=0, lambda=1 
    ## + Fold08: alpha=1, lambda=1 
    ## - Fold08: alpha=1, lambda=1 
    ## + Fold09: alpha=0, lambda=1 
    ## - Fold09: alpha=0, lambda=1 
    ## + Fold09: alpha=1, lambda=1 
    ## - Fold09: alpha=1, lambda=1 
    ## + Fold10: alpha=0, lambda=1 
    ## - Fold10: alpha=0, lambda=1 
    ## + Fold10: alpha=1, lambda=1 
    ## - Fold10: alpha=1, lambda=1 
    ## Aggregating results
    ## Selecting tuning parameters
    ## Fitting alpha = 1, lambda = 0.0527 on full training set

``` r
pred_glmnet = predict(glmnetmodel,test_data,type="prob") 
pred_glmnet = pred_glmnet$yes
auc_glmnet = as.numeric(ROCR::performance(prediction(pred_glmnet,test_data$admitted),"auc")@y.values)
auc_glmnet
```

    ## [1] 0.6202496

XGB model

``` r
xgbTrainingControl = trainControl(method = "CV", 
                                     number = 5, 
                                     savePredictions = TRUE, 
                                     classProbs = TRUE, 
                                     summaryFunction = twoClassSummary,
                                     verboseIter = F)
nrounds = 1000
  
xgb_grid = expand.grid(
    nrounds = seq(from = 200, to = nrounds, by = 50),
    eta = c(0.025, 0.05, 0.1, 0.3),
    max_depth = c(2, 3, 4, 5, 6),
    gamma = 0,
    colsample_bytree = 1,
    min_child_weight = 1,
    subsample = 1
)
  
fit_xgb = caret::train(admitted~., 
                         data = train_data, 
                         metric = "ROC",
                         method = "xgbTree", 
                         tuneGrid = xgb_grid,
                         trControl = xgbTrainingControl)
  
pred_xgb = predict(fit_xgb,test_data,type="prob")
pred_xgb = pred_xgb$yes
auc_xgb = as.numeric(ROCR::performance(ROCR::prediction(pred_xgb,test_data$admitted),"auc")@y.values)
auc_xgb
```

    ## [1] 0.6145774

SPLS model

``` r
#SPLS
train_grid = expand.grid(K =c(3,4,5,6,7,8,9),eta =c(0.35,0.4,0.45,0.5,0.55,0.6,0.7,0.8,0.9),
                          kappa=0.5)

plsFit =caret::train(admitted~.,
                         data = train_data,
                         method = "spls",
                         tuneGrid = train_grid,
                         trControl = xgbTrainingControl,
                         metric = "ROC")
```

    ## Registered S3 methods overwritten by 'spls':
    ##   method         from 
    ##   predict.splsda caret
    ##   print.splsda   caret

``` r
pred_plsda = predict(plsFit,test_data,type="prob")
pred_plsda = pred_plsda$yes
auc_plsda = as.numeric(ROCR::performance(prediction(pred_plsda,test_data$admitted),"auc")@y.values)
auc_plsda
```

    ## [1] 0.6435054
