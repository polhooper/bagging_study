import pandas as pd 
import numpy as np 
from sklearn.ensemble import BaggingRegressor, BaggingClassifier, RandomForestRegressor
from sklearn.linear_model import LinearRegression, LogisticRegression

train = pd.read_csv('train.csv')
test = pd.read_csv('test.csv')
feature_list = open('use_these_vars.txt', 'rb')
features = feature_list.read().splitlines()

def write_function(preds, fname):
    with open(fname, 'wb') as writer: 
        for item in preds:
            writer.write("%s\n" % item )

def second_pos_clip(ls):
    out = [x[1] for x in ls]
    return(out)

log = LogisticRegression(solver = 'sag')
lm = LinearRegression()
rf = RandomForestRegressor(
  n_estimators = 500, 
  max_features = 0.33, 
  min_samples_leaf = 1000, 
  n_jobs = -1)
lm_bagged = BaggingRegressor(
  base_estimator = lm, 
  n_estimators = 250, 
  max_samples = 0.5, 
  max_features = 0.25,
  bootstrap = True, 
  oob_score = False, 
  warm_start = False, 
  n_jobs = -1
)
log_bagged = BaggingClassifier(
  base_estimator = log, 
  n_estimators = 250, 
  max_samples = 0.5, 
  max_features = 0.75,
  bootstrap = True, 
  oob_score = False, 
  warm_start = False, 
  n_jobs = -1
)

print('fitting logistic model')
log.fit(X = train[features], y = train['y'])

print('fitting linear model')
lm.fit(X = train[features], y = train['y'])

print('fitting random forest model')
rf.fit(X = train[features], y = train['y'])

print('fitting bagged lm regressor')
lm_bagged.fit(X = train[features], y = train['y'])

print('fitting bagged log regressor')
log_bagged.fit(X = train[features], y = train['y'])

lm_preds = lm.predict(X = test[features])
log_preds = log.predict_proba(X = test[features])
rf_preds = rf.predict(X = test[features])
lm_bagged_preds = lm_bagged.predict(X = test[features])
log_bagged_preds = log_bagged.predict_proba(X = test[features])

write_function(test['y'], 'truths.txt')
write_function(lm_preds, 'lm_preds.txt')
write_function(second_pos_clip(log_preds), 'log_preds.txt')
write_function(rf_preds, 'rf_preds.txt')
write_function(lm_bagged_preds, 'lm_bagged_preds.txt')
write_function(second_pos_clip(log_bagged_preds), 'log_bagged_preds.txt')
