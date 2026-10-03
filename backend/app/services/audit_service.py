import datetime
from typing import List, Dict, Any, Optional

class AuditService:
    def __init__(self):
        self.audit_logs: List[Dict[str, Any]] = [
            {
                'log_id': 'AUD-1001',
                'analyst_id': 'ADMIN001',
                'action': 'HOLD',
                'transaction_id': 'TXN-10342',
                'timestamp': (datetime.datetime.now() - datetime.timedelta(minutes=15)).isoformat(),
                'notes': 'Observed new device and unusually large transaction compared with normal baseline.',
                'ip_address': '127.0.0.1',
            },
            {
                'log_id': 'AUD-1002',
                'analyst_id': 'ADMIN002',
                'action': 'REVIEW',
                'transaction_id': 'TXN-10341',
                'timestamp': (datetime.datetime.now() - datetime.timedelta(minutes=45)).isoformat(),
                'notes': 'Triggered automated OTP challenge verification for new unverified recipient.',
                'ip_address': '127.0.0.1',
            }
        ]

    def record_action(
        self,
        analyst_id: str,
        action: str,
        transaction_id: str,
        notes: Optional[str] = None,
        ip_address: str = '127.0.0.1'
    ) -> Dict[str, Any]:
        log_entry = {
            'log_id': f"AUD-{1000 + len(self.audit_logs) + 1}",
            'analyst_id': analyst_id,
            'action': action,
            'transaction_id': transaction_id,
            'timestamp': datetime.datetime.now().isoformat(),
            'notes': notes or f'Analyst applied action: {action}',
            'ip_address': ip_address,
        }
        self.audit_logs.insert(0, log_entry)
        return log_entry

    def get_logs(self, limit: int = 50) -> List[Dict[str, Any]]:
        return self.audit_logs[:limit]
