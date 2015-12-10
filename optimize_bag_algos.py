import pandas as pd 
from sklearn.ensemble import BaggingRegressor
from sklearn.ensemble import BaggingClassifier
from sklearn.linear_model import LinearRegression
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestRegressor

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

write_function(test['y'], '/tmp/truths.txt')

print('optimizing samples')
for n_samp in [0.1, 0.25, 0.33, 0.5, 0.75, 1.0]:
    for n_feat in [0.1, 0.25, 0.33, 0.5, 0.75, 1.0]:    
        
        lm_bagged = BaggingRegressor(
          base_estimator = lm, 
          n_estimators = 75, 
          max_samples = n_samp, 
          max_features = n_feat,
          bootstrap = True, 
          oob_score = False, 
          warm_start = False, 
          n_jobs = -1
        )
        
        log_bagged = BaggingClassifier(
          base_estimator = log, 
          n_estimators = 75, 
          max_samples = n_samp, 
          max_features = n_feat,
          bootstrap = True, 
          oob_score = False, 
          warm_start = False, 
          n_jobs = -1
        )
        
        lm_bagged.fit(X = train[features], y = train['y'])
        log_bagged.fit(X = train[features], y = train['y'])        
        lm_bagged_preds = lm_bagged.predict(X = test[features])
        log_bagged_preds = log_bagged.predict_proba(X = test[features])
        
        write_function(lm_bagged_preds, '/tmp/lm_bagged_preds_nsamp-%s_nfeat-%s.txt' % (n_samp, n_feat))
        write_function(second_pos_clip(log_bagged_preds), '/tmp/log_bagged_preds_nsamp-%s_nfeat-%s.txt' % (n_samp, n_feat))
