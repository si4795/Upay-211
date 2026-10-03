import random
import datetime
import pandas as pd
import numpy as np
from faker import Faker

fake = Faker('en_US')
np.random.seed(42)
random.seed(42)

def generate_synthetic_mfs_data(n_samples=6000, fraud_ratio=0.20):
    """
    Generates realistic Bangladesh MFS transaction dataset adhering to
    Bangladesh Bank guidelines and Track 01 fraud intelligence specifications.
    """
    n_fraud = int(n_samples * fraud_ratio)
    n_normal = n_samples - n_fraud
    
    locations = ['Dhaka', 'Chattogram', 'Sylhet', 'Rajshahi', 'Khulna', 'Barishal', 'Rangpur', 'Mymensingh', 'Cumilla', 'Gazipur']
    user_ids = [f'USER{str(i).zfill(3)}' for i in range(1, 301)]
    receiver_ids = [f'USER{str(i).zfill(3)}' for i in range(1, 601)]
    devices = [f'DEVICE{str(i).zfill(3)}' for i in range(1, 401)]
    
    # User historical baselines
    user_avg_amounts = {u: random.uniform(800, 3500) for u in user_ids}
    user_primary_devices = {u: random.choice(devices[:200]) for u in user_ids}
    user_primary_locations = {u: random.choice(locations[:3]) for u in user_ids}
    user_account_ages = {u: random.randint(90, 1200) for u in user_ids}

    records = []
    base_time = datetime.datetime.now() - datetime.timedelta(days=30)

    # 1. Generate Normal Transactions (80%)
    for i in range(n_normal):
        user = random.choice(user_ids)
        receiver = random.choice(receiver_ids)
        while receiver == user:
            receiver = random.choice(receiver_ids)
            
        txn_id = f"TXN{100000 + i}"
        
        # Normal amounts in Bangladesh MFS (৳100 to ৳5,000)
        user_avg = user_avg_amounts[user]
        amount = max(100.0, round(float(np.random.normal(user_avg, user_avg * 0.25)), 2))
        amount = min(15000.0, amount) # Cap normal amounts
        
        # Normal hours: 7 AM - 11 PM
        hour = random.choices(
            list(range(24)),
            weights=[1, 1, 1, 1, 2, 3, 5, 8, 10, 12, 12, 11, 10, 9, 9, 10, 11, 12, 12, 11, 9, 6, 4, 2]
        )[0]
        
        txn_time = base_time + datetime.timedelta(
            days=random.randint(0, 29),
            hours=hour,
            minutes=random.randint(0, 59),
            seconds=random.randint(0, 59)
        )
        
        device = user_primary_devices[user] if random.random() > 0.05 else random.choice(devices)
        device_change = 1 if device != user_primary_devices[user] else 0
        
        loc = user_primary_locations[user] if random.random() > 0.07 else random.choice(locations)
        location_change = 1 if loc != user_primary_locations[user] else 0
        
        account_age = user_account_ages[user]
        receiver_age = random.randint(60, 1000)
        
        velocity = max(1, int(np.random.poisson(1.2)))
        amount_deviation = round(amount - user_avg, 2)
        new_receiver = 1 if random.random() < 0.2 else 0
        rapid_transaction = 1 if velocity >= 4 else 0
        failed_attempts = 0 if random.random() > 0.04 else 1

        records.append({
            'transaction_id': txn_id,
            'user_id': user,
            'receiver_id': receiver,
            'amount': amount,
            'timestamp': txn_time.isoformat(),
            'hour': hour,
            'device_id': device,
            'device_change': device_change,
            'location': loc,
            'location_change': location_change,
            'account_age': account_age,
            'receiver_age': receiver_age,
            'velocity': velocity,
            'amount_deviation': amount_deviation,
            'new_receiver': new_receiver,
            'rapid_transaction': rapid_transaction,
            'failed_attempts': failed_attempts,
            'is_fraud': 0,
        })

    # 2. Generate Fraud / Anomalous Transactions (20%)
    # Scenarios: Account Takeover, Money Mule funneling, Velocity bursts, High Amount Deviation at 3 AM
    fraud_types = ['ATO', 'MULE', 'VELOCITY_BURST', 'HIGH_AMOUNT_NIGHT']
    
    for i in range(n_fraud):
        user = random.choice(user_ids)
        receiver = random.choice(receiver_ids)
        while receiver == user:
            receiver = random.choice(receiver_ids)
            
        txn_id = f"TXN{200000 + i}"
        ftype = random.choice(fraud_types)
        user_avg = user_avg_amounts[user]
        
        if ftype == 'ATO': # Account Takeover: New device + Location jump + Failed PINs + High Amount
            amount = round(random.uniform(25000, 50000), 2)
            hour = random.choice([1, 2, 3, 4, 23])
            device = f"DEVICE_ROGUE_{random.randint(900, 999)}"
            device_change = 1
            loc = random.choice(['Chattogram', 'Sylhet', 'Coxs Bazar', 'Unknown'])
            location_change = 1
            account_age = user_account_ages[user]
            receiver_age = random.randint(1, 15) # Very fresh receiver
            velocity = random.randint(5, 12)
            amount_deviation = round(amount - user_avg, 2)
            new_receiver = 1
            rapid_transaction = 1
            failed_attempts = random.randint(2, 4)
            
        elif ftype == 'MULE': # Money Mule: Multiple quick transfers to syndicate node
            amount = round(random.uniform(15000, 48000), 2)
            hour = random.randint(8, 22)
            device = user_primary_devices[user] if random.random() > 0.4 else random.choice(devices)
            device_change = 1 if device != user_primary_devices[user] else 0
            loc = user_primary_locations[user]
            location_change = 0
            account_age = random.randint(5, 30) # Mule mule account is young
            receiver_age = random.randint(5, 30)
            velocity = random.randint(6, 18)
            amount_deviation = round(amount - user_avg, 2)
            new_receiver = 1
            rapid_transaction = 1
            failed_attempts = 0
            
        elif ftype == 'VELOCITY_BURST': # Rapid automated draining
            amount = round(random.uniform(8000, 25000), 2)
            hour = random.randint(0, 23)
            device = random.choice(devices)
            device_change = 1
            loc = user_primary_locations[user]
            location_change = 0
            account_age = user_account_ages[user]
            receiver_age = random.randint(10, 200)
            velocity = random.randint(8, 20)
            amount_deviation = round(amount - user_avg, 2)
            new_receiver = 1
            rapid_transaction = 1
            failed_attempts = random.choice([1, 2])
            
        else: # HIGH_AMOUNT_NIGHT
            amount = round(random.uniform(35000, 50000), 2)
            hour = random.choice([2, 3, 4])
            device = user_primary_devices[user]
            device_change = 0
            loc = user_primary_locations[user]
            location_change = 0
            account_age = user_account_ages[user]
            receiver_age = random.randint(30, 400)
            velocity = random.randint(2, 5)
            amount_deviation = round(amount - user_avg, 2)
            new_receiver = 1
            rapid_transaction = 0
            failed_attempts = random.choice([0, 1])

        txn_time = base_time + datetime.timedelta(
            days=random.randint(0, 29),
            hours=hour,
            minutes=random.randint(0, 59),
            seconds=random.randint(0, 59)
        )

        records.append({
            'transaction_id': txn_id,
            'user_id': user,
            'receiver_id': receiver,
            'amount': amount,
            'timestamp': txn_time.isoformat(),
            'hour': hour,
            'device_id': device,
            'device_change': device_change,
            'location': loc,
            'location_change': location_change,
            'account_age': account_age,
            'receiver_age': receiver_age,
            'velocity': velocity,
            'amount_deviation': amount_deviation,
            'new_receiver': new_receiver,
            'rapid_transaction': rapid_transaction,
            'failed_attempts': failed_attempts,
            'is_fraud': 1,
        })

    df = pd.DataFrame(records)
    # Shuffle dataset
    df = df.sample(frac=1.0, random_state=42).reset_index(drop=True)
    return df

if __name__ == '__main__':
    df = generate_synthetic_mfs_data(6000, fraud_ratio=0.20)
    print(f"Generated {len(df)} transactions.")
    print("Class distribution:")
    print(df['is_fraud'].value_counts(normalize=True))
    
    # Save to ml/dataset.csv
    df.to_csv('ml/dataset.csv', index=False)
    # Also save to backend/data/transactions.csv
    df.to_csv('backend/data/transactions.csv', index=False)
    print("Saved to ml/dataset.csv and backend/data/transactions.csv successfully.")

