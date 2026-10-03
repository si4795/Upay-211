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
  final RiskLevel riskLevel; // low, medium, high
  final RiskDecision decision; // allow, verify, hold, block
  final String customerMessage;
  final List<RiskFactor> riskFactors;
  final double? anomalyScore;
  final Map<String, dynamic>? rawDetails;

  const RiskResult({
    required this.transactionId,
    required this.riskScore,
    required this.riskLevel,
    required this.decision,
    required this.customerMessage,
    this.riskFactors = const [],
    this.anomalyScore,
    this.rawDetails,
  });

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
  };

  factory RiskResult.fromJson(Map<String, dynamic> json) {
    return RiskResult(
      transactionId: json['transaction_id'] as String? ?? '',
      riskScore: json['risk_score'] as int? ?? 10,
      riskLevel: parseLevel(json['risk_level'] as String? ?? 'LOW'),
      decision: parseDecision(json['decision'] as String? ?? 'ALLOW'),
      customerMessage:
          json['customer_message'] as String? ?? 'Money Sent Successfully',
      riskFactors:
          (json['risk_factors'] as List<dynamic>?)
              ?.map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      anomalyScore: (json['anomaly_score'] as num?)?.toDouble(),
      rawDetails: json,
    );
  }
}
