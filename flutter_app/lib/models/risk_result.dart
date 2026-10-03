enum RiskLevel { low, medium, high }

enum RiskDecision { allow, verify, hold, block }

class RiskFactor {
  final String feature;
  final double impact;
  final String message;

  const RiskFactor({
    required this.feature,
    required this.impact,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
    'feature': feature,
    'impact': impact,
    'message': message,
  };

  factory RiskFactor.fromJson(Map<String, dynamic> json) {
    return RiskFactor(
      feature: json['feature'] as String? ?? '',
      impact: (json['impact'] as num?)?.toDouble() ?? 0.0,
      message: json['message'] as String? ?? '',
    );
  }
}

class RiskResult {
  final String transactionId;
  final int riskScore; // 0-100
  final RiskLevel riskLevel; // low (0-39), medium (40-69), high (70-100)
  final RiskDecision decision; // allow, verify, hold, block
  final String customerMessage;
  final List<RiskFactor> riskFactors;
  final double? anomalyScore;
  final String? whatHappened;
  final String? whyRisky;
  final String? whatNext;
  final Map<String, dynamic>? rawDetails;

  const RiskResult({
    required this.transactionId,
    required this.riskScore,
    required this.riskLevel,
    required this.decision,
    required this.customerMessage,
    this.riskFactors = const [],
    this.anomalyScore,
    this.whatHappened,
    this.whyRisky,
    this.whatNext,
    this.rawDetails,
  });

  static RiskLevel calculateLevel(int score) {
    if (score >= 70) return RiskLevel.high;
    if (score >= 40) return RiskLevel.medium;
    return RiskLevel.low;
  }

  static RiskLevel levelFromScore(int score) => calculateLevel(score);

  static RiskLevel parseLevel(String level) {
    switch (level.toUpperCase()) {
      case 'HIGH':
        return RiskLevel.high;
      case 'MEDIUM':
        return RiskLevel.medium;
      case 'LOW':
      default:
        return RiskLevel.low;
    }
  }

  static RiskDecision parseDecision(String dec) {
    switch (dec.toUpperCase()) {
      case 'BLOCK':
        return RiskDecision.block;
      case 'HOLD':
        return RiskDecision.hold;
      case 'VERIFY':
        return RiskDecision.verify;
      case 'ALLOW':
      default:
        return RiskDecision.allow;
    }
  }

  Map<String, dynamic> toJson() => {
    'transaction_id': transactionId,
    'risk_score': riskScore,
    'risk_level': riskLevel.name.toUpperCase(),
    'decision': decision.name.toUpperCase(),
    'customer_message': customerMessage,
    'risk_factors': riskFactors.map((e) => e.toJson()).toList(),
    'anomaly_score': anomalyScore,
    if (whatHappened != null) 'what_happened': whatHappened,
    if (whyRisky != null) 'why_risky': whyRisky,
    if (whatNext != null) 'what_next': whatNext,
  };

  factory RiskResult.fromJson(Map<String, dynamic> json) {
    final score = json['risk_score'] as int? ?? 10;
    final levelStr = json['risk_level'] as String?;
    final level = levelStr != null ? parseLevel(levelStr) : calculateLevel(score);

    return RiskResult(
      transactionId: json['transaction_id'] as String? ?? '',
      riskScore: score,
      riskLevel: level,
      decision: parseDecision(json['decision'] as String? ?? 'ALLOW'),
      customerMessage:
          json['customer_message'] as String? ?? 'Money Sent Successfully',
      riskFactors:
          (json['risk_factors'] as List<dynamic>?)
              ?.map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      anomalyScore: (json['anomaly_score'] as num?)?.toDouble(),
      whatHappened: json['what_happened'] as String? ??
          (json['ai_explanation'] is Map ? (json['ai_explanation']['what_happened'] as String?) : null),
      whyRisky: json['why_risky'] as String? ??
          (json['ai_explanation'] is Map ? (json['ai_explanation']['why_risky'] as String?) : null),
      whatNext: json['what_next'] as String? ??
          (json['ai_explanation'] is Map ? (json['ai_explanation']['what_to_do'] as String?) : null),
      rawDetails: json,
    );
  }
}
