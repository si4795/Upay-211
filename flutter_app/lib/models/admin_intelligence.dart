class AnalyticsData {
  final int totalTransactions;
  final int highRiskCount;
  final int mediumRiskCount;
  final int lowRiskCount;
  final int blockedCount;
  final int underReviewCount;
  final Map<String, int> riskDistribution;
  final List<Map<String, dynamic>> recentTrend;

  const AnalyticsData({
    this.totalTransactions = 25430,
    this.highRiskCount = 42,
    this.mediumRiskCount = 186,
    this.lowRiskCount = 25202,
    this.blockedCount = 31,
    this.underReviewCount = 18,
    this.riskDistribution = const {
      '0-20': 21400,
      '21-40': 3802,
      '41-60': 140,
      '61-80': 46,
      '81-100': 42,
    },
    this.recentTrend = const [
      {'day': 'Mon', 'normal': 4200, 'flagged': 28},
      {'day': 'Tue', 'normal': 3950, 'flagged': 34},
      {'day': 'Wed', 'normal': 4600, 'flagged': 22},
      {'day': 'Thu', 'normal': 4100, 'flagged': 41},
      {'day': 'Fri', 'normal': 4800, 'flagged': 48},
      {'day': 'Sat', 'normal': 3700, 'flagged': 31},
      {'day': 'Sun', 'normal': 3200, 'flagged': 24},
    ],
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      totalTransactions: json['total_transactions'] as int? ?? 25430,
      highRiskCount: json['high_risk_count'] as int? ?? 42,
      mediumRiskCount: json['medium_risk_count'] as int? ?? 186,
      lowRiskCount: json['low_risk_count'] as int? ?? 25202,
      blockedCount: json['blocked_count'] as int? ?? 31,
      underReviewCount: json['under_review_count'] as int? ?? 18,
      riskDistribution:
          (json['risk_distribution'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          ) ??
          const {},
      recentTrend:
          (json['recent_trend'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
    );
  }
}

class AdminFraudCase {
  final String caseId;
  final String userId;
  final String transactionId;
  final double amount;
  final int riskScore;
  final String riskLevel;
  final String reason;
  String
  status; // Open, Under Review, Confirmed Suspicious, Resolved, False Positive
  String assignedAnalyst;
  final String createdTime;

  AdminFraudCase({
    required this.caseId,
    required this.userId,
    required this.transactionId,
    required this.amount,
    required this.riskScore,
    required this.riskLevel,
    required this.reason,
    required this.status,
    required this.assignedAnalyst,
    required this.createdTime,
  });

  factory AdminFraudCase.fromJson(Map<String, dynamic> json) {
    return AdminFraudCase(
      caseId: json['case_id'] as String? ?? 'CASE-0001',
      userId: json['user_id'] as String? ?? 'USER001',
      transactionId: json['transaction_id'] as String? ?? 'TXN-100',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      riskScore: json['risk_score'] as int? ?? 80,
      riskLevel: json['risk_level'] as String? ?? 'HIGH',
      reason: json['reason'] as String? ?? 'Suspicious Activity',
      status: json['status'] as String? ?? 'Open',
      assignedAnalyst: json['assigned_analyst'] as String? ?? 'Unassigned',
      createdTime: json['created_time'] as String? ?? '',
    );
  }
}

class BanglaScamResult {
  final String text;
  final bool isScam;
  final String category;
  final double confidence;
  final List<String> detectedKeywords;

  const BanglaScamResult({
    required this.text,
    required this.isScam,
    required this.category,
    required this.confidence,
    required this.detectedKeywords,
  });

  factory BanglaScamResult.fromJson(Map<String, dynamic> json) {
    return BanglaScamResult(
      text: json['text'] as String? ?? '',
      isScam: json['is_scam'] as bool? ?? false,
      category: json['category'] as String? ?? 'Normal',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      detectedKeywords:
          (json['detected_keywords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
