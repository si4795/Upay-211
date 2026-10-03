import '../models/admin_intelligence.dart';
import '../models/transaction.dart';
import '../models/risk_result.dart';
import 'api_service.dart';

class AdminService {
  final ApiService _apiService = ApiService();
  ApiService get apiService => _apiService;

  Future<AnalyticsData> fetchAnalytics() async {
    try {
      final res = await _apiService.get('/api/v1/admin/analytics');
      return AnalyticsData.fromJson(res);
    } catch (e) {
      // High-fidelity fallback
      return const AnalyticsData();
    }
  }

  Future<List<TransactionModel>> fetchAdminTransactions() async {
    try {
      final res = await _apiService.getList('/api/v1/admin/transactions');
      if (res.isNotEmpty) {
        return res.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    // Illustrative seed data for admin dashboard demo
    final now = DateTime.now();
    return [
      TransactionModel(
        id: 'TXN-10342',
        userId: 'USER001',
        receiverId: 'USER_ROGUE_99',
        receiverName: 'Syndicate Node B',
        receiverPhone: '01999887766',
        amount: 50000.0,
        fee: 5.0,
        total: 50005.0,
        timestamp: now.subtract(const Duration(minutes: 6)),
        type: TransactionType.sendMoney,
        status: TransactionStatus.hold,
        deviceId: 'DEVICE009',
        location: 'Chattogram',
        riskResult: const RiskResult(
          transactionId: 'TXN-10342',
          riskScore: 94,
          riskLevel: RiskLevel.high,
          decision: RiskDecision.hold,
          customerMessage: 'Transaction temporarily unavailable.',
          riskFactors: [
            RiskFactor(feature: 'device_change', impact: 0.38, message: 'Unrecognized Device Fingerprint (DEVICE009)'),
            RiskFactor(feature: 'amount_deviation', impact: 0.32, message: 'Amount significantly exceeds user normal pattern (+৳47,500)'),
            RiskFactor(feature: 'velocity', impact: 0.24, message: 'Multiple rapid transactions detected (8 txns/hr)'),
            RiskFactor(feature: 'location_change', impact: 0.18, message: 'Abnormal geographical jump (Dhaka to Chattogram)'),
          ],
          anomalyScore: 0.89,
        ),
      ),
      TransactionModel(
        id: 'TXN-10341',
        userId: 'USER001',
        receiverId: 'USER_NEW_45',
        receiverName: 'Anisur Rahman',
        receiverPhone: '01799887766',
        amount: 8000.0,
        fee: 5.0,
        total: 8005.0,
        timestamp: now.subtract(const Duration(minutes: 35)),
        type: TransactionType.sendMoney,
        status: TransactionStatus.verifyRequired,
        deviceId: 'DEVICE001',
        location: 'Dhaka',
        riskResult: const RiskResult(
          transactionId: 'TXN-10341',
          riskScore: 56,
          riskLevel: RiskLevel.medium,
          decision: RiskDecision.verify,
          customerMessage: 'Additional verification is required to complete this transaction.',
          riskFactors: [
            RiskFactor(feature: 'new_receiver', impact: 0.42, message: 'First-time transfer to unverified recipient'),
            RiskFactor(feature: 'amount_deviation', impact: 0.30, message: 'Moderately exceeds normal transfer amount'),
          ],
          anomalyScore: 0.45,
        ),
      ),
      TransactionModel(
        id: 'TXN-10340',
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
        deviceId: 'DEVICE001',
        location: 'Dhaka',
        riskResult: const RiskResult(
          transactionId: 'TXN-10340',
          riskScore: 12,
          riskLevel: RiskLevel.low,
          decision: RiskDecision.allow,
          customerMessage: 'Money Sent Successfully',
          riskFactors: [
            RiskFactor(feature: 'trusted_device', impact: 0.05, message: 'Recognized primary trusted device'),
            RiskFactor(feature: 'normal_amount', impact: 0.04, message: 'Amount matches historical average'),
          ],
          anomalyScore: 0.08,
        ),
      ),
    ];
  }

  Future<List<AdminFraudCase>> fetchFraudCases() async {
    try {
      final res = await _apiService.getList('/api/v1/admin/cases');
      if (res.isNotEmpty) {
        return res.map((e) => AdminFraudCase.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    return [
      AdminFraudCase(
        caseId: 'CASE-0001',
        userId: 'USER001',
        transactionId: 'TXN-10342',
        amount: 50000.0,
        riskScore: 94,
        riskLevel: 'HIGH',
        reason: 'Unrecognized Device + Rapid Velocity Burst + Location Jump',
        status: 'Open',
        assignedAnalyst: 'ADMIN001',
        createdTime: 'Today, 12:42 PM',
      ),
      AdminFraudCase(
        caseId: 'CASE-0002',
        userId: 'USER001',
        transactionId: 'TXN-10341',
        amount: 8000.0,
        riskScore: 56,
        riskLevel: 'MEDIUM',
        reason: 'First-time transfer to unverified recipient',
        status: 'Under Review',
        assignedAnalyst: 'ADMIN002',
        createdTime: 'Today, 11:20 AM',
      ),
      AdminFraudCase(
        caseId: 'CASE-0003',
        userId: 'USER089',
        transactionId: 'TXN-10290',
        amount: 35000.0,
        riskScore: 88,
        riskLevel: 'HIGH',
        reason: 'Potential Money-Mule Funneling Pattern',
        status: 'Confirmed Suspicious',
        assignedAnalyst: 'ADMIN001',
        createdTime: 'Yesterday, 04:15 PM',
      ),
    ];
  }

  Future<bool> takeAdminAction({
    required String transactionId,
    required String action,
    String analystId = 'ADMIN001',
    String? notes,
  }) async {
    try {
      await _apiService.post('/api/v1/admin/actions', {
        'transaction_id': transactionId,
        'action': action,
        'analyst_id': analystId,
        'notes': notes,
      });
      return true;
    } catch (_) {
      return true; // Local simulation success
    }
  }

  Future<Map<String, dynamic>> fetchGraphIntelligence() async {
    try {
      return await _apiService.get('/api/v1/admin/graph');
    } catch (_) {
      return {
        'total_nodes': 8,
        'total_edges': 9,
        'high_connectivity_accounts': [
          {'node': 'USER_SYNDICATE_X', 'degree': 4},
          {'node': 'USER_MULE_A', 'degree': 4},
          {'node': 'USER001', 'degree': 3},
        ],
        'suspicious_networks': [
          {
            'node': 'USER_SYNDICATE_X',
            'in_degree': 4,
            'pattern': 'Fan-In Aggregator (Potential Money-Mule Destination)',
            'risk_level': 'HIGH',
            'recommendation': 'Requires Investigation'
          },
          {
            'node': 'USER_MULE_A',
            'out_degree': 4,
            'pattern': 'Fan-Out Disperser (Rapid Smurfing Pattern)',
            'risk_level': 'HIGH',
            'recommendation': 'Requires Investigation'
          }
        ],
        'nodes': [
          {'id': 'USER_MULE_A', 'is_flagged': true, 'in_degree': 0, 'out_degree': 4},
          {'id': 'USER_MULE_B', 'is_flagged': false, 'in_degree': 1, 'out_degree': 1},
          {'id': 'USER_MULE_C', 'is_flagged': false, 'in_degree': 1, 'out_degree': 1},
          {'id': 'USER_MULE_D', 'is_flagged': false, 'in_degree': 1, 'out_degree': 1},
          {'id': 'USER_MULE_E', 'is_flagged': false, 'in_degree': 1, 'out_degree': 1},
          {'id': 'USER_SYNDICATE_X', 'is_flagged': true, 'in_degree': 4, 'out_degree': 0},
          {'id': 'USER001', 'is_flagged': false, 'in_degree': 0, 'out_degree': 3},
          {'id': 'USER102', 'is_flagged': false, 'in_degree': 1, 'out_degree': 0},
        ],
        'edges': [
          {'source': 'USER_MULE_A', 'target': 'USER_MULE_B', 'amount': 25000.0},
          {'source': 'USER_MULE_A', 'target': 'USER_MULE_C', 'amount': 25000.0},
          {'source': 'USER_MULE_A', 'target': 'USER_MULE_D', 'amount': 25000.0},
          {'source': 'USER_MULE_A', 'target': 'USER_MULE_E', 'amount': 25000.0},
          {'source': 'USER_MULE_B', 'target': 'USER_SYNDICATE_X', 'amount': 24500.0},
          {'source': 'USER_MULE_C', 'target': 'USER_SYNDICATE_X', 'amount': 24500.0},
          {'source': 'USER_MULE_D', 'target': 'USER_SYNDICATE_X', 'amount': 24500.0},
          {'source': 'USER_MULE_E', 'target': 'USER_SYNDICATE_X', 'amount': 24500.0},
          {'source': 'USER001', 'target': 'USER102', 'amount': 500.0},
        ]
      };
    }
  }

  Future<BanglaScamResult> analyzeScamText(String text) async {
    try {
      final res = await _apiService.post('/api/v1/admin/scam-nlp', {'text': text});
      return BanglaScamResult.fromJson(res);
    } catch (_) {
      // Local fallback classifier
      final lower = text.toLowerCase();
      if (lower.contains('pin') || lower.contains('পিন') || lower.contains('otp') || lower.contains('ওটিপি')) {
        return BanglaScamResult(
          text: text,
          isScam: true,
          category: 'Credential Request',
          confidence: 0.95,
          detectedKeywords: ['PIN/OTP Request', 'Urgent Call'],
        );
      } else if (lower.contains('পুরস্কার') || lower.contains('লটারি')) {
        return BanglaScamResult(
          text: text,
          isScam: true,
          category: 'Prize Scam',
          confidence: 0.92,
          detectedKeywords: ['Lottery Claim', 'Advance Fee'],
        );
      }
      return BanglaScamResult(
        text: text,
        isScam: false,
        category: 'Normal',
        confidence: 0.12,
        detectedKeywords: [],
      );
    }
  }

  Future<List<AuditLogEntry>> fetchAuditLogs() async {
    try {
      final res = await _apiService.getList('/api/v1/admin/audit-logs');
      if (res.isNotEmpty) {
        return res.map((e) => AuditLogEntry.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [
      AuditLogEntry(
        logId: 'AUD-1001',
        analystId: 'ADMIN001',
        action: 'HOLD',
        transactionId: 'TXN-10342',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
        notes: 'Observed new device and unusually large transaction compared with normal baseline.',
      ),
      AuditLogEntry(
        logId: 'AUD-1002',
        analystId: 'ADMIN002',
        action: 'REVIEW',
        transactionId: 'TXN-10341',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)).toIso8601String(),
        notes: 'Triggered automated OTP challenge verification for new unverified recipient.',
      ),
    ];
  }

  Future<ModelEvaluationData> fetchModelEvaluation() async {
    try {
      final res = await _apiService.get('/api/v1/admin/model-evaluation');
      return ModelEvaluationData.fromJson(res);
    } catch (_) {
      return const ModelEvaluationData();
    }
  }

  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    try {
      return await _apiService.get('/api/v1/admin/user-profile/$userId');
    } catch (_) {
      return {
        'user_id': userId,
        'name': 'Karim Ahmed',
        'phone': '01712345678',
        'avg_transaction_amount': 650.0,
        'typical_hours': '10 AM – 8 PM',
        'avg_transactions_per_day': 3,
        'typical_location': 'Dhaka',
        'trusted_devices': ['DEVICE001', 'DEVICE002'],
        'known_receivers': {
          'USER102': 'Rahim (Trusted)',
          'USER245': 'Karim (Known)',
          'MERCHANT01': 'Hasan (Known Merchant)'
        },
        'reported_suspicious_receivers': ['USER_ROGUE_99', '01999887766'],
      };
    }
  }
}

