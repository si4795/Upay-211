# Hackathon Presentation & Live Demo Guide — Track 01

This guide provides step-by-step instructions for demonstrating the **upay Trust & Risk Intelligence** platform to hackathon judges.

---

## 1. Quick Start / Environment Setup

### Terminal 1 — Start FastAPI Risk Engine & WebSocket
```bash
# From workspace root (d:\Upay)
python -m uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload
```
*Verify*: Open `http://127.0.0.1:8000/api/v1/health` in your browser. Expected status: `"healthy"`.

### Terminal 2 — Launch Flutter Application
```bash
cd flutter_app
flutter run -d chrome      # Web demonstration
# Or: flutter run -d windows / flutter run -d android
```

---

## 2. Core Storyline to Present to Judges

> *"In Bangladesh, millions of citizens rely on MFS like upay for daily livelihoods. When fraud happens, it destroys user trust. However, if security is too intrusive with constant captchas and technical warnings, users abandon the platform.*  
> *Our solution embodies: **Invisible Protection for Customers, Actionable Intelligence for Fraud Analysts.**"*

---

## 3. Live Demonstration Steps

### Step 1: Customer App Experience (Invisible Protection)
1. **Login**: Tap **"Quick Demo Login"** as `Md. Rafiqul Islam` (`01712345678`).
2. **Dashboard**: Show the modern upay-inspired mobile interface. Tap **"ব্যালেন্স দেখতে ট্যাপ করুন"** to reveal `৳25,450.00`.
3. **Customer Security Center**: Tap the **Shield icon** in the upper right. Show the customer-friendly security features (Trusted Devices, Active Protection status, Recent Logins) — strictly free of alarmist fraud terminology.

---

### Step 2: The 3 Core Predefined Scenarios

Open the **Judge Demo Dialog** by tapping the **Play Icon** (▶) in the Admin Dashboard, or execute manually:

#### Scenario A: Normal Transaction (ALLOW)
- **Parameters**: ৳500 to trusted friend `Karim Ahmed` (`01819283746`), trusted device `DEVICE001`, location `Dhaka`.
- **Result**:
  - Backend scores risk at **12/100 (LOW)**.
  - Policy Engine triggers **`ALLOW`**.
  - Customer sees: **"টাকা পাঠানো সফল হয়েছে (Money Sent Successfully)"**.
  - Wallet balance smoothly deducts to `৳24,945.00`.

#### Scenario B: Medium-Risk Transaction (VERIFY)
- **Parameters**: ৳8,000 to first-time recipient `Anisur Rahman` (`01799887766`).
- **Result**:
  - Backend scores risk at **56/100 (MEDIUM)**.
  - Policy Engine triggers **`VERIFY`**.
  - Customer sees: **"অতিরিক্ত যাচাই প্রয়োজন (Additional verification required)"**.
  - No alarming fraud accusations; prompts secondary OTP challenge.

#### Scenario C: High-Risk Account Takeover (HOLD / BLOCK)
- **Parameters**: ৳50,000 to unverified receiver `01999887766`, new device `DEVICE009`, sudden geo-hop to `Chattogram`, 3 consecutive failed PIN attempts.
- **Result**:
  - Supervised probability is 0.96; anomaly score is 0.88; Composite Score: **94/100 (HIGH)**.
  - Policy Engine triggers **`HOLD`**.
  - Customer sees reassuring, neutral notice: **"লেনদেনটি সাময়িকভাবে স্থগিত (Transaction temporarily unavailable for your security)"**.

---

### Step 3: Admin Console — Real-Time WebSocket & High-Risk Alert
1. Switch to the **Admin Console** tab (`ADMIN001` / `1234`).
2. Point out that when Scenario C was submitted, the **WebSocket** instantly broadcasted the event without any page refresh!
3. Highlight the animated **`⚠ HIGH-RISK TRANSACTION DETECTED`** banner:
   - Displays `TXN-10453`, `৳50,000`, Risk: `94/100`.
   - Indicators: `New Device • Unusual Location • High Velocity`.
4. Tap **`[Open Investigation]`** on the banner.

---

### Step 4: Explainable AI & Human-in-the-Loop Investigation
1. Inside the **Risk Investigation Console**, show judges the **SHAP Feature Contribution Waterfall**:
   - `Amount Deviation`: +38%
   - `Device Change`: +32%
   - `Velocity Surge`: +24%
   - `Geo-Location Hop`: +18%
2. Show the **Account Takeover (ATO) Indicators** panel:
   - Phrased neutrally as **"Potential Account Takeover Pattern"** (Responsible AI principle).
3. Demonstrate **Human-in-the-Loop**:
   - Tap **`HOLD`** or **`BLOCK`**.
   - Enter Analyst Notes: *"Observed new device and unusually large transaction compared with normal baseline."*
   - Tap **Confirm**.
4. Show that the decision is immediately committed to the **Audit Trail**.

---

### Step 5: NetworkX Mule Graph Intelligence
1. Switch to the **"Mule Graph Intelligence"** tab.
2. Show the visual network graph rendered from NetworkX:
   - **Fan-Out Smurfing Disperser**: Account `USER_MULE_A` splitting funds across 4 accounts.
   - **Fan-In Collector / Destination Node**: Account `USER_SYNDICATE_X` funneling funds from 4 intermediate mules.
   - Circular transfer loop detection.
3. Emphasize that the system labels it **"Potential Money-Mule Pattern"**, not "Confirmed Money Laundering" (Responsible AI).

---

### Step 6: Bangla Scam NLP Phishing Detector
1. Switch to the **"Bangla Scam NLP"** tab.
2. Select or type:
   `"upay থেকে বলছি আপনার একাউন্ট ভেরিফাই করতে গোপন PIN দিন"`
3. Tap **"Analyze Bangla Text"**.
4. The engine flags:
   - **Category**: `Credential Request`
   - **Confidence**: `96%`
   - **Matched Keywords**: `PIN Request`, `Official Impersonation`

---

### Step 7: Model Evaluation & Audit Trail
1. Switch to **Security Analytics** tab.
2. Point to the **Model Evaluation Metrics** card:
   - Clearly labeled: **"Synthetic Dataset Evaluation (6,000 Transactions)"**.
   - Precision: **99.58%** | Recall: **100.00%** | F1: **0.9979** | ROC-AUC: **1.0000**.
   - Held-out Confusion matrix and ranked feature contributions.
3. Switch to the **"Audit Trail"** tab to verify that the analyst's action was permanently recorded with timestamp, analyst ID, and notes.
