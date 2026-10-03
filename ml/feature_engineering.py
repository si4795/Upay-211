import pandas as pd
import numpy as np

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

def extract_features_from_dict(txn_dict: dict, user_profile: dict = None) -> pd.DataFrame:
    """
    Extracts numerical features matching the ML model pipeline from an incoming transaction dict.
    """
    amount = float(txn_dict.get('amount', 500.0))
    hour = int(txn_dict.get('hour', 12))
    
    # Check device change
    trusted_devices = user_profile.get('trusted_devices', ['DEVICE001']) if user_profile else ['DEVICE001']
    current_device = txn_dict.get('device_id', 'DEVICE001')
    device_change = int(txn_dict.get('device_change', 1 if current_device not in trusted_devices else 0))
    
    # Check location change
    home_location = user_profile.get('home_location', 'Dhaka') if user_profile else 'Dhaka'
    current_location = txn_dict.get('location', 'Dhaka')
    location_change = int(txn_dict.get('location_change', 1 if current_location.lower() != home_location.lower() else 0))
    
    account_age = int(user_profile.get('account_age', 320) if user_profile else txn_dict.get('account_age', 320))
    receiver_age = int(txn_dict.get('receiver_age', 180))
    
    velocity = int(txn_dict.get('velocity', 1))
    user_avg = float(user_profile.get('avg_amount', 2500.0) if user_profile else 2500.0)
    amount_deviation = float(txn_dict.get('amount_deviation', amount - user_avg))
    
    new_receiver = int(txn_dict.get('new_receiver', 0))
    rapid_transaction = int(txn_dict.get('rapid_transaction', 1 if velocity >= 4 else 0))
    failed_attempts = int(txn_dict.get('failed_attempts', 0))

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

