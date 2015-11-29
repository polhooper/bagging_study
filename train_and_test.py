import pandas as pd 
from sklearn.ensemble import BaggingRegressor
from sklearn.ensemble import BaggingClassifier
from sklearn.linear_model import LinearRegression
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestRegressor

train = pd.read_csv('train.csv')
test = pd.read_csv('test.csv')
feature_names = [x for x in train.columns.values if not x in ['y', 'group']]

def WriteFunction(preds, fname):
    with open(fname, 'wb') as writer: 
        for item in preds:
            writer.write("%s\n" % item )

log = LogisticRegression(solver = 'sag')
lm = LinearRegression()
rf = RandomForestRegressor(
  n_estimators = 250, 
  max_features = 0.33, 
  min_samples_leaf = 1000, 
  n_jobs = -1)
lm_bagged = BaggingRegressor(
  base_estimator = lm, 
  n_estimators = 75, 
  max_samples = 0.25, 
  max_features = 0.33,
  bootstrap = True, 
  oob_score = False, 
  warm_start = False, 
  n_jobs = -1
)
log_bagged = BaggingClassifier(
  base_estimator = log, 
  n_estimators = 75, 
  max_samples = 0.25, 
  max_features = 0.33,
  bootstrap = True, 
  oob_score = False, 
  warm_start = False, 
  n_jobs = -1
)

print('fitting logistic model, first pass')
log.fit(X = train[feature_names], y = train['y'])
coefs = log.coef_[0].tolist()
features_to_cut = [x[0] for x in zip(feature_names, coefs) if x[1] == 0]
new_features = [x for x in feature_names if not x in features_to_cut]

print('fitting logistic model, second pass')
log.fit(X = train[new_features], y = train['y'])

print('fitting linear model')
lm.fit(X = train[new_features], y = train['y'])

print('fitting random forest model')
rf.fit(X = train[new_features], y = train['y'])

print('fitting bagged lm regressor')
lm_bagged.fit(X = train[new_features], y = train['y'])

print('fitting bagged log regressor')
log_bagged.fit(X = train[new_features], y = train['y'])

lm_preds = lm.predict(X = test[new_features])
log_preds = log.predict_proba(X = test[new_features])
rf_preds = rf.predict(X = test[new_features])
lm_bagged_preds = lm_bagged.predict(X = test[new_features])
log_bagged_preds = log_bagged.predict_proba(X = test[new_features])

WriteFunction(test['y'], 'truths.txt')
WriteFunction(lm_preds, 'lm_preds.txt')
WriteFunction(log_preds, 'log_preds.txt')
WriteFunction(rf_preds, 'rf_preds.txt')
WriteFunction(lm_bagged_preds, 'lm_bagged_preds.txt')
WriteFunction(log_bagged_preds, 'log_bagged_preds.txt')
