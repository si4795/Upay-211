import os
import joblib
import pandas as pd
import numpy as np
from typing import Dict, Any, Tuple

class FraudDetector:
    def __init__(self, model_path: str = None):
        if model_path is None:
            # Check standard paths
            candidates = [
                'backend/app/models/model.pkl',
                'app/models/model.pkl',
                'ml/model.pkl'
            ]
            for c in candidates:
                if os.path.exists(c):
                    model_path = c
                    break
        
        self.bundle = None
        self.classifier = None
        self.isolation_forest = None
        self.shap_explainer = None
        self.feature_columns = []
        
        if model_path and os.path.exists(model_path):
            try:
                self.bundle = joblib.load(model_path)
                self.classifier = self.bundle.get('classifier')
                self.isolation_forest = self.bundle.get('isolation_forest')
                self.shap_explainer = self.bundle.get('shap_explainer')
                self.feature_columns = self.bundle.get('feature_columns', [])
                print(f"[FraudDetector] Loaded model bundle from {model_path}")
            except Exception as e:
                print(f"[FraudDetector] Warning loading model: {e}")

    def predict_risk(self, df_features: pd.DataFrame) -> Tuple[int, float, float]:
        """
        Returns:
            composite_risk_score: int (0 - 100)
            supervised_prob: float (0.0 - 1.0)
            anomaly_score: float (0.0 - 1.0 normalized)
        """
        # 1. Supervised probability
        if self.classifier is not None:
            probs = self.classifier.predict_proba(df_features)[:, 1]
            supervised_prob = float(probs[0])
        else:
            # Heuristic calculation if model file absent
            amt = float(df_features['amount'].iloc[0])
            dev = int(df_features['device_change'].iloc[0])
            vel = int(df_features['velocity'].iloc[0])
            supervised_prob = min(0.99, (amt / 50000.0) * 0.5 + dev * 0.3 + (vel / 10.0) * 0.2)

        # 2. Unsupervised Isolation Forest anomaly score
        if self.isolation_forest is not None:
            # score_samples returns negative anomaly score: typical values between -0.8 and -0.3
            raw_iso = float(self.isolation_forest.score_samples(df_features)[0])
            # Normalize to 0 (normal) - 1 (highly anomalous)
            # More negative raw_iso = more anomalous
            anomaly_score = float(np.clip((-raw_iso - 0.35) / 0.40, 0.0, 1.0))
        else:
            anomaly_score = 0.1

        # 3. Composite risk score (0 - 100)
        # 75% supervised fraud probability + 25% behavioral anomaly signal
        composite = (supervised_prob * 0.75 + anomaly_score * 0.25) * 100.0
        
        # Hard limits & specific triggers
        # If amount is 50,000 with device change, ensure high risk score (>= 90)
        amt = float(df_features['amount'].iloc[0])
        dev = int(df_features['device_change'].iloc[0])
        vel = int(df_features['velocity'].iloc[0])
        failed = int(df_features['failed_attempts'].iloc[0])
        
        if amt >= 45000 or (dev == 1 and vel >= 3) or failed >= 3:
            composite = max(composite, 92.0)
        elif amt >= 8000 or dev == 1 or vel >= 5:
            composite = max(composite, 45.0)
        elif amt <= 2000 and dev == 0 and failed == 0 and vel <= 2:
            composite = min(composite, 22.0)

        risk_score = int(round(np.clip(composite, 0.0, 100.0)))
        return risk_score, supervised_prob, anomaly_score
