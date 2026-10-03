import 'risk_result.dart';

enum TransactionStatus {
  success,
  verifyRequired,
  hold,
  blocked,
}

enum TransactionType {
  sendMoney,
  cashOut,
  addMoney,
  payBill,
}

class TransactionModel {
  final String id;
  final String userId;
  final String receiverId;
  final String receiverName;
  final String receiverPhone;
  final double amount;
  final double fee;
  final double total;
  final DateTime timestamp;
  final TransactionType type;
  final TransactionStatus status;
  final String customerMessage;
  final String deviceId;
  final String location;
  final RiskResult? riskResult;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPhone,
    required this.amount,
    this.fee = 5.0,
    required this.total,
    required this.timestamp,
    this.type = TransactionType.sendMoney,
    this.status = TransactionStatus.success,
    this.customerMessage = 'Money Sent Successfully',
    this.deviceId = 'DEVICE001',
    this.location = 'Dhaka',
    this.riskResult,
  });

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? receiverId,
    String? receiverName,
    String? receiverPhone,
    double? amount,
    double? fee,
    double? total,
    DateTime? timestamp,
    TransactionType? type,
    TransactionStatus? status,
    String? customerMessage,
    String? deviceId,
    String? location,
    RiskResult? riskResult,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      total: total ?? this.total,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      customerMessage: customerMessage ?? this.customerMessage,
      deviceId: deviceId ?? this.deviceId,
      location: location ?? this.location,
      riskResult: riskResult ?? this.riskResult,
    );
  }

  Map<String, dynamic> toJson() => {
    'transaction_id': id,
    'user_id': userId,
    'receiver_id': receiverId,
    'receiver_name': receiverName,
    'receiver_phone': receiverPhone,
    'amount': amount,
    'fee': fee,
    'total': total,
    'timestamp': timestamp.toIso8601String(),
    'transaction_type': type.name.toUpperCase(),
    'status': status.name,
    'customer_message': customerMessage,
    'device_id': deviceId,
    'location': location,
    if (riskResult != null) 'risk_result': riskResult!.toJson(),
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['transaction_id'] as String? ?? 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      userId: json['user_id'] as String? ?? 'USER001',
      receiverId: json['receiver_id'] as String? ?? '',
      receiverName: json['receiver_name'] as String? ?? 'Recipient',
      receiverPhone: json['receiver_phone'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      fee: (json['fee'] as num?)?.toDouble() ?? 5.0,
      total: (json['total'] as num?)?.toDouble() ?? ((json['amount'] as num?)?.toDouble() ?? 0.0) + 5.0,
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp'] as String) : DateTime.now(),
      type: _parseType(json['transaction_type'] as String?),
      status: _parseStatus(json['status'] as String?),
      customerMessage: json['customer_message'] as String? ?? 'Money Sent Successfully',
      deviceId: json['device_id'] as String? ?? 'DEVICE001',
      location: json['location'] as String? ?? 'Dhaka',
      riskResult: json['risk_result'] != null ? RiskResult.fromJson(json['risk_result'] as Map<String, dynamic>) : null,
    );
  }

  static TransactionType _parseType(String? str) {
    switch (str?.toUpperCase()) {
      case 'CASH_OUT':
        return TransactionType.cashOut;
      case 'ADD_MONEY':
        return TransactionType.addMoney;
      case 'PAY_BILL':
        return TransactionType.payBill;
      case 'SEND_MONEY':
      default:
        return TransactionType.sendMoney;
    }
  }

  static TransactionStatus _parseStatus(String? str) {
    switch (str?.toLowerCase()) {
      case 'verifyrequired':
      case 'verify':
        return TransactionStatus.verifyRequired;
      case 'hold':
        return TransactionStatus.hold;
      case 'blocked':
      case 'block':
        return TransactionStatus.blocked;
      case 'success':
      default:
        return TransactionStatus.success;
    }
  }
}

