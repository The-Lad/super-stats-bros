source('load_app_data.R')
library(caret)

# No way to model Pokemon Trainer
char_data <- char_stats %>% 
  select(character, all_plot_vars) %>% 
  mutate_if(is.numeric, function(x) {x[which(.$character == 'Ice Climbers' & is.na(x))] = x[which(.$character == 'Popo')]; x}) %>% 
  filter(!character %in% c('Squirtle', 'Charizard', 'Ivysaur', 'Pokemon Trainer', 'Popo', 'Nana', 'Byleth')) 

# USAGE
usage_model_data =  select(char_data, -c(character, games_lost, games_won))
run_once = FALSE
if (run_once == TRUE) {
  set.seed(37)
  test_inds = sample(1:nrow(usage_model_data), 10)
  test_usage = usage_model_data[test_inds, ]
  train_usage = usage_model_data[-test_inds, ]
  
  usage.lm = lm(usage ~ ., data = usage_model_data %>%  select(-initial_dash) )
  #summary(usage.lm)
  #anova(usage.lm)
  
  usage.rf = train(usage ~ ., data = train_usage %>%  select(-initial_dash), 
                   method = 'ranger',
                   trControl = trainControl(method='cv', number = 5, verboseIter = FALSE),
                   tuneGrid = expand.grid(
                     #num.trees = c(200, 500, 1000),
                     min.node.size = c(3, 5, 7, 9),
                     splitrule = 'extratrees',
                     mtry = 2:5),
                   preProcess = NULL
  )
  
  caret::RMSE(predict(usage.rf, test_usage), test_usage$usage)
  caret::RMSE(predict(usage.lm, test_usage), test_usage$usage)
  
  caret::R2(predict(usage.rf, test_usage), test_usage$usage)
  caret::R2(predict(usage.lm, test_usage), test_usage$usage)
  
} else {
  usage_rmse <- list(lm = NULL, rf = NULL)
  usage_r2 <- list(lm = NULL, rf = NULL)
  all_tuning <- list()
  for (i in 1:10) {
    test_inds = sample(1:nrow(usage_model_data), 10)
    test_usage = usage_model_data[test_inds, ]
    train_usage = usage_model_data[-test_inds, ]
    
    usage.lm = lm(usage ~ ., data = train_usage %>%  select(-initial_dash))
    #summary(usage.lm)
    #anova(usage.lm)
    
    usage.rf = train(usage ~ ., data = train_usage %>%  select(-initial_dash), 
                     method = 'ranger',
                     trControl = trainControl(method='cv', number = 5, verboseIter = FALSE),
                     tuneGrid = expand.grid(
                       #num.trees = c(200, 500, 1000),
                       #num.random.splits = 1:5,
                       min.node.size = c(5, 7, 9), # 3 is bad
                       splitrule = c('extratrees', 'variance', 'maxstat', 'beta'),
                       mtry = 3:5), # 2 is bad
                     preProcess = NULL
    )
    
    usage_rmse[['rf']][i] = RMSE(predict(usage.rf, test_usage), test_usage$usage)
    usage_rmse[['lm']][i] = RMSE(predict(usage.lm, test_usage), test_usage$usage)
    
    usage_r2[['rf']][i] = R2(predict(usage.rf, test_usage), test_usage$usage)
    usage_r2[['lm']][i] =  R2(predict(usage.lm, test_usage), test_usage$usage)
    
    all_tuning[[i]] <- usage.rf$results
    print(paste(i, '/10 loops done!'))
  }
  ten_build_metrics <- tibble(models = names(usage_rmse), mean_rmse = sapply(usage_rmse, mean), median_rmse = sapply(usage_rmse, median), mean_r2 = sapply(usage_r2, mean), median_r2= sapply(usage_r2, median))
  best_rf_params_rmse = all_tuning %>% bind_rows() %>% group_by(min.node.size, splitrule, mtry) %>% summarise_all(mean) %>% ungroup() %>%  select(min.node.size, splitrule, mtry, RMSE) %>%  filter(RMSE == min(RMSE))
  best_rf_params_r2 = all_tuning %>% bind_rows() %>% group_by(min.node.size, splitrule, mtry) %>% summarise_all(mean) %>% ungroup() %>% select(min.node.size, splitrule, mtry, Rsquared) %>%  filter(Rsquared == max(Rsquared))
  
}

# Tune for extrarules.9 extratrees 5 is best.
usage_best_rmse = list('1' = NULL, '2' = NULL, '3' = NULL, '4' = NULL, '5' = NULL)
usage_best_r2 = list('1' = NULL, '2' = NULL, '3' = NULL, '4' = NULL, '5' = NULL)
best_min_node_size = best_rf_params_r2$min.node.size
best_splitrule = best_rf_params_r2$splitrule
best_mtry = best_rf_params_r2$mtry
for (i in 1:10) {
  for (num_split in 1:5) {
    test_inds = sample(1:nrow(usage_model_data), 10)
    test_usage = usage_model_data[test_inds, ]
    train_usage = usage_model_data[-test_inds, ]
    
    usage.rf = train(usage ~ ., data = train_usage %>%  select(-initial_dash), 
                     method = 'ranger',
                     trControl = trainControl(method='cv', number = 5, verboseIter = FALSE),
                     tuneGrid = expand.grid(min.node.size = best_min_node_size,
                                            splitrule = best_splitrule,
                                            mtry = best_mtry),
                     num.random.splits = num_split,
                     preProcess = NULL
    )
    usage_best_rmse[[as.character(num_split)]][i] = RMSE(predict(usage.rf, test_usage), test_usage$usage)
    usage_best_r2[[as.character(num_split)]][i] = R2(predict(usage.rf, test_usage), test_usage$usage)
  }
}

tibble(num_splits = names(usage_best_r2), mean_rmse = sapply(usage_best_rmse, mean), median_rmse = sapply(usage_best_rmse, median), mean_r2 = sapply(usage_best_r2, mean), median_r2= sapply(usage_best_r2, median))

# 1 appears to be the best
usage.rf = train(usage ~ ., data = usage_model_data %>%  select(-initial_dash), 
                 method = 'ranger',
                 trControl = trainControl(method='cv', number = 5, verboseIter = FALSE),
                 tuneGrid = expand.grid(min.node.size = best_min_node_size,
                                        splitrule = best_splitrule,
                                        mtry = best_mtry),
                 num.random.splits = 1,
                 preProcess = NULL
)

