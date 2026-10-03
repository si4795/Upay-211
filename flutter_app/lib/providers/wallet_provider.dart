import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/wallet.dart';

class WalletProvider extends ChangeNotifier {
  Wallet _wallet = const Wallet(balance: AppConstants.initialBalance);
  bool _isBalanceVisible = false;

  Wallet get wallet => _wallet;
  double get balance => _wallet.balance;
  bool get isBalanceVisible => _isBalanceVisible;

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  void deductAmount(double amountWithFee) {
    if (_wallet.balance >= amountWithFee) {
      _wallet = _wallet.copyWith(
        balance: _wallet.balance - amountWithFee,
        dailySpent: _wallet.dailySpent + amountWithFee,
        monthlySpent: _wallet.monthlySpent + amountWithFee,
      );
      notifyListeners();
    }
  }

  void addAmount(double amount) {
    _wallet = _wallet.copyWith(
      balance: _wallet.balance + amount,
    );
    notifyListeners();
  }

  void resetToDemoBalance() {
    _wallet = const Wallet(balance: AppConstants.initialBalance);
    notifyListeners();
  }
}

