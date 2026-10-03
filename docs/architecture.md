# Architecture & System Design — Track 01: Trust & Risk Intelligence

## 1. System Philosophy & Mission
The core tenet of this system is:
> **"Invisible Protection for Customers, Actionable Intelligence for Fraud Analysts."**

The customer application is deliberately kept clean, intuitive, and frictionless — free from alarming cybersecurity jargon, raw ML probabilities, or SHAP values. Behind the scenes, every sensitive transaction flows through a multi-layered Trust & Risk Engine that evaluates supervised fraud likelihood, unsupervised behavioral anomaly, account takeover indicators, and network graph topologies.

---

## 2. End-to-End Architectural Flow

```
[ Customer App (Flutter) ]
          │
          │ 1. POST /api/v1/transactions
          ▼
┌─────────────────────────────────────────────────────────────┐
│                   FastAPI Risk Gateway                      │
├─────────────────────────────────────────────────────────────┤
│ 1. Feature Engineering Engine                               │
│    • Velocity (txns / 1hr)                                  │
│    • Amount Deviation (Amount - Rolling User Average)       │
│    • Geo-Hop Detection (Dhaka vs Chattogram)                │
│    • Device Fingerprint Validation                          │
│    • Recipient Tenancy & Relationship                       │
├─────────────────────────────────────────────────────────────┤
│ 2. Dual-Layer AI Detection Engine                           │
│    ├── Supervised Model: XGBoost Classifier (P(Fraud))      │
│    └── Unsupervised Model: Isolation Forest (Anomaly Score) │
├─────────────────────────────────────────────────────────────┤
│ 3. Graph Intelligence (NetworkX)                            │
│    • Money-Mule Cluster Detection (A -> B,C,D,E -> X)       │
│    • Fan-In / Fan-Out Centrality                            │
│    • Circular Flow Detection                                │
├─────────────────────────────────────────────────────────────┤
│ 4. Explainable AI (SHAP Engine)                             │
│    • TreeExplainer Feature Attribution                      │
│    • Human-Understandable Factor Generation                 │
├─────────────────────────────────────────────────────────────┤
│ 5. Policy Engine                                            │
│    • LOW (0–30): ALLOW                                      │
│    • MEDIUM (31–70): VERIFY / CHALLENGE_OTP                 │
│    • HIGH (71–100): HOLD / BLOCK                            │
└─────────────────────────────────────────────────────────────┘
          │                                      │
          ▼                                      ▼
[ Safe Response to Customer ]          [ Fraud Analyst Portal ]
  • "Money Sent Successfully"            • Live Risk Feed (94/100)
  • "Additional verification required"   • SHAP Impact Waterfall
  • "Temporarily unavailable"            • Action Bar (Hold/Block/Review)
  (NO Risk Score Expose)                 • Mule Topology Explorer
```

---

## 3. Machine Learning & Anomaly Detection Pipeline

### A. Synthetic Dataset Generation
- **Dataset Size**: 6,000 realistic Bangladesh MFS transactions.
- **Class Distribution**: 80% Normal, 20% Fraud/Anomalous.
- **Regulatory Compliance**: Adheres to Bangladesh Bank MFS daily and single transaction caps (max ৳50,000 single transfer, ৳100,000 daily cumulative).
- **Features Captured**:
  1. `amount`: Transaction amount in BDT.
  2. `hour`: Transaction time (0-23).
  3. `device_change`: 1 if device fingerprint differs from user's trusted device.
  4. `location_change`: 1 if geocoding coordinates deviate significantly from home territory.
  5. `account_age`: Sender account longevity in days.
  6. `receiver_age`: Recipient account longevity in days.
  7. `velocity`: Transaction count within rolling 1-hour window.
  8. `amount_deviation`: Difference between current transfer and historical rolling mean.
  9. `new_receiver`: 1 if first-time transfer to recipient.
  10. `rapid_transaction`: Flag for sub-5 minute transaction bursts.
  11. `failed_attempts`: Consecutive authentication/PIN failures.

### B. Machine Learning Models
- **Supervised Model**: XGBoost (`xgb.XGBClassifier`) tuned for tabular transaction data, returning class probabilities. Fallback to `RandomForestClassifier`.
- **Unsupervised Anomaly Model**: Isolation Forest (`IsolationForest(contamination=0.20)`) trained strictly on verified normal transactions to isolate out-of-distribution behavioral outliers.
- **Composite Normalized Risk Score**:
  $$\text{Composite Score} = (0.75 \times P_{\text{XGBoost}} + 0.25 \times \text{Anomaly}_{\text{IsoForest}}) \times 100$$
  Bounded rigorously between $0$ and $100$.

### C. Explainable AI (SHAP)
- `shap.TreeExplainer` maps model leaf paths to exact feature attributions ($\phi_i$).
- Normalized percentage impact is computed for top contributors.
- Translated into clear human language for fraud analysts:
  - *"New unrecognized device detected (fingerprint mismatch)"*
  - *"Amount significantly exceeds user's normal pattern (+৳47,500)"*
  - *"Multiple rapid transactions detected (8 txns/hr)"*
  - *"Abrupt geographical hop detected (Dhaka to Chattogram)"*

---

## 4. Graph & Money-Mule Intelligence (NetworkX)
- Real-time directed graph $G = (V, E)$ where nodes $V$ represent accounts and edges $E$ represent directed fund transfers weighted by BDT amount.
- **Money Mule Detection**:
  - **Smurfing / Fan-Out Dispersers**: Nodes with out-degree $\ge 4$ transferring funds into intermediate accounts.
  - **Fan-In Aggregators**: Nodes with in-degree $\ge 3$ funneling funds from intermediate mules into a centralized collector ($A \rightarrow [B, C, D, E] \rightarrow X$).
  - **Circular Loops**: Simple directed cycles ($A \rightarrow B \rightarrow C \rightarrow A$) flagging artificial velocity padding.

---

## 5. Bangla Scam NLP Prototype
A specialized pattern recognition and text classification module for detecting Bengali scam messages targeting MFS users:
- **Credential Requests**: Regex and keyword matching for *"আপনার PIN দিন"*, *"OTP দিন"*, *"গোপন পিন"*.
- **Official Impersonation**: *"upay থেকে বলছি"*, *"উপায় হেড অফিস"*.
- **Lottery / Advance Fee**: *"আপনি পুরস্কার পেয়েছেন, verification fee পাঠান"*.
- **Threat / Account Closure**: *"আপনার একাউন্ট বন্ধ হয়ে যাবে"*.
