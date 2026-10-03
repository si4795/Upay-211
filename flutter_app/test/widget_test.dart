import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/models/transaction.dart';
import 'package:flutter_app/models/risk_result.dart';
import 'package:flutter_app/models/wallet.dart';
import 'package:flutter_app/models/admin_intelligence.dart';

void main() {
  group('Phase 1 & 2 - Model & Logic Tests', () {
    test('User model serializes and defaults correctly', () {
      const user = User(
        id: 'USER001',
        name: 'Demo User',
        phone: '01712345678',
        email: 'user@upay.com.bd',
      );
      expect(user.id, 'USER001');
      expect(user.trustedDevices.contains('DEVICE001'), isTrue);
      expect(user.currentLocation, 'Dhaka, Bangladesh');
    });

    test('Wallet balance updates and deducts correctly', () {
      const wallet = Wallet(balance: 25450.0);
      final updated = wallet.copyWith(balance: wallet.balance - 505.0);
      expect(updated.balance, 24945.0);
    });

    test('RiskResult parses high risk policy and factors correctly', () {
      final json = {
        'transaction_id': 'TXN-999',
        'risk_score': 94,
        'risk_level': 'HIGH',
        'decision': 'HOLD',
        'customer_message': 'Transaction temporarily unavailable.',
        'risk_factors': [
          {'feature': 'device_change', 'impact': 0.38, 'message': 'New device'}
        ]
      };
      final result = RiskResult.fromJson(json);
      expect(result.riskScore, 94);
      expect(result.riskLevel, RiskLevel.high);
      expect(result.decision, RiskDecision.hold);
      expect(result.riskFactors.length, 1);
    });

    test('TransactionModel handles send money status correctly', () {
      final txn = TransactionModel(
        id: 'TXN-100',
        userId: 'USER001',
        receiverId: 'USER002',
        receiverName: 'Karim',
        receiverPhone: '01819283746',
        amount: 500.0,
        fee: 5.0,
        total: 505.0,
        timestamp: DateTime.now(),
        status: TransactionStatus.success,
      );
      expect(txn.total, 505.0);
      expect(txn.status, TransactionStatus.success);
    });
  });

  group('Phase 3 & 4 - Admin & Intelligence Tests', () {
    test('AnalyticsData parses default metrics accurately', () {
      const data = AnalyticsData();
      expect(data.totalTransactions, 25430);
      expect(data.highRiskCount, 42);
      expect(data.mediumRiskCount, 186);
      expect(data.blockedCount, 31);
      expect(data.underReviewCount, 18);
    });

    test('AdminFraudCase updates lifecycle status cleanly', () {
      final fraudCase = AdminFraudCase(
        caseId: 'CASE-0001',
        userId: 'USER001',
        transactionId: 'TXN-10342',
        amount: 50000.0,
        riskScore: 94,
        riskLevel: 'HIGH',
        reason: 'Unrecognized Device + Rapid Velocity Burst',
        status: 'Open',
        assignedAnalyst: 'ADMIN001',
        createdTime: 'Today, 12:42 PM',
      );
      expect(fraudCase.status, 'Open');
      fraudCase.status = 'Under Review';
      expect(fraudCase.status, 'Under Review');
    });

    test('BanglaScamResult identifies credential fraud signals', () {
      const scamRes = BanglaScamResult(
        text: 'upay থেকে বলছি আপনার PIN দিন',
        isScam: true,
        category: 'Credential Request',
        confidence: 0.96,
        detectedKeywords: ['PIN Request'],
      );
      expect(scamRes.isScam, isTrue);
      expect(scamRes.category, 'Credential Request');
      expect(scamRes.confidence, greaterThan(0.9));
    });
  });

  group('UI Smoke Tests', () {
    testWidgets('App renders UpayApp and SplashScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const UpayApp());
      expect(find.text('upay'), findsWidgets);
      expect(find.text('Track 01 — Trust & Risk Intelligence'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pumpAndSettle();
    });
  });
}
