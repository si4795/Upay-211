# Security, Privacy & System Hardening Architecture

This document outlines the security controls, data privacy protections, and Responsible AI principles implemented in the **upay Trust & Risk Intelligence** platform.

---

## 1. Data Privacy & Financial Credential Safeguards

### A. No Real Credentials Stored
In compliance with international financial privacy standards and hackathon ethics:
- The system **never** stores real PINs, OTP codes, banking passwords, or payment credentials.
- All accounts use simulated demo credentials (`USER001`, `01712345678`, PIN: `1234`).
- All simulated balance deductions and wallet ledgers exist purely in in-memory state and synthetic storage.

### B. PIN Segregation & Zero-Knowledge ML Pipeline
A foundational architectural rule in financial security:
> **The PIN must never enter the Machine Learning or Feature Engineering pipeline.**

```
Customer PIN
     │
     ▼
[ Authentication Layer ] ── Validates PIN locally / securely
     │
     ▼ (PIN Discarded)
[ Transaction Metadata ] ── Amount, Device ID, Geo-City, Velocity
     │
     ▼
[ ML Risk Engine ] ────── Evaluates behavioral features only
```
- The risk scoring pipeline receives only required behavioral signals (`failed_attempts`, `amount`, `device_id`, `location`).
- The actual 4-digit PIN is strictly excluded from feature extraction, telemetry payloads, and WebSocket streams.

---

## 2. API Security & Validation

### A. Strict Request Validation
All incoming HTTP requests pass through typed **Pydantic v2 schemas** (`backend/app/models/`):
- `amount`: Validated to be positive (`gt=0`) and capped at Bangladesh Bank limits (`le=50000`).
- `user_id` and `receiver_id`: Sanitized strings matching alphanumeric identifiers.
- `receiver_phone`: Regex validated for standard 11-digit Bangladeshi mobile formats (`01[3-9]\d{8}`).
- Malformed payloads receive immediate `422 Unprocessable Entity` responses without triggering downstream inference.

### B. Rate Limiting
- Endpoints are protected against automated credential stuffing and velocity flooding.
- Repeated rapid requests within sub-second intervals trigger automated velocity flags and throttling.

---

## 3. Role-Based Access Control (RBAC)

The platform models simulated role-based authorization separating standard consumers from risk personnel:

| Role | Permitted Access | Restricted Paths |
| :--- | :--- | :--- |
| `CUSTOMER` | Send money, view wallet balance, check personal history, security settings | Cannot access `/api/v1/admin/*`, live feeds, or graph telemetry |
| `ANALYST` | View live risk feeds, inspect SHAP factor waterfalls, view NetworkX mule topologies, record notes | Cannot modify system-wide risk policy thresholds |
| `ADMIN` | Full access: Take binding actions (`HOLD`, `BLOCK`, `REVIEW`), audit logs, system configuration | Unrestricted |

---

## 4. Comprehensive Audit Trail

Every analyst decision generates an immutable audit record (`backend/app/services/audit_service.py`):
```json
{
  "log_id": "AUD-1001",
  "analyst_id": "ADMIN001",
  "action": "HOLD",
  "transaction_id": "TXN-10453",
  "timestamp": "2026-10-03T12:43:20",
  "notes": "Observed new device and unusually large transaction compared with normal baseline.",
  "ip_address": "127.0.0.1"
}
```
Audit entries track:
1. Unique Audit ID
2. Analyst Identifier
3. Action Applied (`HOLD`, `BLOCK`, `REVIEW`, `FALSE POSITIVE`)
4. Target Transaction & Account ID
5. ISO-8601 Timestamp
6. Explanatory Analyst Notes

---

## 5. Responsible AI & Human-in-the-Loop Principles

### A. Human-in-the-Loop Decision Making
AI models do not autonomously freeze user bank accounts or make irreversible punitive judgments. Instead:
$$\text{AI Model} \xrightarrow{\text{Risk Signal}} \text{Fraud Analyst} \xrightarrow{\text{Investigation}} \text{Human Action}$$

### B. Non-Accusatory Terminology
The platform strictly rejects definitive accusations:
- **Use**: *"Potential Account Takeover Pattern"* instead of *"This account has been hacked."*
- **Use**: *"Potential Money-Mule Pattern"* instead of *"Confirmed Money Laundering."*
- **Use**: *"Requires Investigation"* instead of *"Fraudulent Criminal Node."*

### C. False Positive Management
Analysts have a dedicated **`FALSE POSITIVE`** action button:
- When a customer confirms that an unusual transaction was legitimate (e.g., emergency hospital payment), the analyst records a false positive with the user's justification.
- This feedback is logged for subsequent model retraining and baseline adjustment.
