import 'dart:math';
import '../models/transaction.dart';
import '../models/risk_result.dart';
import 'risk_service.dart';

class TransactionService {
  final RiskService _riskService;
  final List<TransactionModel> _transactions = [];

  TransactionService({RiskService? riskService})
      : _riskService = riskService ?? RiskService() {
    _seedInitialTransactions();
  }

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  void _seedInitialTransactions() {
    final now = DateTime.now();
    _transactions.addAll([
      TransactionModel(
        id: 'TXN-89211',
        userId: 'USER001',
        receiverId: 'USER102',
        receiverName: 'Karim Ahmed',
        receiverPhone: '01819283746',
        amount: 500.0,
        fee: 5.0,
        total: 505.0,
        timestamp: now.subtract(const Duration(hours: 2)),
        type: TransactionType.sendMoney,
        status: TransactionStatus.success,
        customerMessage: 'Money Sent Successfully',
      ),
      TransactionModel(
        id: 'TXN-89190',
        userId: 'USER001',
        receiverId: 'MERCHANT01',
        receiverName: 'Shwapno Supershop',
        receiverPhone: '01711223344',
        amount: 1450.0,
        fee: 0.0,
        total: 1450.0,
        timestamp: now.subtract(const Duration(hours: 5)),
        type: TransactionType.payBill,
        status: TransactionStatus.success,
        customerMessage: 'Bill Paid Successfully',
      ),
      TransactionModel(
        id: 'TXN-89045',
        userId: 'USER001',
        receiverId: 'USER304',
        receiverName: 'Nusrat Jahan',
        receiverPhone: '01928374650',
        amount: 3200.0,
        fee: 5.0,
        total: 3205.0,
        timestamp: now.subtract(const Duration(days: 2)),
        type: TransactionType.sendMoney,
        status: TransactionStatus.success,
        customerMessage: 'Money Sent Successfully',
      ),
      TransactionModel(
        id: 'TXN-88902',
        userId: 'USER001',
        receiverId: 'AGENT402',
        receiverName: 'Agent Cashout (Uttara)',
        receiverPhone: '01511223344',
        amount: 5000.0,
        fee: 75.0,
        total: 5075.0,
        timestamp: now.subtract(const Duration(days: 4)),
        type: TransactionType.cashOut,
        status: TransactionStatus.success,
        customerMessage: 'Cash Out Successful',
      ),
      TransactionModel(
        id: 'TXN-88412',
        userId: 'USER001',
        receiverId: 'USER512',
        receiverName: 'Tanvir Hossain',
        receiverPhone: '01677889900',
        amount: 1200.0,
        fee: 5.0,
        total: 1205.0,
        timestamp: now.subtract(const Duration(days: 6)),
        type: TransactionType.sendMoney,
        status: TransactionStatus.success,
        customerMessage: 'Money Sent Successfully',
      ),
    ]);
  }

  Future<TransactionModel> processSendMoney({
    required String userId,
    required String receiverPhone,
    required String receiverName,
    required double amount,
    required String deviceId,
    required String location,
    bool isNewDevice = false,
    bool isNewReceiver = false,
  }) async {
    final txnId = 'TXN-${10000 + Random().nextInt(90000)}';
    
    // Evaluate risk behind the scenes
    final riskResult = await _riskService.evaluateTransaction(
      transactionId: txnId,
      userId: userId,
      receiverId: 'USER_${receiverPhone.substring(max(0, receiverPhone.length - 4))}',
      amount: amount,
      deviceId: deviceId,
      location: location,
      isNewDevice: isNewDevice,
      isNewReceiver: isNewReceiver,
    );

    TransactionStatus status;
    switch (riskResult.decision) {
      case RiskDecision.allow:
        status = TransactionStatus.success;
        break;
      case RiskDecision.verify:
        status = TransactionStatus.verifyRequired;
        break;
      case RiskDecision.hold:
        status = TransactionStatus.hold;
        break;
      case RiskDecision.block:
        status = TransactionStatus.blocked;
        break;
    }

    final newTxn = TransactionModel(
      id: txnId,
      userId: userId,
      receiverId: 'USER_${receiverPhone.substring(max(0, receiverPhone.length - 4))}',
      receiverName: receiverName.isNotEmpty ? receiverName : 'Recipient',
      receiverPhone: receiverPhone,
      amount: amount,
      fee: 5.0,
      total: amount + 5.0,
      timestamp: DateTime.now(),
      type: TransactionType.sendMoney,
      status: status,
      customerMessage: riskResult.customerMessage,
      deviceId: deviceId,
      location: location,
      riskResult: riskResult,
    );

    _transactions.insert(0, newTxn);
    return newTxn;
  }
}

