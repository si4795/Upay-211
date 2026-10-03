import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();

  bool _isProcessing = false;
  String? _errorMessage;
  TransactionModel? _lastCompletedTxn;

  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  TransactionModel? get lastCompletedTxn => _lastCompletedTxn;
  List<TransactionModel> get transactions => _service.transactions;

  List<TransactionModel> get recentTransactions =>
      _service.transactions.take(5).toList();

  List<TransactionModel> get todayTransactions {
    final now = DateTime.now();
    return _service.transactions.where((t) {
      return t.timestamp.year == now.year &&
          t.timestamp.month == now.month &&
          t.timestamp.day == now.day;
    }).toList();
  }

  List<TransactionModel> get thisWeekTransactions {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return _service.transactions.where((t) {
      return t.timestamp.isAfter(sevenDaysAgo);
    }).toList();
  }

  Future<TransactionModel?> executeSendMoney({
    required String userId,
    required String receiverPhone,
    required String receiverName,
    required double amount,
    required String deviceId,
    required String location,
    bool isNewDevice = false,
    bool isNewReceiver = false,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final txn = await _service.processSendMoney(
        userId: userId,
        receiverPhone: receiverPhone,
        receiverName: receiverName,
        amount: amount,
        deviceId: deviceId,
        location: location,
        isNewDevice: isNewDevice,
        isNewReceiver: isNewReceiver,
      );
      _lastCompletedTxn = txn;
      _isProcessing = false;
      notifyListeners();
      return txn;
    } catch (e) {
      _isProcessing = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  void clearLastCompletedTxn() {
    _lastCompletedTxn = null;
    notifyListeners();
  }
}
