import datetime
import pandas as pd
import numpy as np
from typing import Dict, Any

FEATURE_COLUMNS = [
    'amount',
    'hour',
    'device_change',
    'location_change',
    'account_age',
    'receiver_age',
    'velocity',
    'amount_deviation',
    'new_receiver',
    'rapid_transaction',
    'failed_attempts',
]

def engineer_features(txn_data: Dict[str, Any], user_profile: Dict[str, Any], user_history: list = None) -> pd.DataFrame:
    """
    Transforms raw incoming transaction request into model-ready features.
    """
    amount = float(txn_data.get('amount', 500.0))
    
    # Timestamp and hour
    ts_str = txn_data.get('timestamp')
    if ts_str:
        try:
            dt = datetime.datetime.fromisoformat(ts_str.replace('Z', '+00:00'))
            hour = dt.hour
        except Exception:
            hour = datetime.datetime.now().hour
    else:
        hour = datetime.datetime.now().hour

    # Device check
    trusted_devices = user_profile.get('trusted_devices', ['DEVICE001'])
    device_id = txn_data.get('device_id', 'DEVICE001')
    device_change = 1 if device_id not in trusted_devices else 0

    # Location check
    home_location = user_profile.get('home_location', 'Dhaka')
    location = txn_data.get('location', 'Dhaka')
    location_change = 1 if location.strip().lower() != home_location.strip().lower() else 0

    # User & Receiver profiles
    account_age = int(txn_data.get('account_age') or user_profile.get('account_age_days') or 320)
    receiver_age = int(txn_data.get('receiver_age') or 180)

    # Velocity (number of transactions in the last hour)
    velocity = 1
    if user_history:
        now = datetime.datetime.now()
        one_hour_ago = now - datetime.timedelta(hours=1)
        recent_count = 0
        for past_txn in user_history:
            try:
                p_time = datetime.datetime.fromisoformat(past_txn.get('timestamp', ''))
                if p_time >= one_hour_ago:
                    recent_count += 1
            except Exception:
                pass
        velocity = max(1, recent_count + 1)
    if txn_data.get('velocity') is not None:
        velocity = int(txn_data['velocity'])

    # Amount deviation
    avg_amount = float(user_profile.get('avg_amount', 2500.0))
    amount_deviation = round(amount - avg_amount, 2)

    # Receiver relationship
    known_receivers = user_profile.get('known_receivers', ['USER102', 'USER245'])
    receiver_id = txn_data.get('receiver_id', '')
    new_receiver = 1 if (receiver_id not in known_receivers) else 0

    # Rapid transaction indicator
    rapid_transaction = 1 if velocity >= 4 else 0

    # Failed attempts
    failed_attempts = int(txn_data.get('failed_attempts') or 0)

    row = {
        'amount': amount,
        'hour': hour,
        'device_change': device_change,
        'location_change': location_change,
        'account_age': account_age,
        'receiver_age': receiver_age,
        'velocity': velocity,
        'amount_deviation': amount_deviation,
        'new_receiver': new_receiver,
        'rapid_transaction': rapid_transaction,
        'failed_attempts': failed_attempts,
    }

    return pd.DataFrame([row], columns=FEATURE_COLUMNS)
