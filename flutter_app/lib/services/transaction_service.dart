import 'dart:math';
import '../models/transaction.dart';
import '../models/risk_result.dart';
import 'risk_service.dart';

class TransactionService {
  final RiskService _riskService;
  final List<TransactionModel> _transactions = [];

  TransactionService({RiskService? riskService})
      : _riskService = riskService ?? RiskService() {
    _seedInitialTransactions();
  }

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  void _seedInitialTransactions() {
    final now = DateTime.now();
    _transactions.addAll([
      TransactionModel(
        id: 'TXN-89211',
        userId: 'USER001',
        receiverId: 'USER102',
        receiverName: 'Karim Ahmed',
        receiverPhone: '01819283746',
        amount: 500.0,
        fee: 5.0,
        total: 505.0,
        timestamp: now.subtract(const Duration(hours: 1)),
        type: TransactionType.sendMoney,
        status: TransactionStatus.success,
        customerMessage: 'টাকা পাঠানো সফল হয়েছে',
        riskResult: const RiskResult(
          transactionId: 'TXN-89211',
          riskScore: 12,
          riskLevel: RiskLevel.low,
          decision: RiskDecision.allow,
          customerMessage: 'টাকা পাঠানো সফল হয়েছে',
          riskFactors: [
            RiskFactor(feature: 'trusted_device', impact: 0.05, message: 'স্বীকৃত প্রাইমারি ডিভাইস (DEVICE001)'),
            RiskFactor(feature: 'regular_location', impact: 0.04, message: 'স্বাভাবিক অবস্থান (ঢাকা)'),
          ],
          whatHappened: 'পরিচিত প্রাপক করিম আহমেদকে ৳৫০০ সফলভাবে পাঠানো হয়েছে।',
          whyRisky: 'লেনদেন সম্পূর্ণ নিরাপদ। ট্রাস্ট স্কোর উচ্চ (৯৮/১০০)।',
          whatNext: 'কোনো অতিরিক্ত পদক্ষেপের প্রয়োজন নেই।',
        ),
      ),
      TransactionModel(
        id: 'TXN-89100',
        userId: 'USER001',
        receiverId: 'USER304',
        receiverName: 'Anisur Rahman',
        receiverPhone: '01799887766',
        amount: 8500.0,
        fee: 5.0,
        total: 8505.0,
        timestamp: now.subtract(const Duration(hours: 4)),
        type: TransactionType.sendMoney,
        status: TransactionStatus.verifyRequired,
        customerMessage: 'অতিরিক্ত যাচাই সম্পন্ন হয়েছে',
        riskResult: const RiskResult(
          transactionId: 'TXN-89100',
          riskScore: 56,
          riskLevel: RiskLevel.medium,
          decision: RiskDecision.verify,
          customerMessage: 'অতিরিক্ত যাচাই সম্পন্ন হয়েছে',
          riskFactors: [
            RiskFactor(feature: 'new_receiver', impact: 0.42, message: 'নতুন প্রাপক নম্বর (First-time transfer)'),
            RiskFactor(feature: 'amount_deviation', impact: 0.30, message: 'দৈনন্দিন গড়ের তুলনায় বেশি অংক (৳৮,৫০০)'),
          ],
          whatHappened: 'নতুন প্রাপককে ৳৮,৫০০ পাঠানোর সময় অতিরিক্ত ভেরিফিকেশন চাওয়া হয়।',
          whyRisky: 'পূর্বে কখনো এই নম্বরে টাকা পাঠানো হয়নি এবং স্বাভাবিক গড়ের চেয়ে বড় অংক।',
          whatNext: 'ভবিষ্যত সুরক্ষায় প্রাপকের তথ্য সেভ করার পূর্বে পুনরায় মিলিয়ে নিন।',
        ),
      ),
      TransactionModel(
        id: 'TXN-88980',
        userId: 'USER001',
        receiverId: 'USER_MULE_X',
        receiverName: 'Unknown Account',
        receiverPhone: '01911002299',
        amount: 50000.0,
        fee: 5.0,
        total: 50005.0,
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        type: TransactionType.sendMoney,
        status: TransactionStatus.hold,
        customerMessage: 'লেনদেনটি সুরক্ষার্থে সাময়িক স্থগিত রাখা হয়েছে',
        deviceId: 'DEVICE009',
        location: 'Chattogram',
        riskResult: const RiskResult(
          transactionId: 'TXN-88980',
          riskScore: 94,
          riskLevel: RiskLevel.high,
          decision: RiskDecision.hold,
          customerMessage: 'লেনদেনটি সুরক্ষার্থে সাময়িক স্থগিত রাখা হয়েছে',
          riskFactors: [
            RiskFactor(feature: 'device_change', impact: 0.38, message: 'অপরিচিত ডিভাইস শনাক্ত (DEVICE009)'),
            RiskFactor(feature: 'amount_deviation', impact: 0.32, message: 'ব্যবহারকারীর স্বাভাবিক গড়ের চেয়ে অস্বাভাবিক বড় অংক (+৳৫০,০০০)'),
            RiskFactor(feature: 'location_change', impact: 0.22, message: 'চট্টগ্রাম থেকে হঠাৎ অপ্রত্যাশিত ট্রানজেকশন অনুরোধ'),
          ],
          whatHappened: 'নতুন ডিভাইস থেকে রাত ৩:১৫ এ ৳৫০,০০০ সেন্ড মানির অনুরোধ আসে।',
          whyRisky: 'অ্যাকাউন্ট টেকওভার (ATO) প্যাটার্ন মিলেছে। ডিভাইস অমিল, অবস্থান পরিবর্তন এবং চরম পরিমাণ বিচ্যুতি।',
          whatNext: '১. লেনদেন স্থগিত রয়েছে।\n২. আপনি না করে থাকলে অবিলম্বে অ্যাকাউন্ট ফ্রিজ করুন।\n৩. ১৬২৬৮ নম্বরে যোগাযোগ করুন।',
        ),
      ),
      TransactionModel(
        id: 'TXN-89190',
        userId: 'USER001',
        receiverId: 'MERCHANT01',
        receiverName: 'Shwapno Supershop',
        receiverPhone: '01711223344',
        amount: 1450.0,
        fee: 0.0,
        total: 1450.0,
        timestamp: now.subtract(const Duration(hours: 8)),
        type: TransactionType.payBill,
        status: TransactionStatus.success,
        customerMessage: 'বিল সফলভাবে পরিশোধিত হয়েছে',
        riskResult: const RiskResult(
          transactionId: 'TXN-89190',
          riskScore: 8,
          riskLevel: RiskLevel.low,
          decision: RiskDecision.allow,
          customerMessage: 'বিল সফলভাবে পরিশোধিত হয়েছে',
          riskFactors: [
            RiskFactor(feature: 'verified_merchant', impact: 0.02, message: 'ভেরিফায়েড মার্চেন্ট অ্যাকাউন্ট'),
          ],
          whatHappened: 'মার্চেন্ট বিল পেমেন্ট ৳১,৪৫০ সম্পন্ন।',
          whyRisky: 'সম্পূর্ণ নিরাপদ মার্চেন্ট লেনদেন।',
          whatNext: 'কোনো পদক্ষেপের প্রয়োজন নেই।',
        ),
      ),
      TransactionModel(
        id: 'TXN-88902',
        userId: 'USER001',
        receiverId: 'AGENT402',
        receiverName: 'Agent Cashout (Uttara)',
        receiverPhone: '01511223344',
        amount: 5000.0,
        fee: 75.0,
        total: 5075.0,
        timestamp: now.subtract(const Duration(days: 3)),
        type: TransactionType.cashOut,
        status: TransactionStatus.success,
        customerMessage: 'ক্যাশ আউট সম্পন্ন',
        riskResult: const RiskResult(
          transactionId: 'TXN-88902',
          riskScore: 18,
          riskLevel: RiskLevel.low,
          decision: RiskDecision.allow,
          customerMessage: 'ক্যাশ আউট সম্পন্ন',
          riskFactors: [
            RiskFactor(feature: 'verified_agent', impact: 0.04, message: 'নিবন্ধিত অনুমোদিত এজেন্ট পয়েন্ট'),
          ],
          whatHappened: 'উত্তরা এজেন্ট পয়েন্টে ৳৫,০০০ ক্যাশ আউট।',
          whyRisky: 'নিয়মিত অবস্থানের অনুমোদিত এজেন্ট।',
          whatNext: 'লেনদেন নিরাপদ।',
        ),
      ),
    ]);
  }

  Future<TransactionModel> processSendMoney({
    required String userId,
    required String receiverPhone,
    required String receiverName,
    required double amount,
    required String deviceId,
    required String location,
    bool isNewDevice = false,
    bool isNewReceiver = false,
    int failedAttempts = 0,
  }) async {
    final txnId = 'TXN-${10000 + Random().nextInt(90000)}';
    
    // Evaluate risk behind the scenes
    final riskResult = await _riskService.evaluateTransaction(
      transactionId: txnId,
      userId: userId,
      receiverId: 'USER_${receiverPhone.substring(max(0, receiverPhone.length - 4))}',
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      amount: amount,
      deviceId: deviceId,
      location: location,
      isNewDevice: isNewDevice,
      isNewReceiver: isNewReceiver,
      failedAttempts: failedAttempts,
    );

    TransactionStatus status;
    switch (riskResult.decision) {
      case RiskDecision.allow:
        status = TransactionStatus.success;
        break;
      case RiskDecision.verify:
        status = TransactionStatus.verifyRequired;
        break;
      case RiskDecision.hold:
        status = TransactionStatus.hold;
        break;
      case RiskDecision.block:
        status = TransactionStatus.blocked;
        break;
    }

    final newTxn = TransactionModel(
      id: txnId,
      userId: userId,
      receiverId: 'USER_${receiverPhone.substring(max(0, receiverPhone.length - 4))}',
      receiverName: receiverName.isNotEmpty ? receiverName : 'Recipient',
      receiverPhone: receiverPhone,
      amount: amount,
      fee: 5.0,
      total: amount + 5.0,
      timestamp: DateTime.now(),
      type: TransactionType.sendMoney,
      status: status,
      customerMessage: riskResult.customerMessage,
      deviceId: deviceId,
      location: location,
      riskResult: riskResult,
    );

    _transactions.insert(0, newTxn);
    return newTxn;
  }
}

