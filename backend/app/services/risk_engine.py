import datetime
from typing import Dict, Any, Tuple
from .feature_engineering import engineer_features
from .fraud_detector import FraudDetector
from .explanation_engine import ExplanationEngine
from .graph_analyzer import GraphAnalyzer

class RiskEngine:
    def __init__(self):
        self.detector = FraudDetector()
        self.explainer = ExplanationEngine(
            shap_explainer=self.detector.shap_explainer,
            feature_columns=self.detector.feature_columns
        )
        self.graph_analyzer = GraphAnalyzer()
        
        # In-memory storage for user profiles and transactions
        self.user_profiles: Dict[str, Dict[str, Any]] = {
            'USER001': {
                'user_id': 'USER001',
                'name': 'Md. Rafiqul Islam',
                'phone': '01712345678',
                'account_age_days': 320,
                'avg_amount': 2500.0,
                'trusted_devices': ['DEVICE001', 'DEVICE002'],
                'home_location': 'Dhaka',
                'known_receivers': ['USER102', 'MERCHANT01', 'USER304', 'AGENT402'],
            }
        }
        self.transaction_history = []
        self.risk_events = []
        self.fraud_cases = []
        self.admin_actions = []

    def evaluate_and_record(self, txn_data: Dict[str, Any], record_history: bool = True) -> Dict[str, Any]:
        """
        Processes a full transaction through the risk engine pipeline:
        Features -> XGBoost -> Isolation Forest -> Graph Update -> SHAP Explanation -> Policy Engine
        """
        user_id = txn_data.get('user_id', 'USER001')
        profile = self.user_profiles.get(user_id, {
            'user_id': user_id,
            'account_age_days': 200,
            'avg_amount': 2000.0,
            'trusted_devices': ['DEVICE001'],
            'home_location': 'Dhaka',
            'known_receivers': [],
        })

        # 1. Feature Engineering
        user_past_txns = [t for t in self.transaction_history if t.get('user_id') == user_id]
        df_features = engineer_features(txn_data, profile, user_past_txns)

        # 2. ML & Anomaly Inference
        risk_score, supervised_prob, anomaly_score = self.detector.predict_risk(df_features)

        # 3. Policy Classification
        # 0-30 LOW, 31-70 MEDIUM, 71-100 HIGH
        if risk_score <= 30:
            risk_level = "LOW"
            decision = "ALLOW"
            customer_message = "Money Sent Successfully"
            status = "SUCCESS"
        elif risk_score <= 70:
            risk_level = "MEDIUM"
            decision = "VERIFY"
            customer_message = "Additional verification is required to complete this transaction."
            status = "VERIFY_REQUIRED"
        else:
            risk_level = "HIGH"
            decision = "HOLD"
            customer_message = "Transaction temporarily unavailable. For your security, this transaction needs additional review."
            status = "HOLD"

        # 4. Explainable AI (SHAP Factors)
        risk_factors = self.explainer.explain_transaction(df_features, risk_score)

        # 5. Graph Analytics Update (if recording)
        receiver_id = txn_data.get('receiver_id', 'USER_UNKNOWN')
        amount = float(txn_data.get('amount', 0.0))
        if record_history:
            self.graph_analyzer.add_transaction(user_id, receiver_id, amount)

        # Build full result record
        txn_id = txn_data.get('transaction_id') or f"TXN-{10000 + len(self.transaction_history) + 1}"
        timestamp = txn_data.get('timestamp') or datetime.datetime.now().isoformat()

        record = {
            'transaction_id': txn_id,
            'user_id': user_id,
            'receiver_id': receiver_id,
            'receiver_name': txn_data.get('receiver_name', 'Recipient'),
            'receiver_phone': txn_data.get('receiver_phone', ''),
            'amount': amount,
            'fee': 5.0,
            'total': amount + 5.0,
            'timestamp': timestamp,
            'transaction_type': txn_data.get('transaction_type', 'SEND_MONEY'),
            'device_id': txn_data.get('device_id', 'DEVICE001'),
            'location': txn_data.get('location', 'Dhaka'),
            'status': status,
            'risk_score': risk_score,
            'risk_level': risk_level,
            'decision': decision,
            'customer_message': customer_message,
            'risk_factors': risk_factors,
            'anomaly_score': round(anomaly_score, 3),
            'supervised_probability': round(supervised_prob, 4),
        }

        if record_history:
            self.transaction_history.insert(0, record)

        # If medium or high risk, log risk event & case for admin
        if risk_level in ['MEDIUM', 'HIGH']:
            self.risk_events.insert(0, {
                'event_id': f"EVT-{len(self.risk_events)+1}",
                'transaction_id': txn_id,
                'user_id': user_id,
                'amount': amount,
                'risk_score': risk_score,
                'risk_level': risk_level,
                'decision': decision,
                'timestamp': timestamp,
                'indicators': [f['message'] for f in risk_factors],
            })
            
            # Create fraud case
            case_id = f"CASE-{len(self.fraud_cases) + 1:04d}"
            self.fraud_cases.insert(0, {
                'case_id': case_id,
                'user_id': user_id,
                'transaction_id': txn_id,
                'amount': amount,
                'risk_score': risk_score,
                'risk_level': risk_level,
                'reason': risk_factors[0]['message'] if risk_factors else 'Suspicious Activity',
                'status': 'Open',
                'assigned_analyst': 'Unassigned',
                'created_time': timestamp,
                'timeline': [
                    {'time': timestamp, 'event': f'Flagged as {risk_level} Risk (Score: {risk_score})'}
                ],
            })

        return record
