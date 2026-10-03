# Machine Learning & Fraud Intelligence Pipeline

This document details the data generation, feature engineering, dual-model architecture, SHAP explainability, and validation metrics powering the **upay Trust & Risk Intelligence** platform.

---

## 1. Synthetic Data Generation

In financial fraud detection, public MFS transaction datasets are strictly proprietary due to customer privacy regulations. To develop a production-grade machine learning system, we engineered a dedicated synthetic data generation pipeline (`ml/generate_dataset.py`) adhering to real-world Bangladeshi mobile financial services parameters.

### Key Dataset Characteristics
- **Total Transactions**: 6,000 samples.
- **Class Balance**: 80% Normal (4,800), 20% Fraud / Anomalous (1,200).
- **Regulatory Guardrails**: Strictly mirrors Bangladesh Bank limits:
  - Single transfer limit: Up to ৳50,000.
  - Daily cumulative limit: Up to ৳100,000.
- **Normal Patterns**:
  - Small to moderate daily transfers (Mean: ৳650, SD: ৳400).
  - Regular operational hours (8:00 AM – 10:00 PM).
  - Domestic geolocations (Dhaka primary cluster).
  - Consistent device fingerprints (`DEVICE001`, `DEVICE002`).
  - Low velocity (1–2 transactions/hour).
- **Simulated Attack Vectors**:
  - **Account Takeover (ATO)**: Rapid login from new device (`DEVICE009`), geographical hop (Dhaka $\rightarrow$ Chattogram), multiple failed PIN attempts, followed by large transfer (৳40,000–৳50,000).
  - **Money Mule Smurfing**: Sudden burst of high velocity (5–12 txns/hour) fanning out to multiple unverified recipients.
  - **Odd-Hour Drains**: Maximum-cap transfers initiated between 1:00 AM and 4:00 AM.

---

## 2. Feature Engineering Pipeline

The feature engineering layer (`backend/app/services/feature_engineering.py`) extracts 11 behavioral and contextual signals for every evaluated transaction:

| Feature Name | Type | Description |
| :--- | :--- | :--- |
| `amount` | Continuous | Transfer amount in BDT (৳). |
| `hour` | Discrete | Hour of day (0–23) to identify odd-hour activity. |
| `device_change` | Binary | `1` if device ID differs from user's registered trusted devices; `0` otherwise. |
| `location_change` | Binary | `1` if transaction originates from outside the user's primary historical city. |
| `account_age` | Continuous | Age of sender's account in days. |
| `receiver_age` | Continuous | Age of receiver's account in days. |
| `velocity` | Continuous | Count of transactions by this user in rolling 1-hour window. |
| `amount_deviation` | Continuous | Current amount minus user's historical rolling baseline mean. |
| `new_receiver` | Binary | `1` if user has never transferred to this recipient before. |
| `rapid_transaction` | Binary | `1` if previous transaction occurred within 5 minutes. |
| `failed_attempts` | Discrete | Count of consecutive failed PIN/auth attempts prior to execution. |

---

## 3. Dual-Layer AI Detection Architecture

Rather than relying solely on a single black-box classifier, the platform pairs a **supervised classifier** with an **unsupervised anomaly detector**:

```
                       ┌─────────────────────────┐
                       │   Transaction Request   │
                       └────────────┬────────────┘
                                    │
                       ┌────────────▼────────────┐
                       │   Feature Engineering   │
                       └────────────┬────────────┘
                                    │
               ┌────────────────────┴────────────────────┐
               │                                         │
    ┌──────────▼───────────┐                 ┌───────────▼───────────┐
    │  Supervised Model    │                 │  Unsupervised Model   │
    │  XGBoost Classifier  │                 │   Isolation Forest    │
    │  (Fraud Probability) │                 │    (Anomaly Score)    │
    └──────────┬───────────┘                 └───────────┬───────────┘
               │                                         │
               │ P(Fraud)                                │ Anomaly
               └────────────────────┬────────────────────┘
                                    │
                       ┌────────────▼────────────┐
                       │  Composite Risk Scoring │
                       └────────────┬────────────┘
                                    │
                       ┌────────────▼────────────┐
                       │    SHAP TreeExplainer   │
                       └────────────┬────────────┘
                                    │
                       ┌────────────▼────────────┐
                       │  Policy Decision Engine │
                       └─────────────────────────┘
```

### A. Supervised Model: XGBoost Classifier
- **Algorithm**: `xgboost.XGBClassifier(n_estimators=150, max_depth=5, learning_rate=0.08, eval_metric="logloss")`.
- **Purpose**: Learns complex non-linear combinations of known fraud signatures (e.g., Device Change + Geo-Hop + Large Amount Deviation).
- **Fallback**: Built-in graceful degradation to `RandomForestClassifier` if native XGBoost libraries are absent.

### B. Unsupervised Model: Isolation Forest
- **Algorithm**: `sklearn.ensemble.IsolationForest(n_estimators=100, contamination=0.20, random_state=42)`.
- **Purpose**: Flags novel, zero-day fraud patterns and abnormal behavioral outliers that do not conform to historical fraud labels.
- **Normalization**: Raw decision function scores $[-0.5, 0.5]$ are min-max normalized into $[0, 1]$.

### C. Composite Risk Scoring Formula
The normalized composite score ($0–100$) balances supervised fraud likelihood with anomaly severity:

$$\text{Composite Score} = \min\left(100, \max\left(0, \left(0.75 \times P_{\text{XGBoost}} + 0.25 \times \text{Anomaly}_{\text{IsoForest}}\right) \times 100\right)\right)$$

---

## 4. Explainable AI (SHAP Engine)

Every flagged transaction provides full transparency into **why** the decision was reached using **SHAP (SHapley Additive exPlanations)**:

1. **TreeExplainer**: `shap.TreeExplainer(model)` calculates exact Shapley values ($\phi_i$) for each feature.
2. **Attribution Normalization**: Positive contributions that pushed the score upward are isolated and converted to percentage weights:
   $$w_i = \frac{\phi_i}{\sum_{j} \phi_j}$$
3. **Human Language Synthesis**: Raw feature names are converted into actionable analyst insights:
   - `amount_deviation` $\rightarrow$ *"Transaction amount is significantly above user baseline (+৳49,350)"*
   - `device_change` $\rightarrow$ *"Unrecognized device fingerprint detected (DEVICE009)"*
   - `location_change` $\rightarrow$ *"Abrupt geographical hop detected (Dhaka to Chattogram)"*
   - `velocity` $\rightarrow$ *"Multiple rapid transactions in rolling window (8 txns/hr)"*

---

## 5. Model Evaluation & Performance

> **Synthetic Dataset Disclaimer**: The evaluation metrics presented below were measured on a held-out test split of the 6,000 synthetic transaction dataset (80% Train, 20% Test = 1,200 samples). Real-world performance on live production data may vary.

| Metric | Score | Note |
| :--- | :--- | :--- |
| **Accuracy** | **99.92%** | Overall correct classifications |
| **Precision** | **99.58%** | Minimized false accusations of legitimate users |
| **Recall (Sensitivity)** | **100.00%** | Zero missed fraud incidents on test set |
| **F1-Score** | **0.9979** | Harmonic mean of precision and recall |
| **ROC-AUC** | **1.0000** | Area under the Receiver Operating Characteristic curve |
| **False Positive Rate** | **0.10%** | Exceptionally low customer friction |

### Held-Out Confusion Matrix (1,200 Samples)
| | Predicted Normal | Predicted Fraud |
| :--- | :---: | :---: |
| **Actual Normal** | 959 (True Negative) | 1 (False Positive) |
| **Actual Fraud** | 0 (False Negative) | 240 (True Positive) |

### Feature Importance Ranking
1. **Amount Deviation**: 34%
2. **Device Change**: 28%
3. **Velocity**: 18%
4. **Location Change**: 12%
5. **Failed PIN Attempts**: 8%
