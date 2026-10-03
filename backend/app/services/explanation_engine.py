import pandas as pd
import numpy as np
from typing import List, Dict, Any

class ExplanationEngine:
    def __init__(self, shap_explainer=None, feature_columns=None):
        self.shap_explainer = shap_explainer
        self.feature_columns = feature_columns or [
            'amount', 'hour', 'device_change', 'location_change',
            'account_age', 'receiver_age', 'velocity', 'amount_deviation',
            'new_receiver', 'rapid_transaction', 'failed_attempts'
        ]

    def explain_transaction(self, df_features: pd.DataFrame, risk_score: int) -> List[Dict[str, Any]]:
        """
        Calculates feature contributions using SHAP (or gradient importance)
        and converts them into clear, human-understandable explanation cards.
        """
        contributions = {}
        
        # Try computing SHAP values if explainer is available
        if self.shap_explainer is not None:
            try:
                shap_values = self.shap_explainer(df_features)
                # Handle binary classification output shape
                values = shap_values.values[0]
                if len(values.shape) > 1 and values.shape[-1] == 2:
                    values = values[:, 1]
                for col, val in zip(self.feature_columns, values):
                    contributions[col] = float(val)
            except Exception as e:
                contributions = self._heuristic_contributions(df_features)
        else:
            contributions = self._heuristic_contributions(df_features)

        # Generate human-readable risk factors
        risk_factors = []
        
        # Helper dictionary for explanation templates
        feature_messages = {
            'device_change': lambda v: "New unrecognized device detected (fingerprint mismatch)" if v > 0 else "Recognized trusted device",
            'amount_deviation': lambda v: f"Amount significantly exceeds user's normal pattern (+৳{v:,.0f})" if v > 1000 else "Amount within normal range",
            'amount': lambda v: f"Unusually large transfer amount (৳{v:,.0f})" if v >= 20000 else "Standard transfer volume",
            'velocity': lambda v: f"Multiple rapid transactions detected ({int(v)} in last hour)" if v >= 3 else "Normal transaction pace",
            'location_change': lambda v: "Abrupt geographical hop detected (location anomaly)" if v > 0 else "Normal geo-location",
            'hour': lambda v: f"Unusual off-peak transaction time ({int(v)}:00 hours)" if v in [1, 2, 3, 4, 5] else "Standard daytime transaction",
            'new_receiver': lambda v: "First-time transfer to new unverified recipient" if v > 0 else "Known regular recipient",
            'failed_attempts': lambda v: f"Multiple failed PIN / authentication attempts ({int(v)})" if v >= 2 else "Smooth authentication",
            'rapid_transaction': lambda v: "High-frequency burst transfer detected" if v > 0 else "Normal transaction interval",
            'account_age': lambda v: f"Fresh account creation ({int(v)} days active)" if v < 30 else "Established account tenure",
        }

        # Sort features by absolute contribution impact
        sorted_feats = sorted(
            contributions.items(),
            key=lambda item: abs(item[1]),
            reverse=True
        )

        total_positive_impact = sum(max(0.0, v) for _, v in sorted_feats) or 1.0

        for feat, val in sorted_feats:
            feat_val = df_features[feat].iloc[0]
            # Only include features that meaningfully elevate or lower risk
            if (feat == 'device_change' and feat_val == 1) or \
               (feat == 'amount_deviation' and feat_val > 1000) or \
               (feat == 'velocity' and feat_val >= 2) or \
               (feat == 'location_change' and feat_val == 1) or \
               (feat == 'failed_attempts' and feat_val >= 2) or \
               (feat == 'new_receiver' and feat_val == 1) or \
               (feat == 'amount' and feat_val >= 8000) or \
               (feat == 'hour' and feat_val in [1, 2, 3, 4, 5]):
                
                impact_norm = round(min(0.95, max(0.10, val / total_positive_impact)), 2)
                msg_gen = feature_messages.get(feat, lambda v: f"Elevated {feat} signal")
                
                risk_factors.append({
                    'feature': feat,
                    'impact': impact_norm,
                    'message': msg_gen(feat_val),
                })

        # If low risk and empty, show low-risk signals
        if not risk_factors:
            risk_factors.append({
                'feature': 'trusted_device',
                'impact': 0.05,
                'message': 'Recognized trusted primary device',
            })
            risk_factors.append({
                'feature': 'normal_amount',
                'impact': 0.04,
                'message': 'Transaction amount matches historical baseline',
            })

        return risk_factors[:5]

    def _heuristic_contributions(self, df_features: pd.DataFrame) -> Dict[str, float]:
        res = {}
        for col in self.feature_columns:
            val = df_features[col].iloc[0]
            if col == 'device_change':
                res[col] = 0.38 if val == 1 else 0.02
            elif col == 'amount_deviation':
                res[col] = 0.32 if val > 5000 else (0.15 if val > 2000 else 0.03)
            elif col == 'velocity':
                res[col] = 0.28 if val >= 4 else (0.14 if val >= 2 else 0.02)
            elif col == 'location_change':
                res[col] = 0.22 if val == 1 else 0.01
            elif col == 'failed_attempts':
                res[col] = 0.30 if val >= 2 else 0.01
            elif col == 'new_receiver':
                res[col] = 0.18 if val == 1 else 0.02
            else:
                res[col] = 0.05
        return res
