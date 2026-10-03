import os
import joblib
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import IsolationForest, RandomForestClassifier
from sklearn.metrics import classification_report, roc_auc_score, f1_score
from feature_engineering import FEATURE_COLUMNS

try:
    import xgboost as xgb
    USE_XGB = True
except ImportError:
    USE_XGB = False

try:
    import shap
    USE_SHAP = True
except ImportError:
    USE_SHAP = False

def train_and_export():
    dataset_path = 'ml/dataset.csv'
    if not os.path.exists(dataset_path):
        import generate_dataset
        print("Generating dataset first...")
        df = generate_dataset.generate_synthetic_mfs_data(6000, 0.20)
        df.to_csv(dataset_path, index=False)
    else:
        df = pd.read_csv(dataset_path)

    X = df[FEATURE_COLUMNS]
    y = df['is_fraud']

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.20, random_state=42, stratify=y
    )

    print(f"Training dataset: {X_train.shape[0]} samples, {len(FEATURE_COLUMNS)} features.")

    # 1. Supervised Fraud Classification Model
    if USE_XGB:
        print("Training primary XGBoost Classifier...")
        clf = xgb.XGBClassifier(
            n_estimators=100,
            max_depth=4,
            learning_rate=0.08,
            random_state=42,
            eval_metric='logloss'
        )
    else:
        print("Fallback: Training Random Forest Classifier...")
        clf = RandomForestClassifier(
            n_estimators=100,
            max_depth=6,
            random_state=42
        )

    clf.fit(X_train, y_train)

    # Evaluate
    y_pred = clf.predict(X_test)
    y_prob = clf.predict_proba(X_test)[:, 1]
    auc = roc_auc_score(y_test, y_prob)
    f1 = f1_score(y_test, y_pred)
    print(f"Model AUC-ROC: {auc:.4f}")
    print(f"Model F1-Score: {f1:.4f}")
    print("Classification Report:")
    print(classification_report(y_test, y_pred))

    # 2. Unsupervised Anomaly Detection (Isolation Forest)
    print("Training Isolation Forest for anomaly detection...")
    iso_forest = IsolationForest(
        n_estimators=100,
        contamination=0.20,
        random_state=42
    )
    # Fit only on normal transactions
    normal_idx = (y_train == 0)
    iso_forest.fit(X_train[normal_idx])

    # 3. Explainable AI (SHAP Explainer)
    shap_explainer = None
    if USE_SHAP:
        print("Initializing SHAP TreeExplainer...")
        try:
            shap_explainer = shap.TreeExplainer(clf)
        except Exception as e:
            print(f"SHAP explainer init note: {e}")

    # Save model bundle
    bundle = {
        'model_type': 'xgboost' if USE_XGB else 'random_forest',
        'classifier': clf,
        'isolation_forest': iso_forest,
        'shap_explainer': shap_explainer,
        'feature_columns': FEATURE_COLUMNS,
        'baseline_means': X_train.mean().to_dict(),
        'metrics': {
            'auc_roc': float(auc),
            'f1_score': float(f1),
        }
    }

    os.makedirs('ml', exist_ok=True)
    os.makedirs('backend/app/models', exist_ok=True)
    
    joblib.dump(bundle, 'ml/model.pkl')
    joblib.dump(bundle, 'backend/app/models/model.pkl')
    print("Model bundle saved to ml/model.pkl and backend/app/models/model.pkl successfully!")

if __name__ == '__main__':
    train_and_export()

