import joblib
import pandas as pd
from sklearn.metrics import classification_report, roc_auc_score, confusion_matrix
from feature_engineering import FEATURE_COLUMNS

def evaluate():
    bundle = joblib.load('ml/model.pkl')
    clf = bundle['classifier']
    iso_forest = bundle['isolation_forest']
    
    df = pd.read_csv('ml/dataset.csv')
    X = df[FEATURE_COLUMNS]
    y = df['is_fraud']

    probs = clf.predict_proba(X)[:, 1]
    preds = clf.predict(X)
    
    auc = roc_auc_score(y, probs)
    cm = confusion_matrix(y, preds)
    
    print("=" * 60)
    print("UPAY TRUST & RISK INTELLIGENCE - MODEL EVALUATION REPORT")
    print("=" * 60)
    print(f"Model Type: {bundle.get('model_type')}")
    print(f"Total Evaluated Samples: {len(y)}")
    print(f"ROC-AUC Score: {auc:.4f}")
    print("Confusion Matrix:")
    print(f"  [TN={cm[0,0]}  FP={cm[0,1]}]")
    print(f"  [FN={cm[1,0]}  TP={cm[1,1]}]")
    print("\nDetailed Classification Report:")
    print(classification_report(y, preds, target_names=['Normal (0)', 'Fraud/Anomalous (1)']))
    
    # Test Isolation Forest anomaly scores
    iso_scores = iso_forest.score_samples(X[:10])
    print(f"Sample Isolation Forest Anomaly Scores (first 5): {iso_scores[:5]}")
    print("=" * 60)

if __name__ == '__main__':
    evaluate()

