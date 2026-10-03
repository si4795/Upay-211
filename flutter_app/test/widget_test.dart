import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/models/transaction.dart';
import 'package:flutter_app/models/risk_result.dart';
import 'package:flutter_app/models/wallet.dart';
import 'package:flutter_app/models/admin_intelligence.dart';
import 'package:flutter_app/services/risk_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/wallet_provider.dart';
import 'package:flutter_app/providers/transaction_provider.dart';
import 'package:flutter_app/screens/home/home_screen.dart';

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

    test('AuditLogEntry serializes and parses properly', () {
      final log = AuditLogEntry.fromJson({
        'log_id': 'AUD-1001',
        'analyst_id': 'ADMIN001',
        'action': 'HOLD',
        'transaction_id': 'TXN-10342',
        'timestamp': '2026-10-03T12:00:00',
        'notes': 'Observed new device and unusually large transaction.',
      });
      expect(log.logId, 'AUD-1001');
      expect(log.action, 'HOLD');
      expect(log.analystId, 'ADMIN001');
      expect(log.transactionId, 'TXN-10342');
    });

    test('ModelEvaluationData calculates synthetic metrics correctly', () {
      const eval = ModelEvaluationData();
      expect(eval.precision, greaterThanOrEqualTo(0.99));
      expect(eval.recall, 1.00);
      expect(eval.f1Score, greaterThan(0.99));
      expect(eval.rocAuc, 1.00);
      expect(eval.confusionMatrix['true_positive'], 240);
      expect(eval.confusionMatrix['false_positive'], 1);
      expect(eval.featuresRanked.length, 5);
    });
  });

  group('Track 01 — Trust & Risk Intelligence Engine & 4 Demo Scenarios', () {
    final riskService = RiskService();

    test('Scenario 1: Normal Transaction triggers LOW risk (<40) and ALLOW', () {
      final res = riskService.evaluateTransactionLocally(
        transactionId: 'TXN-NORM-01',
        amount: 500.0,
        receiverPhone: '01812345678',
        deviceId: 'DEVICE001',
        location: 'Dhaka',
        isNewDevice: false,
        isNewReceiver: false,
        failedAttempts: 0,
        transactionsLastHour: 0,
      );

      expect(res.riskScore, lessThanOrEqualTo(39));
      expect(res.riskScore, greaterThanOrEqualTo(0));
      expect(res.riskLevel, RiskLevel.low);
      expect(res.decision, RiskDecision.allow);
      expect(res.whatHappened, isNotEmpty);
      expect(res.whyRisky, isNotEmpty);
      expect(res.whatNext, isNotEmpty);
      expect(res.riskFactors, isNotEmpty);
    });

    test('Scenario 2: Suspicious Transfer triggers MEDIUM risk (40-69) and VERIFY', () {
      final res = riskService.evaluateTransactionLocally(
        transactionId: 'TXN-MED-02',
        amount: 8500.0,
        receiverPhone: '01799887766',
        deviceId: 'DEVICE001',
        location: 'Dhaka',
        isNewDevice: false,
        isNewReceiver: true,
        failedAttempts: 0,
        transactionsLastHour: 1,
      );

      expect(res.riskScore, greaterThanOrEqualTo(40));
      expect(res.riskScore, lessThanOrEqualTo(69));
      expect(res.riskLevel, RiskLevel.medium);
      expect(res.decision, RiskDecision.verify);
      expect(res.whatHappened, contains('8500'));
      expect(res.whyRisky, isNotEmpty);
      expect(res.whatNext, contains('ওটিপি'));
      expect(res.riskFactors.any((f) => f.feature == 'new_receiver'), isTrue);
    });

    test('Scenario 3: Account Takeover (ATO) / Mule triggers HIGH risk (70-100) and HOLD', () {
      final res = riskService.evaluateTransactionLocally(
        transactionId: 'TXN-ATO-03',
        amount: 24500.0,
        receiverPhone: '01900112233',
        deviceId: 'UNKNOWN_DEV_X99',
        location: 'Sylhet',
        isNewDevice: true,
        isNewReceiver: true,
        failedAttempts: 3,
        transactionsLastHour: 4,
      );

      expect(res.riskScore, greaterThanOrEqualTo(70));
      expect(res.riskScore, lessThanOrEqualTo(100));
      expect(res.riskLevel, RiskLevel.high);
      expect(res.decision, RiskDecision.hold);
      expect(res.whatHappened, contains('Sylhet'));
      expect(res.whyRisky, contains('অ্যাকাউন্ট টেকওভার'));
      expect(res.whatNext, contains('১৬২৬৮'));
      expect(res.riskFactors.any((f) => f.feature == 'device_change'), isTrue);
      expect(res.riskFactors.any((f) => f.feature == 'failed_attempts'), isTrue);
    });

    test('Scenario 4: Scam Text NLP detects Bangla credential fraud and prize scams', () async {
      // Credential scam
      final credRes = await riskService.analyzeScamText('upay সিকিউরিটি থেকে বলছি, আপনার অ্যাকাউন্টের পিন ও OTP দিন');
      expect(credRes.isScam, isTrue);
      expect(credRes.category, contains('Credential'));
      expect(credRes.confidence, greaterThanOrEqualTo(0.90));

      // Lottery/Prize scam
      final prizeRes = await riskService.analyzeScamText('অভিনন্দন! আপনি ৫০,০০০ টাকা লটারি জিতেছেন। এখনই টাকা গ্রহণ করুন');
      expect(prizeRes.isScam, isTrue);
      expect(prizeRes.category, contains('Lottery'));
      expect(prizeRes.confidence, greaterThanOrEqualTo(0.85));

      // Normal benign message
      final benignRes = await riskService.analyzeScamText('কালকে বিকাল ৫ টায় ক্যাম্পাসে দেখা করব।');
      expect(benignRes.isScam, isFalse);
    });

    test('RiskResult threshold helper functions adhere to 0-39, 40-69, 70-100', () {
      expect(RiskResult.levelFromScore(0), RiskLevel.low);
      expect(RiskResult.levelFromScore(39), RiskLevel.low);
      expect(RiskResult.levelFromScore(40), RiskLevel.medium);
      expect(RiskResult.levelFromScore(69), RiskLevel.medium);
      expect(RiskResult.levelFromScore(70), RiskLevel.high);
      expect(RiskResult.levelFromScore(100), RiskLevel.high);
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

  group('Mobile Viewport & Responsive UI Tests', () {
    const viewports = [
      Size(360, 640),
      Size(375, 667),
      Size(390, 844),
      Size(400, 642), // Exact user-reported viewport
    ];

    for (final size in viewports) {
      testWidgets('Home screen renders without RenderFlex overflow at ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => AuthProvider()),
              ChangeNotifierProvider(create: (_) => WalletProvider()),
              ChangeNotifierProvider(create: (_) => TransactionProvider()),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const HomeScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Home screen service items are present and rendered
        expect(find.text('সেন্ড মানি'), findsOneWidget);
        expect(find.text('মোবাইল রিচার্জ'), findsOneWidget);
        expect(find.text('ক্যাশ আউট'), findsOneWidget);
        expect(find.text('পে বিল'), findsOneWidget);
        expect(find.text('অ্যাড মানি'), findsOneWidget);
        expect(find.text('সঞ্চয়'), findsOneWidget);
        expect(find.text('ফান্ড ট্রান্সফার'), findsOneWidget);
        expect(find.text('রিকোয়েস্ট মানি'), findsOneWidget);

        // Verify no RenderFlex overflow exception was thrown
        expect(tester.takeException(), isNull);
      });
    }
  });
}
