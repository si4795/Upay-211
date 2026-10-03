class Wallet {
  final double balance;
  final double dailySpent;
  final double monthlySpent;
  final double dailyLimit;

  const Wallet({
    this.balance = 25450.00,
    this.dailySpent = 3500.00,
    this.monthlySpent = 45200.00,
    this.dailyLimit = 100000.00,
  });

  Wallet copyWith({
    double? balance,
    double? dailySpent,
    double? monthlySpent,
    double? dailyLimit,
  }) {
    return Wallet(
      balance: balance ?? this.balance,
      dailySpent: dailySpent ?? this.dailySpent,
      monthlySpent: monthlySpent ?? this.monthlySpent,
      dailyLimit: dailyLimit ?? this.dailyLimit,
    );
  }
}

