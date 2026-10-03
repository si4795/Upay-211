import datetime
from typing import Dict, Any, List

class BehaviorEngine:
    def __init__(self):
        # Baseline profiles for demo users
        self.profiles: Dict[str, Dict[str, Any]] = {
            'USER001': {
                'user_id': 'USER001',
                'name': 'Karim Ahmed',
                'phone': '01712345678',
                'avg_transaction_amount': 650.0,
                'typical_hours': '10 AM – 8 PM',
                'avg_transactions_per_day': 3,
                'typical_location': 'Dhaka',
                'trusted_devices': ['DEVICE001', 'DEVICE002'],
                'known_receivers': {
                    'USER102': 'Rahim (Trusted)',
                    'USER245': 'Karim (Known)',
                    'MERCHANT01': 'Hasan (Known Merchant)'
                },
                'reported_suspicious_receivers': ['USER_ROGUE_99', '01999887766'],
            }
        }

    def get_user_profile(self, user_id: str) -> Dict[str, Any]:
        return self.profiles.get(user_id, {
            'user_id': user_id,
            'name': 'Customer',
            'phone': '01700000000',
            'avg_transaction_amount': 1200.0,
            'typical_hours': '9 AM – 9 PM',
            'avg_transactions_per_day': 2,
            'typical_location': 'Dhaka',
            'trusted_devices': ['DEVICE001'],
            'known_receivers': {},
            'reported_suspicious_receivers': [],
        })

    def analyze_receiver(self, user_id: str, receiver_phone: str, receiver_id: str) -> Dict[str, Any]:
        profile = self.get_user_profile(user_id)
        known = profile.get('known_receivers', {})
        suspicious = profile.get('reported_suspicious_receivers', [])

        if receiver_id in suspicious or receiver_phone in suspicious:
            category = 'Frequently Reported'
            risk_level = 'HIGH'
            is_suspicious = True
        elif receiver_id in known or receiver_phone in known:
            category = 'Trusted' if 'Trusted' in known.get(receiver_id, '') else 'Known'
            risk_level = 'LOW'
            is_suspicious = False
        else:
            category = 'New'
            risk_level = 'MEDIUM'
            is_suspicious = True

        return {
            'receiver_id': receiver_id,
            'receiver_phone': receiver_phone,
            'category': category,
            'risk_level': risk_level,
            'is_new_receiver': category == 'New',
            'is_suspicious': is_suspicious,
        }

    def calculate_velocity_signals(self, user_id: str, current_amount: float, user_history: List[Dict[str, Any]]) -> Dict[str, Any]:
        now = datetime.datetime.now()
        five_min_ago = now - datetime.timedelta(minutes=5)
        one_hour_ago = now - datetime.timedelta(hours=1)

        txns_5min = 1
        txns_1hr = 1
        amount_1hr = current_amount
        receivers_1hr = set()

        for t in user_history:
            if t.get('user_id') != user_id:
                continue
            try:
                t_time = datetime.datetime.fromisoformat(t.get('timestamp', ''))
                if t_time >= five_min_ago:
                    txns_5min += 1
                if t_time >= one_hour_ago:
                    txns_1hr += 1
                    amount_1hr += float(t.get('amount', 0.0))
                    if t.get('receiver_id'):
                        receivers_1hr.add(t.get('receiver_id'))
            except Exception:
                pass

        is_abnormal_velocity = txns_1hr >= 5 or txns_5min >= 3
        return {
            'transactions_5min': txns_5min,
            'transactions_1hr': txns_1hr,
            'amount_1hr': round(amount_1hr, 2),
            'unique_receivers_1hr': len(receivers_1hr) + 1,
            'is_abnormal_velocity': is_abnormal_velocity,
            'velocity_flag': 'ABNORMAL VELOCITY' if is_abnormal_velocity else 'NORMAL VELOCITY',
        }

    def evaluate_account_takeover(
        self,
        user_id: str,
        device_id: str,
        location: str,
        amount: float,
        failed_attempts: int,
        receiver_data: Dict[str, Any],
        velocity_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Detects combinations of New Device + New Location + Failed Attempts + High Amount + New Receiver.
        Uses responsible AI phrasing: 'Potential Account Takeover Pattern'.
        """
        profile = self.get_user_profile(user_id)
        
        is_new_device = device_id not in profile.get('trusted_devices', ['DEVICE001'])
        is_new_location = location.strip().lower() != profile.get('typical_location', 'Dhaka').strip().lower()
        is_high_amount = amount >= (profile.get('avg_transaction_amount', 650.0) * 5)
        has_failed_attempts = failed_attempts >= 2
        is_new_receiver = receiver_data.get('is_new_receiver', False)
        is_rapid_velocity = velocity_data.get('is_abnormal_velocity', False)

        ato_signals = []
        if is_new_device:
            ato_signals.append('New Unrecognized Device')
        if is_new_location:
            ato_signals.append('Location Anomaly Hop')
        if has_failed_attempts:
            ato_signals.append(f'{failed_attempts} Consecutive Failed PIN Attempts')
        if is_high_amount:
            ato_signals.append(f'Amount Significantly Exceeds Baseline (৳{amount:,.0f} vs ৳{profile.get("avg_transaction_amount", 650):,.0f})')
        if is_new_receiver:
            ato_signals.append('Unverified First-Time Receiver')
        if is_rapid_velocity:
            ato_signals.append('Velocity Spike in Short Window')

        # Calculate confidence signal
        signal_count = len(ato_signals)
        if signal_count >= 4:
            confidence = 'HIGH'
            is_ato_detected = True
        elif signal_count >= 2:
            confidence = 'MEDIUM'
            is_ato_detected = True
        else:
            confidence = 'LOW'
            is_ato_detected = False

        return {
            'is_ato_pattern': is_ato_detected,
            'confidence_signal': confidence,
            'pattern_label': 'Potential Account Takeover Pattern' if is_ato_detected else 'Standard Activity Pattern',
            'detected_indicators': ato_signals,
            'behavior_comparison': {
                'normal_avg_amount': profile.get('avg_transaction_amount', 650.0),
                'current_amount': amount,
                'typical_location': profile.get('typical_location', 'Dhaka'),
                'current_location': location,
                'trusted_devices_count': len(profile.get('trusted_devices', [])),
                'current_device': device_id,
                'failed_attempts': failed_attempts,
            }
        }
