import pytest
from fastapi.testclient import TestClient
import sys
import os

# Add root directory to python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from backend.app.main import app

@pytest.fixture(scope="module")
def client():
    with TestClient(app) as c:
        yield c

def test_health_check(client):
    res = client.get("/api/v1/health")
    assert res.status_code == 200
    data = res.json()
    assert data["status"] == "healthy"
    assert "components" in data

def test_normal_transaction_low_risk(client):
    payload = {
        "user_id": "USER001",
        "receiver_id": "USER102",
        "amount": 500.0,
        "transaction_type": "SEND_MONEY",
        "device_id": "DEVICE001",
        "location": "Dhaka",
        "velocity": 1,
    }
    # Test predict-risk endpoint
    risk_res = client.post("/api/v1/predict-risk", json=payload)
    assert risk_res.status_code == 200
    r_data = risk_res.json()
    assert r_data["risk_level"] == "LOW"
    assert r_data["decision"] == "ALLOW"
    assert r_data["risk_score"] <= 30
    assert "Successfully" in r_data["customer_message"]

    # Test transaction execution endpoint
    txn_res = client.post("/api/v1/transactions", json=payload)
    assert txn_res.status_code == 200
    t_data = txn_res.json()
    assert t_data["status"] == "SUCCESS"
    # Ensure customer response NEVER exposes risk scores
    assert "risk_score" not in t_data
    assert "risk_level" not in t_data

def test_medium_risk_transaction(client):
    payload = {
        "user_id": "USER001",
        "receiver_id": "USER_UNFAMILIAR_55",
        "amount": 8000.0,
        "transaction_type": "SEND_MONEY",
        "device_id": "DEVICE001",
        "location": "Dhaka",
        "velocity": 2,
    }
    risk_res = client.post("/api/v1/predict-risk", json=payload)
    assert risk_res.status_code == 200
    r_data = risk_res.json()
    assert r_data["risk_level"] in ["MEDIUM", "HIGH"]
    assert r_data["decision"] in ["VERIFY", "HOLD"]

def test_high_risk_transaction_ato(client):
    payload = {
        "user_id": "USER001",
        "receiver_id": "USER_UNKNOWN_99",
        "amount": 50000.0,
        "transaction_type": "SEND_MONEY",
        "device_id": "DEVICE009", # New device
        "location": "Chattogram",  # Location change
        "velocity": 8,
        "failed_attempts": 3,
    }
    risk_res = client.post("/api/v1/predict-risk", json=payload)
    assert risk_res.status_code == 200
    r_data = risk_res.json()
    assert r_data["risk_level"] == "HIGH"
    assert r_data["decision"] in ["HOLD", "BLOCK"]
    assert r_data["risk_score"] >= 71
    # Check that explainable AI generated risk factors
    assert len(r_data["risk_factors"]) > 0

    # Ensure neutral customer message without technical alarm
    assert "temporarily unavailable" in r_data["customer_message"]
    assert "94" not in r_data["customer_message"] # No score in customer message

def test_admin_endpoints(client):
    # Test admin live risk events
    res = client.get("/api/v1/admin/risk-events")
    assert res.status_code == 200
    assert isinstance(res.json(), list)

    # Test admin transactions
    res_txns = client.get("/api/v1/admin/transactions")
    assert res_txns.status_code == 200
    admin_txns = res_txns.json()
    assert len(admin_txns) > 0
    # Admin CAN see risk scores
    assert "risk_score" in admin_txns[0]

    # Test admin action
    action_payload = {
        "transaction_id": admin_txns[0]["transaction_id"],
        "action": "HOLD",
        "analyst_id": "ADMIN001",
        "notes": "Verified new device and abnormal jump",
    }
    action_res = client.post("/api/v1/admin/actions", json=action_payload)
    assert action_res.status_code == 200
    assert action_res.json()["action"] == "HOLD"

def test_networkx_graph_intelligence(client):
    res = client.get("/api/v1/admin/graph")
    assert res.status_code == 200
    data = res.json()
    assert "total_nodes" in data
    assert "total_edges" in data
    assert "suspicious_networks" in data
    assert "nodes" in data
    assert "edges" in data

def test_bangla_scam_nlp(client):
    # Test credential phishing pattern
    payload = {"text": "upay থেকে বলছি আপনার PIN দিন"}
    res = client.post("/api/v1/admin/scam-nlp", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["is_scam"] is True
    assert data["category"] == "Credential Request"

    # Test normal Bengali message
    normal_payload = {"text": "শুভ সকাল ভাইয়া কেমন আছেন?"}
    res_norm = client.post("/api/v1/admin/scam-nlp", json=normal_payload)
    assert res_norm.status_code == 200
    assert res_norm.json()["is_scam"] is False

def test_audit_logs_and_user_profile(client):
    # Test audit logs endpoint
    res_audit = client.get("/api/v1/admin/audit-logs")
    assert res_audit.status_code == 200
    audit_data = res_audit.json()
    assert isinstance(audit_data, list)
    assert len(audit_data) >= 1
    assert "analyst_id" in audit_data[0]
    assert "action" in audit_data[0]

    # Test user profile endpoint
    res_profile = client.get("/api/v1/admin/user-profile/USER001")
    assert res_profile.status_code == 200
    profile_data = res_profile.json()
    assert profile_data["user_id"] == "USER001"
    assert "avg_transaction_amount" in profile_data
    assert "typical_location" in profile_data
    assert "trusted_devices" in profile_data

def test_model_evaluation_metrics(client):
    res = client.get("/api/v1/admin/model-evaluation")
    assert res.status_code == 200
    data = res.json()
    assert "metrics" in data
    assert "confusion_matrix" in data
    assert "features_ranked" in data
    assert "Synthetic Dataset Evaluation" in data["dataset_source"]
    assert data["metrics"]["precision"] >= 0.95
    assert data["metrics"]["recall"] >= 0.95

def test_websocket_connection(client):
    with client.websocket_connect("/api/v1/ws/risk-events") as websocket:
        data = websocket.receive_json()
        assert data["type"] == "CONNECTION_ESTABLISHED"
        assert "recent_events" in data
        websocket.send_text("ping")
        pong = websocket.receive_json()
        assert pong["type"] == "PONG"
