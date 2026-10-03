# upay Simulator — Track 01: Trust & Risk Intelligence

![Flutter](https://img.shields.io/badge/Flutter-3.47.2-02569B?logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-0.142.2-009688?logo=fastapi)
![Python](https://img.shields.io/badge/Python-3.14.4-3776AB?logo=python)
![XGBoost](https://img.shields.io/badge/XGBoost-3.4.1-EB7A22?logo=xgboost)
![SHAP](https://img.shields.io/badge/SHAP-Explainable%20AI-blue)
![NetworkX](https://img.shields.io/badge/NetworkX-Graph%20Analytics-green)
![License](https://img.shields.io/badge/License-MIT-purple)

---

## 1. Overview & Core Mission

**upay Trust & Risk Intelligence** is a complete, hackathon-ready MFS simulation application engineered exclusively for **Track 01: Trust & Risk Intelligence**.

### Core Mission
Protect customers, merchants, agents, and the wider MFS ecosystem from fraud, scams, account takeover (ATO), money-mule activity, and emerging financial risks.

> **Disclaimer**: This is a prototype and simulation system for evaluation and hackathon judging. It does not connect to real bank accounts, real gateways, or real customer credentials.

---

## 2. Tech Stack & Architecture

| Layer | Technologies |
| :--- | :--- |
| **Frontend (Customer App & Admin)** | **Flutter 3.47.2**, Dart 3.13.2, Material 3, Provider State Management, `fl_chart`, `google_fonts` (Hind Siliguri & Inter), `pinput`, `animate_do`, `http`, `lucide_icons` |
| **Backend API** | **Python FastAPI**, Uvicorn, Pydantic v2, CORS middleware |
| **Supervised Machine Learning** | **XGBoost Classifier** (`XGBClassifier`) with fallback to **Random Forest** |
| **Unsupervised Anomaly Detection** | **Isolation Forest** (`IsolationForest`) |
| **Explainable AI (XAI)** | **SHAP** (`TreeExplainer`) feature contribution waterfall |
| **Graph Intelligence** | **NetworkX** directed transaction graph analysis |
| **Scam NLP Module** | Bengali text classification prototype for credential phishing & lottery scams |
| **Data Generation** | **Faker**, Pandas, NumPy (6,000 synthetic MFS transactions) |

---

## 3. System Architecture & Diagram

```
[ Customer App (Flutter) ]                  [ Admin / Fraud Analyst Dashboard ]
          │                                                  ▲
          │ POST /api/v1/transactions                        │
          ▼                                                  │
┌────────────────────────────────────────────────────────────┼─────────┐
│                    FastAPI Trust & Risk Engine             │         │
├────────────────────────────────────────────────────────────┴─────────┤
│ 1. Feature Engineering (Velocity, Deviation, Geo-Hop, Device Finger)  │
│ 2. Dual-Layer AI:                                                    │
│    • XGBoost Supervised Classification -> Fraud Probability          │
│    • Isolation Forest Unsupervised -> Behavioral Anomaly Score       │
│ 3. NetworkX Graph Intelligence:                                      │
│    • Money-Mule Cluster Detection: A -> [B, C, D, E] -> X            │
│    • Circular Transaction Detection & Degree Centrality Ranking      │
│ 4. Explainable AI (SHAP TreeExplainer):                              │
│    • Feature Importance & Human-Understandable Attribution          │
│ 5. Policy Engine:                                                    │
│    • Score 0-30:   ALLOW                                             │
│    • Score 31-70:  VERIFY (Challenge OTP/Biometrics)                 │
│    • Score 71-100: HOLD / BLOCK (Neutral Customer Notification)      │
└──────────────────────────────────────────────────────────────────────┘
          │
          ▼
[ Customer Safe Experience ]
  • Safe: "Money Sent Successfully"
  • Warning: "Additional verification is required to complete this transaction."
  • High-Risk: "Transaction temporarily unavailable. For your security, this transaction needs additional review."
  • (Risk Scores, SHAP values, and ML probabilities are NEVER exposed to customer)
```

---

## 4. Core Principle: Invisible Protection vs. Actionable Intelligence

> **"Invisible Protection for Customers, Actionable Intelligence for Fraud Analysts."**

* **Customer Flow**: The customer experiences a frictionless, authentic Bangladeshi MFS payment interface (inspired by upay). The customer **never** sees risk scores, fraud probabilities, SHAP values, or internal fraud labels.
* **Admin Flow**: Fraud analysts and security engineers have access to a data-rich investigation console with live risk feeds, SHAP feature importance charts, account takeover (ATO) indicators, money-mule graph topology, and action execution buttons (`[Review]`, `[Hold]`, `[Block]`, `[Monitor]`, `[Flag Account]`, `[Escalate]`).

---

## 5. 4-Phase Implementation & Verification

The project is structured and completed across the 4 required phases:

- [x] **Phase 1: Flutter Customer App Foundation**
  - Splash screen with animated upay branding.
  - Simulated authentication with Demo User 1-tap entry.
  - Interactive home dashboard with tap-to-reveal balance (`৳25,450.00`).
  - 6-step customer Send Money flow with review summary and PIN authentication.
  - Customer Security Center (Trusted Devices, Recent Logins, Active Monitoring).
  - Customer Transaction Statement with filterable tabs (Recent, Today, This Week).
- [x] **Phase 2: FastAPI + Trust & Risk Engine**
  - High-performance FastAPI server running on Python 3.14.
  - 6,000 synthetic Bangladesh MFS transactions respecting BB limits.
  - Primary XGBoost model (1.0000 AUC-ROC) + Isolation Forest anomaly detector.
  - SHAP TreeExplainer feature attribution engine.
  - Policy Engine mapping normalized composite risk scores ($0–100$) to `ALLOW`, `VERIFY`, `HOLD`, `BLOCK`.
- [x] **Phase 3: Admin Fraud Intelligence Dashboard**
  - Flutter Web/Desktop Security Console.
  - Real-time Live Risk Feed with severity indicators.
  - Interactive Security Analytics with `fl_chart` (risk score distribution, weekly flagged trends).
  - Fraud Case Management with lifecycle states (`Open`, `Under Review`, `Confirmed Suspicious`, `Resolved`, `False Positive`).
  - Action execution console recording analyst actions into the backend.
- [x] **Phase 4: Advanced Trust Intelligence & Demo Scenarios**
  - NetworkX Graph Analyzer for money-mule syndicates ($A \rightarrow B, C, D, E \rightarrow X$) and circular loops.
  - Account Takeover (ATO) correlation (New Device + Geo-Hop + Failed PINs + Spike).
  - Bangla Scam NLP Prototype with instant keyword attribution and confidence scoring.
  - 3 Official Predefined Demo Scenarios for instant hackathon evaluation.
- [x] **Phase 5: Real-Time Trust & Risk Intelligence**
  - WebSocket event stream (`/api/v1/ws/risk-events`) delivering live telemetry to admin consoles without manual refresh.
  - Animated `⚠ HIGH-RISK TRANSACTION DETECTED` real-time banner with direct `[Open Investigation]` drill-down.
  - Real-time customer & admin transaction status synchronization (`SUCCESS`, `VERIFY_REQUIRED`, `HOLD`).
- [x] **Phase 6: Advanced Fraud Intelligence**
  - Behavioral baselines for users (typical amount, time, velocity, trusted devices, known receivers).
  - Multi-signal Account Takeover (ATO) detection module with confidence levels.
  - Transaction velocity tracking (5-minute and 1-hour windows).
  - New receiver risk intelligence (Trusted, Known, New, Frequently Reported).
- [x] **Phase 7: Graph & Network Intelligence**
  - NetworkX directed transaction graph ($G=(V, E)$).
  - Degree centrality ranking to uncover high-connectivity hubs.
  - Money-mule fan-in aggregator and fan-out smurfing disperser detection.
  - Circular transaction loop detection ($A \rightarrow B \rightarrow C \rightarrow A$).
- [x] **Phase 8: Fraud Case Management & Responsible AI**
  - Fraud case creation, lifecycle status transitions, and analyst notes capture.
  - Strict Human-in-the-Loop principle (AI proposes risk signals; fraud analysts make binding decisions).
  - False Positive management workflow for model feedback.
  - Explainable AI (SHAP TreeExplainer feature contribution breakdown).
- [x] **Phase 9: Security, Privacy & System Hardening**
  - Zero real credentials stored (simulated demo auth).
  - PIN segregation: PIN validated at auth layer and strictly excluded from ML models.
  - Strict Pydantic v2 API validation and rate-limiting safeguards.
  - Immutable Analyst Audit Trail recording all interventions.
- [x] **Phase 10: Performance & Reliability**
  - Graceful fallback policies for ML and backend offline states.
  - Sanitized logging: PINs, OTPs, and passwords never written to logs.
- [x] **Phase 11: Polished UI/UX**
  - Customer UI: Clean, trustworthy, modern Bangladeshi MFS design in Bengali & English.
  - Admin UI: High-contrast fintech cybersecurity console with real-time charts and investigation consoles.
- [x] **Phase 12: Demo Mode & Presentation Readiness**
  - 1-tap preset demo scenario runner (Normal, Suspicious, High-Risk ATO).
  - Fast demo reset and reproducible state transitions.
- [x] **Phase 13: Presentation & Storytelling**
  - Customer story vs. Analyst investigation workflow narrative.
- [x] **Phase 14: Model Evaluation**
  - Statistical validation on held-out test split: Precision 99.58%, Recall 100.00%, F1 0.9979, ROC-AUC 1.0000.
  - Explicit *"Synthetic Dataset Evaluation"* disclaimer.
- [x] **Phase 15: Documentation & Submission Quality**
  - Comprehensive documentation in `docs/` (`API.md`, `ML_PIPELINE.md`, `DEMO.md`, `SECURITY.md`, `architecture.md`).
- [x] **Phase 16: Final Hackathon Verification**
  - 10/10 Pytest backend tests passing.
  - 10/10 Flutter tests passing.
  - 0 issues on `flutter analyze`.

---

## 6. Demo Scenarios Walkthrough (Judge Evaluation)

You can launch and verify the 3 predefined test scenarios directly from the app via the **Demo Scenario Dialog** (tap the play icon in the Admin header or use preset buttons in Send Money):

### Scenario 1 — Normal Transaction
* **Parameters**: ৳500 • Trusted Device (`DEVICE001`) • Dhaka • Normal Velocity (1 txn/hr)
* **Backend Evaluation**: Low Risk (Score ~12/100) $\rightarrow$ Decision: `ALLOW`
* **Customer Receives**: *"Money Sent Successfully"*
* **Admin Console**: Green status, trusted device verified, zero elevated factors.

### Scenario 2 — Suspicious Transaction
* **Parameters**: ৳8,000 • New Receiver • Moderate Amount Deviation
* **Backend Evaluation**: Medium Risk (Score ~56/100) $\rightarrow$ Decision: `VERIFY`
* **Customer Receives**: *"Additional verification is required to complete this transaction."*
* **Admin Console**: Orange status, SHAP highlights new recipient weight and deviation.

### Scenario 3 — High-Risk Fraud / Account Takeover (ATO)
* **Parameters**: ৳50,000 • New Device (`DEVICE009`) • Chattogram Geo-Hop • Rapid Burst (8 txns/hr) • 3 PIN Failures
* **Backend Evaluation**: High Risk (Score 94/100) $\rightarrow$ Decision: `HOLD` / `BLOCK`
* **Customer Receives**: Neutral message — *"Transaction temporarily unavailable. For your security, this transaction needs additional review."*
* **Admin Console**: Real-time WebSocket banner, SHAP breakdown (Unrecognized Device 38%, Amount Deviation 32%, Velocity 24%), option to click `[HOLD]` or `[BLOCK]`.

---

## 7. Setup & Run Guide

### Prerequisites
* Flutter SDK $\ge 3.24.0$ (Tested on Flutter 3.47.2 / Dart 3.13.2)
* Python $\ge 3.10$ (Tested on Python 3.14.4)
* Git

### Step 1: Install Python Dependencies & Train ML Models
```bash
# Install backend requirements
pip install -r backend/requirements.txt

# Generate synthetic dataset and train models
python ml/generate_dataset.py
python ml/train_model.py
python ml/evaluate_model.py
```

### Step 2: Start the FastAPI Backend Server
```bash
python -m uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload
```
* **API Documentation (Swagger UI)**: `http://127.0.0.1:8000/docs`
* **Health Check**: `http://127.0.0.1:8000/api/v1/health`
* **WebSocket Stream**: `ws://127.0.0.1:8000/api/v1/ws/risk-events`

### Step 3: Run the Flutter Application
```bash
cd flutter_app

# Fetch dependencies
flutter pub get

# Run on Chrome (Web Admin & Customer)
flutter run -d chrome

# Or run on Windows Desktop
flutter run -d windows
```

---

## 8. Key Endpoints & Architecture Reference

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/v1/health` | Service health and active AI components |
| `POST` | `/api/v1/predict-risk` | Dry-run risk assessment (SHAP factors & scores) |
| `POST` | `/api/v1/transactions` | Execute transaction through the risk engine & broadcast |
| `WS` | `/api/v1/ws/risk-events` | Real-time WebSocket stream for Admin Dashboard |
| `GET` | `/api/v1/admin/risk-events` | Live feed of recent risk events |
| `GET` | `/api/v1/admin/transactions` | Full transactions with risk scores & factors |
| `POST` | `/api/v1/admin/actions` | Record analyst action (`HOLD`, `BLOCK`, `REVIEW`) |
| `GET` | `/api/v1/admin/audit-logs` | Retrieve immutable analyst audit trail |
| `GET` | `/api/v1/admin/user-profile/{id}` | Behavioral profile & baselines for a user |
| `GET` | `/api/v1/admin/model-evaluation`| Held-out test split evaluation metrics & confusion matrix |
| `GET` | `/api/v1/admin/graph` | NetworkX money-mule topology and nodes |
| `POST` | `/api/v1/admin/scam-nlp` | Bangla scam-text classifier prototype |

Detailed documentation:
- [Architecture Guide](docs/architecture.md)
- [API Documentation](docs/API.md)
- [Machine Learning Pipeline](docs/ML_PIPELINE.md)
- [Hackathon Demo Guide](docs/DEMO.md)
- [Security & Privacy Guide](docs/SECURITY.md)

---

## 9. Test Cases & Verification Results

### Backend Test Suite (Pytest)
Run the backend test suite:
```bash
python -m pytest backend/tests/test_backend.py -v
```
**Results**:
* `test_health_check`: PASSED
* `test_normal_transaction_low_risk`: PASSED
* `test_medium_risk_transaction`: PASSED
* `test_high_risk_transaction_ato`: PASSED
* `test_admin_endpoints`: PASSED
* `test_networkx_graph_intelligence`: PASSED
* `test_bangla_scam_nlp`: PASSED
* `test_audit_logs_and_user_profile`: PASSED
* `test_model_evaluation_metrics`: PASSED
* `test_websocket_connection`: PASSED
* **Overall: 10 / 10 PASSED (100%)**

### Flutter Test Suite
Run the Flutter test suite:
```bash
cd flutter_app
flutter test
```
**Results**:
* Model serialization tests (User, Wallet, Transaction, RiskResult): PASSED
* Admin analytics & fraud case lifecycle tests: PASSED
* Bangla scam keyword matching tests: PASSED
* Audit log serialization and parsing tests: PASSED
* Model evaluation synthetic metric tests: PASSED
* UI widget smoke tests: PASSED
* **Overall: 10 / 10 PASSED (100%)**

### Flutter Analysis
```bash
flutter analyze
```
**Result**: `No issues found!` (0 errors, 0 warnings, 0 lints).

---

### Project Maintainer
* **Author**: Md Sayadul Islam (`mdsayadulislamsayad2626@gmail.com`)
* **Track**: Track 01 — Trust & Risk Intelligence
* **Date**: October 2026
