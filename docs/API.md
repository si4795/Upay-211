# API Reference & Documentation — upay Trust & Risk Intelligence

**Base URL**: `http://127.0.0.1:8000` (Localhost) or `http://10.0.2.2:8000` (Android Emulator)  
**API Version**: `v1` (`/api/v1`)  
**Interactive Docs**: `http://127.0.0.1:8000/docs` (Swagger UI) / `http://127.0.0.1:8000/redoc` (ReDoc)

---

## 1. Public & Core Endpoints

### `GET /api/v1/health`
Checks the operational health of the FastAPI service and ML pipeline components.

**Response (200 OK)**:
```json
{
  "status": "healthy",
  "service": "upay-trust-risk-engine",
  "version": "1.0.0",
  "model_loaded": true,
  "graph_nodes": 8,
  "graph_edges": 9,
  "timestamp": "2026-10-03T12:00:00"
}
```

---

### `POST /api/v1/predict-risk`
Performs risk inference and SHAP explainability on a proposed transaction without committing to history.

**Request Body**:
```json
{
  "user_id": "USER001",
  "receiver_id": "USER_ROGUE_99",
  "receiver_phone": "01999887766",
  "receiver_name": "Unknown Recipient",
  "amount": 50000.0,
  "device_id": "DEVICE009",
  "location": "Chattogram",
  "failed_attempts": 3,
  "velocity": 8
}
```

**Response (200 OK)**:
```json
{
  "transaction_id": "TXN-10001",
  "risk_score": 94,
  "risk_level": "HIGH",
  "decision": "HOLD",
  "customer_message": "Transaction temporarily unavailable. For your security, this transaction needs additional review.",
  "anomaly_score": 0.88,
  "supervised_probability": 0.96,
  "risk_factors": [
    {
      "feature": "device_change",
      "impact": 0.38,
      "message": "Unrecognized Device Fingerprint (DEVICE009)"
    },
    {
      "feature": "amount_deviation",
      "impact": 0.32,
      "message": "Amount significantly exceeds normal baseline (+৳49,350)"
    },
    {
      "feature": "location_change",
      "impact": 0.18,
      "message": "Abnormal geographical jump (Dhaka to Chattogram)"
    }
  ]
}
```

---

### `POST /api/v1/transactions`
Executes an actual customer Send Money transaction. Evaluates risk, updates the behavioral baseline and NetworkX graph, logs the risk event, and broadcasts it in real-time over WebSocket.

**Request Body**:
```json
{
  "user_id": "USER001",
  "receiver_phone": "01819283746",
  "receiver_name": "Karim Ahmed",
  "amount": 500.0,
  "device_id": "DEVICE001",
  "location": "Dhaka"
}
```

**Response (200 OK)**:
```json
{
  "transaction_id": "TXN-10002",
  "user_id": "USER001",
  "receiver_name": "Karim Ahmed",
  "receiver_phone": "01819283746",
  "amount": 500.0,
  "fee": 5.0,
  "total": 505.0,
  "timestamp": "2026-10-03T12:05:00",
  "status": "SUCCESS",
  "customer_message": "Money Sent Successfully"
}
```
*(Notice: Risk scores and technical factors are omitted from customer response to preserve customer privacy).*

---

## 2. Real-Time WebSockets

### `WS /api/v1/ws/risk-events`
Persistent WebSocket connection delivering instant risk telemetry to connected Admin Dashboards.

**On Connect Payload**:
```json
{
  "type": "CONNECTION_ESTABLISHED",
  "message": "Connected to real-time Trust & Risk Event Stream",
  "recent_events": [...]
}
```

**Live Broadcast Event Payload**:
```json
{
  "event_id": "EVT-1",
  "transaction_id": "TXN-10453",
  "user_id": "USER001",
  "amount": 50000.0,
  "risk_score": 94,
  "risk_level": "HIGH",
  "decision": "HOLD",
  "timestamp": "2026-10-03T12:41:19",
  "indicators": [
    "Unrecognized Device Fingerprint (DEVICE009)",
    "Amount significantly exceeds normal baseline (+৳49,350)",
    "Abnormal geographical jump (Dhaka to Chattogram)"
  ],
  "is_high_risk": true,
  "ato_pattern": "Potential Account Takeover Pattern",
  "device_id": "DEVICE009",
  "location": "Chattogram"
}
```

---

## 3. Fraud Analyst & Admin Endpoints

### `GET /api/v1/admin/risk-events`
Fetches recent risk events in chronological order.

### `GET /api/v1/admin/transactions`
Fetches full transaction history with attached SHAP explanations and anomaly scores.

### `POST /api/v1/admin/actions`
Applies an analyst decision (`HOLD`, `BLOCK`, `REVIEW`, `FALSE POSITIVE`) and writes to the permanent audit trail.

**Request Body**:
```json
{
  "transaction_id": "TXN-10453",
  "action": "HOLD",
  "analyst_id": "ADMIN001",
  "notes": "Observed new device and unusually large transaction compared with normal baseline."
}
```

### `GET /api/v1/admin/audit-logs`
Retrieves chronological audit log entries of all analyst interventions.

**Response (200 OK)**:
```json
[
  {
    "log_id": "AUD-1001",
    "analyst_id": "ADMIN001",
    "action": "HOLD",
    "transaction_id": "TXN-10453",
    "timestamp": "2026-10-03T12:43:20",
    "notes": "Observed new device and unusually large transaction compared with normal baseline.",
    "ip_address": "127.0.0.1"
  }
]
```

### `GET /api/v1/admin/user-profile/{user_id}`
Returns the behavioral baseline profile for a specific user.

**Response (200 OK)**:
```json
{
  "user_id": "USER001",
  "name": "Karim Ahmed",
  "phone": "01712345678",
  "avg_transaction_amount": 650.0,
  "typical_hours": "10 AM – 8 PM",
  "avg_transactions_per_day": 3,
  "typical_location": "Dhaka",
  "trusted_devices": ["DEVICE001", "DEVICE002"],
  "known_receivers": {
    "USER102": "Rahim (Trusted)",
    "USER245": "Karim (Known)",
    "MERCHANT01": "Hasan (Known Merchant)"
  }
}
```

### `GET /api/v1/admin/model-evaluation`
Returns statistical model validation results evaluated on the held-out test split.

**Response (200 OK)**:
```json
{
  "dataset_source": "Synthetic Dataset Evaluation (6,000 Transactions)",
  "evaluation_split": "80% Train, 20% Test (1,200 Held-Out Samples)",
  "model_type": "XGBoost Classifier + Isolation Forest",
  "metrics": {
    "accuracy": 0.9992,
    "precision": 0.9958,
    "recall": 1.0000,
    "f1_score": 0.9979,
    "roc_auc": 1.0000,
    "false_positive_rate": 0.0010
  },
  "confusion_matrix": {
    "true_negative": 959,
    "false_positive": 1,
    "false_negative": 0,
    "true_positive": 240
  },
  "features_ranked": [
    {"feature": "amount_deviation", "importance": 0.34},
    {"feature": "device_change", "importance": 0.28},
    {"feature": "velocity", "importance": 0.18},
    {"feature": "location_change", "importance": 0.12},
    {"feature": "failed_attempts", "importance": 0.08}
  ]
}
```

### `GET /api/v1/admin/graph`
Returns NetworkX topology containing detected money-mule aggregators, fan-out smurfing dispersers, and circular transaction flows.

### `POST /api/v1/admin/scam-nlp`
Performs Bengali NLP heuristic classification on SMS or chat text to detect PIN solicitation, OTP scams, official impersonation, and lottery advance-fee fraud.
