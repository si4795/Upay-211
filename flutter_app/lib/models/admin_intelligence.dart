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

class AuditLogEntry {
  final String logId;
  final String analystId;
  final String action;
  final String transactionId;
  final String timestamp;
  final String notes;
  final String ipAddress;

  const AuditLogEntry({
    required this.logId,
    required this.analystId,
    required this.action,
    required this.transactionId,
    required this.timestamp,
    required this.notes,
    this.ipAddress = '127.0.0.1',
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      logId: json['log_id'] as String? ?? '',
      analystId: json['analyst_id'] as String? ?? 'ADMIN001',
      action: json['action'] as String? ?? 'HOLD',
      transactionId: json['transaction_id'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      ipAddress: json['ip_address'] as String? ?? '127.0.0.1',
    );
  }
}

class ModelEvaluationData {
  final String datasetSource;
  final String evaluationSplit;
  final String modelType;
  final double accuracy;
  final double precision;
  final double recall;
  final double f1Score;
  final double rocAuc;
  final double falsePositiveRate;
  final Map<String, int> confusionMatrix;
  final List<Map<String, dynamic>> featuresRanked;

  const ModelEvaluationData({
    this.datasetSource = 'Synthetic Dataset Evaluation (6,000 Transactions)',
    this.evaluationSplit = '80% Train, 20% Test (1,200 Held-Out Samples)',
    this.modelType = 'XGBoost Classifier + Isolation Forest',
    this.accuracy = 0.9992,
    this.precision = 0.9958,
    this.recall = 1.0000,
    this.f1Score = 0.9979,
    this.rocAuc = 1.0000,
    this.falsePositiveRate = 0.0010,
    this.confusionMatrix = const {
      'true_negative': 959,
      'false_positive': 1,
      'false_negative': 0,
      'true_positive': 240,
    },
    this.featuresRanked = const [
      {'feature': 'amount_deviation', 'importance': 0.34},
      {'feature': 'device_change', 'importance': 0.28},
      {'feature': 'velocity', 'importance': 0.18},
      {'feature': 'location_change', 'importance': 0.12},
      {'feature': 'failed_attempts', 'importance': 0.08},
    ],
  });

  factory ModelEvaluationData.fromJson(Map<String, dynamic> json) {
    final metrics = (json['metrics'] as Map<String, dynamic>?) ?? {};
    final cm = (json['confusion_matrix'] as Map<String, dynamic>?) ?? {};
    final feats = (json['features_ranked'] as List<dynamic>?) ?? [];

    return ModelEvaluationData(
      datasetSource: json['dataset_source'] as String? ?? 'Synthetic Dataset Evaluation (6,000 Transactions)',
      evaluationSplit: json['evaluation_split'] as String? ?? '80% Train, 20% Test (1,200 Held-Out Samples)',
      modelType: json['model_type'] as String? ?? 'XGBoost Classifier',
      accuracy: (metrics['accuracy'] as num?)?.toDouble() ?? 0.9992,
      precision: (metrics['precision'] as num?)?.toDouble() ?? 0.9958,
      recall: (metrics['recall'] as num?)?.toDouble() ?? 1.0000,
      f1Score: (metrics['f1_score'] as num?)?.toDouble() ?? 0.9979,
      rocAuc: (metrics['roc_auc'] as num?)?.toDouble() ?? 1.0000,
      falsePositiveRate: (metrics['false_positive_rate'] as num?)?.toDouble() ?? 0.0010,
      confusionMatrix: cm.map((k, v) => MapEntry(k, (v as num).toInt())),
      featuresRanked: feats.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
    );
  }
}
