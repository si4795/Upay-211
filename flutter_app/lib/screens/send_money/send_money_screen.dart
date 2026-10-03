import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/transaction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/loading_overlay.dart';

class SendMoneyScreen extends StatefulWidget {
  final double? initialAmount;
  final String? initialReceiverPhone;
  final String? initialReceiverName;
  final bool isNewDeviceSimulation;

  const SendMoneyScreen({
    super.key,
    this.initialAmount,
    this.initialReceiverPhone,
    this.initialReceiverName,
    this.isNewDeviceSimulation = false,
  });

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  int _currentStep = 1; // 1: Receiver, 2: Amount, 3: PIN, 4: Review, 6: Result

  final TextEditingController _receiverPhoneController = TextEditingController();
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  TransactionModel? _resultTxn;

  // Preset demo contacts for easy testing
  final List<Map<String, String>> _frequentRecipients = [
    {'name': 'Karim Ahmed', 'phone': '01819283746', 'type': 'বন্ধু (Trusted)'},
    {'name': 'Anisur Rahman', 'phone': '01799887766', 'type': 'অপরিচিত (New Recipient)'},
    {'name': 'Mule Syndicate Account', 'phone': '01911002299', 'type': 'সন্দেহভাজন (Mule Flag)'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialReceiverPhone != null) {
      _receiverPhoneController.text = widget.initialReceiverPhone!;
      _receiverNameController.text = widget.initialReceiverName ?? 'Recipient';
    }
    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _receiverPhoneController.dispose();
    _receiverNameController.dispose();
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  double get _parsedAmount => double.tryParse(_amountController.text.trim()) ?? 0.0;
  double get _fee => 5.0;
  double get _total => _parsedAmount + _fee;

  void _onSelectContact(Map<String, String> contact) {
    setState(() {
      _receiverNameController.text = contact['name']!;
      _receiverPhoneController.text = contact['phone']!;
    });
  }

  void _proceedToStep2() {
    final phone = _receiverPhoneController.text.trim();
    if (phone.length < 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুগ্রহ করে সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন'),
          backgroundColor: UpayColors.riskHigh,
        ),
      );
      return;
    }
    if (_receiverNameController.text.trim().isEmpty) {
      _receiverNameController.text = 'Receiver (${phone.substring(phone.length - 4)})';
    }
    setState(() => _currentStep = 2);
  }

  void _proceedToStep3() {
    final wallet = context.read<WalletProvider>();
    if (_parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুগ্রহ করে টাকার পরিমাণ দিন'),
          backgroundColor: UpayColors.riskHigh,
        ),
      );
      return;
    }
    if (_total > wallet.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('অপর্যাপ্ত ব্যালেন্স। বর্তমান ব্যালেন্স: ${Formatters.currency(wallet.balance)}'),
          backgroundColor: UpayColors.riskHigh,
        ),
      );
      return;
    }
    setState(() => _currentStep = 3);
  }

  void _proceedToStep4() {
    if (_pinController.text.trim().length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('৪ ডিজিটের পিন কোড দিন'),
          backgroundColor: UpayColors.riskHigh,
        ),
      );
      return;
    }
    setState(() => _currentStep = 4);
  }

  void _executeTransaction() async {
    final auth = context.read<AuthProvider>();
    final wallet = context.read<WalletProvider>();
    final txnProvider = context.read<TransactionProvider>();

    final user = auth.user;
    final isNewReceiver = _receiverPhoneController.text.trim() != '01819283746';

    final result = await txnProvider.executeSendMoney(
      userId: user?.id ?? 'USER001',
      receiverPhone: _receiverPhoneController.text.trim(),
      receiverName: _receiverNameController.text.trim(),
      amount: _parsedAmount,
      deviceId: widget.isNewDeviceSimulation ? 'DEVICE009' : (user?.currentDeviceId ?? 'DEVICE001'),
      location: widget.isNewDeviceSimulation ? 'Chattogram' : (user?.currentLocation ?? 'Dhaka'),
      isNewDevice: widget.isNewDeviceSimulation,
      isNewReceiver: isNewReceiver,
    );

    if (result != null) {
      if (result.status == TransactionStatus.success) {
        wallet.deductAmount(_total);
      }
      setState(() {
        _resultTxn = result;
        _currentStep = 6; // Jump directly to outcome
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = context.watch<TransactionProvider>().isProcessing;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: UpayColors.bgLight,
          appBar: AppBar(
            title: Text(
              'সেন্ড মানি (Send Money)',
              style: GoogleFonts.hindSiliguri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: LinearProgressIndicator(
                value: _currentStep <= 4 ? _currentStep / 4 : 1.0,
                backgroundColor: UpayColors.primaryDark,
                valueColor: const AlwaysStoppedAnimation<Color>(UpayColors.accentYellow),
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: switch (_currentStep) {
                1 => _buildStep1Receiver(),
                2 => _buildStep2Amount(),
                3 => _buildStep3Pin(),
                4 => _buildStep4Review(),
                _ => _buildStep6Result(),
              },
            ),
          ),
        ),
        if (isProcessing)
          const SecureLoadingOverlay(
            message: 'Processing your transaction securely...',
          ),
      ],
    );
  }

  // Step 1: Receiver Number
  Widget _buildStep1Receiver() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'প্রাপকের নম্বর দিন',
          style: GoogleFonts.hindSiliguri(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: UpayColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'যাকে টাকা পাঠাতে চান তার মোবাইল নম্বর লিখুন',
          style: GoogleFonts.hindSiliguri(
            fontSize: 13,
            color: UpayColors.textMuted,
          ),
        ),
        const SizedBox(height: 20),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _receiverPhoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    labelText: 'প্রাপকের নম্বর',
                    hintText: '01XXXXXXXXX',
                    prefixIcon: Icon(Icons.phone, color: UpayColors.primaryBlue),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _receiverNameController,
                  style: GoogleFonts.hindSiliguri(fontSize: 15),
                  decoration: const InputDecoration(
                    labelText: 'নাম (ঐচ্ছিক)',
                    hintText: 'প্রাপকের নাম',
                    prefixIcon: Icon(Icons.person_outline, color: UpayColors.primaryBlue),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        Text(
          'ডেমো প্রাপক তালিকা (Quick Test Contacts)',
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: UpayColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        ..._frequentRecipients.map((c) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: UpayColors.borderSubtle),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: UpayColors.primaryBlue,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              title: Text(c['name']!, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
              subtitle: Text('${c['phone']} • ${c['type']}', style: GoogleFonts.inter(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: UpayColors.textMuted),
              onTap: () => _onSelectContact(c),
            ),
          );
        }),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _proceedToStep2,
            child: Text(
              'পরবর্তী ধাপ (Next)',
              style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // Step 2: Amount
  Widget _buildStep2Amount() {
    final balance = context.read<WalletProvider>().balance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'টাকার পরিমাণ দিন',
              style: GoogleFonts.hindSiliguri(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: UpayColors.textDark,
              ),
            ),
            Text(
              'ব্যালেন্স: ${Formatters.currency(balance)}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: UpayColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '৳',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: UpayColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: UpayColors.primaryBlue,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  'সেন্ড মানি চার্জ: ৳৫.০০',
                  style: GoogleFonts.hindSiliguri(fontSize: 12, color: UpayColors.textMuted),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        Text(
          'ট্র্যাক ০১ ডেমো সিনারিও প্রিসেটসমূহ (Demo Scenarios)',
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: UpayColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              avatar: const Icon(Icons.check_circle_outline, color: UpayColors.riskLow, size: 18),
              label: Text('৳500 (Scenario 1 - Normal)', style: GoogleFonts.inter(fontSize: 12)),
              backgroundColor: Colors.white,
              onPressed: () => setState(() => _amountController.text = '500'),
            ),
            ActionChip(
              avatar: const Icon(Icons.warning_amber_rounded, color: UpayColors.riskMedium, size: 18),
              label: Text('৳8,000 (Scenario 2 - Suspicious)', style: GoogleFonts.inter(fontSize: 12)),
              backgroundColor: Colors.white,
              onPressed: () => setState(() => _amountController.text = '8000'),
            ),
            ActionChip(
              avatar: const Icon(Icons.error_outline, color: UpayColors.riskHigh, size: 18),
              label: Text('৳50,000 (Scenario 3 - High Risk)', style: GoogleFonts.inter(fontSize: 12)),
              backgroundColor: Colors.white,
              onPressed: () => setState(() => _amountController.text = '50000'),
            ),
          ],
        ),

        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text('পূর্ববর্তী (Back)', style: GoogleFonts.hindSiliguri(fontSize: 15)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _proceedToStep3,
                child: Text(
                  'পরবর্তী ধাপ (Next)',
                  style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Step 3: Enter PIN
  Widget _buildStep3Pin() {
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 52,
      textStyle: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: UpayColors.primaryBlue,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UpayColors.borderSubtle, width: 1.5),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'আপনার গোপন পিন (PIN) দিন',
          style: GoogleFonts.hindSiliguri(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: UpayColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'লেনদেন নিশ্চিত করতে ৪ ডিজিটের পিন নম্বর প্রবেশ করান',
          style: GoogleFonts.hindSiliguri(
            fontSize: 13,
            color: UpayColors.textMuted,
          ),
        ),
        const SizedBox(height: 28),

        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                Pinput(
                  controller: _pinController,
                  length: 4,
                  obscureText: true,
                  obscuringCharacter: '●',
                  autofocus: true,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: UpayColors.primaryBlue, width: 2),
                    ),
                  ),
                  onCompleted: (_) => _proceedToStep4(),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, size: 14, color: UpayColors.textLight),
                    const SizedBox(width: 6),
                    Text(
                      'পিন নম্বর সম্পূর্ণভাবে এনক্রিপ্ট করা থাকে',
                      style: GoogleFonts.hindSiliguri(fontSize: 11, color: UpayColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 2),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text('পূর্ববর্তী (Back)', style: GoogleFonts.hindSiliguri(fontSize: 15)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _proceedToStep4,
                child: Text(
                  'যাচাই ও রিভিউ (Review)',
                  style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Step 4: Review
  Widget _buildStep4Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'লেনদেনের বিবরণ নিশ্চিত করুন',
          style: GoogleFonts.hindSiliguri(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: UpayColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'টাকা পাঠানোর পূর্বে প্রাপক ও টাকার পরিমাণ মিলিয়ে নিন',
          style: GoogleFonts.hindSiliguri(
            fontSize: 13,
            color: UpayColors.textMuted,
          ),
        ),
        const SizedBox(height: 20),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildReviewRow('প্রাপক', _receiverNameController.text),
                const Divider(height: 24),
                _buildReviewRow('মোবাইল নম্বর', _receiverPhoneController.text),
                const Divider(height: 24),
                _buildReviewRow('টাকার পরিমাণ', Formatters.currency(_parsedAmount)),
                const Divider(height: 24),
                _buildReviewRow('চার্জ (Fee)', Formatters.currency(_fee)),
                const Divider(height: 24),
                _buildReviewRow('সর্বমোট (Total)', Formatters.currency(_total), isBold: true),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _executeTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: UpayColors.primaryBlue,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send_rounded, color: UpayColors.accentYellow),
                const SizedBox(width: 10),
                Text(
                  'টাকা পাঠাতে ট্যাপ করুন (Send)',
                  style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _currentStep = 2),
            child: Text(
              'পরিবর্তন করুন (Edit Details)',
              style: GoogleFonts.hindSiliguri(color: UpayColors.textMuted),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? UpayColors.textDark : UpayColors.textMuted,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isBold ? 17 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? UpayColors.primaryBlue : UpayColors.textDark,
          ),
        ),
      ],
    );
  }

  // Step 6: Customer-facing Result Screen (NEVER shows internal risk score!)
  Widget _buildStep6Result() {
    final txn = _resultTxn;
    if (txn == null) return const SizedBox.shrink();

    // Determine customer-safe styling
    final (IconData icon, Color color, String title, String subtitle) = switch (txn.status) {
      TransactionStatus.success => (
          Icons.check_circle_rounded,
          UpayColors.riskLow,
          'টাকা পাঠানো সফল হয়েছে',
          '${Formatters.currency(txn.amount)} সফলভাবে প্রেরিত হয়েছে।'
        ),
      TransactionStatus.verifyRequired => (
          Icons.verified_user_outlined,
          UpayColors.riskMedium,
          'অতিরিক্ত যাচাই প্রয়োজন',
          'আপনার অ্যাকাউন্টের নিরাপত্তার স্বার্থে লেনদেনটি সম্পন্ন করতে অতিরিক্ত যাচাইকরণ প্রয়োজন।'
        ),
      TransactionStatus.hold || TransactionStatus.blocked => (
          Icons.shield_outlined,
          UpayColors.riskHigh,
          'লেনদেনটি সাময়িকভাবে স্থগিত',
          'আপনার সুরক্ষার স্বার্থে এই লেনদেনটি অতিরিক্ত পর্যালোচনার জন্য সাময়িকভাবে স্থগিত রাখা হয়েছে।'
        ),
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 50),
          ),
          const SizedBox(height: 20),

          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.hindSiliguri(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: UpayColors.textDark,
            ),
          ),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                color: UpayColors.textMuted,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Standard Customer Receipt Card (No risk scores!)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildReviewRow('ট্রানজেকশন আইডি', txn.id),
                  const Divider(height: 20),
                  _buildReviewRow('প্রাপক', txn.receiverName),
                  const Divider(height: 20),
                  _buildReviewRow('প্রাপক নম্বর', txn.receiverPhone),
                  const Divider(height: 20),
                  _buildReviewRow('পরিমাণ', Formatters.currency(txn.amount)),
                  const Divider(height: 20),
                  _buildReviewRow('সময়', Formatters.formatTimestamp(txn.timestamp)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'সম্পন্ন (Done)',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

