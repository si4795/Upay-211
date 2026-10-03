import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/admin_intelligence.dart';
import '../../providers/auth_provider.dart';
import '../../services/risk_service.dart';

class TrustAndSafetyCenterScreen extends StatefulWidget {
  const TrustAndSafetyCenterScreen({super.key});

  @override
  State<TrustAndSafetyCenterScreen> createState() => _TrustAndSafetyCenterScreenState();
}

class _TrustAndSafetyCenterScreenState extends State<TrustAndSafetyCenterScreen> {
  final RiskService _riskService = RiskService();
  final TextEditingController _scamTextController = TextEditingController();

  BanglaScamResult? _scamResult;
  bool _isAnalyzingScam = false;

  final List<String> _presetScamTexts = [
    'upay থেকে বলছি আপনার PIN দিন, নয়তো একাউন্ট বন্ধ হবে।',
    'অভিনন্দন! আপনি ৫০,০০০ টাকা লটারি জিতেছেন, ভেরিফিকেশন ফি দিন।',
    'জরুরি নোটিশ: আপনার OTP কোড কনফার্ম করুন অবিলম্বে।',
    'ভাইয়া কেমন আছেন? কালকের মিটিং কয়টায় শুরু হবে?',
  ];

  @override
  void dispose() {
    _scamTextController.dispose();
    super.dispose();
  }

  void _runScamAnalysis(String text) async {
    if (text.trim().isEmpty) return;
    setState(() => _isAnalyzingScam = true);
    final result = await _riskService.analyzeScamText(text.trim());
    if (mounted) {
      setState(() {
        _scamResult = result;
        _isAnalyzingScam = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: UpayColors.bgLight,
      appBar: AppBar(
        backgroundColor: UpayColors.primaryBlue,
        foregroundColor: Colors.white,
        title: Text(
          'ট্রাস্ট অ্যান্ড সেফটি সেন্টার',
          style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Account Trust Information Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [UpayColors.primaryBlue, Color(0xFF133E68)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: UpayColors.primaryBlue.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'অ্যাকাউন্ট ট্রাস্ট স্কোর',
                            style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.white70),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '৯৮ / ১০০ (সুরক্ষিত)',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: UpayColors.accentYellow,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: UpayColors.riskLow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: UpayColors.riskLow),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, color: UpayColors.riskLow, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'AI Shield Active',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  Text(
                    'upay AI Trust Engine আপনার লেনদেনের নিরাপত্তা সার্বক্ষণিক বিশ্লেষণ করছে। কোনো অস্বাভাবিক আচরণ লক্ষ্য করলে সিস্টেম স্বয়ংক্রিয়ভাবে অ্যাকাউন্ট সুরক্ষা পদক্ষেপ গ্রহণ করে।',
                    style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.white70, height: 1.35),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Account Takeover (ATO) Protection
            Text(
              'অ্যাকাউন্ট টেকওভার (ATO) প্রোটেকশন',
              style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: UpayColors.textDark),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: UpayColors.borderSubtle),
              ),
              child: Column(
                children: [
                  _buildStatusRow(
                    icon: Icons.smartphone_rounded,
                    title: 'নিবন্ধিত প্রাইমারি ডিভাইস',
                    value: user?.currentDeviceId ?? 'DEVICE001 (Samsung Galaxy)',
                    isOk: true,
                  ),
                  const Divider(height: 20),
                  _buildStatusRow(
                    icon: Icons.location_on_outlined,
                    title: 'স্বাভাবিক ভৌগোলিক অবস্থান',
                    value: user?.currentLocation ?? 'ঢাকা, বাংলাদেশ',
                    isOk: true,
                  ),
                  const Divider(height: 20),
                  _buildStatusRow(
                    icon: Icons.security_outlined,
                    title: 'লগইন ব্যর্থতা ও ব্রুট-ফোর্স নজরদারি',
                    value: '০ বার ভুল পিন (নিরাপদ)',
                    isOk: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Behavioral Anomaly Baseline
            Text(
              'আচরণগত অস্বাভাবিকতা পর্যবেক্ষণ (Behavioral Baseline)',
              style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: UpayColors.textDark),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: UpayColors.borderSubtle),
              ),
              child: Column(
                children: [
                  _buildBaselineRow('ঐতিহাসিক গড় লেনদেন', '৳৬৫০.০০ (স্বাভাবিক সীমা: ৳১০০ - ৳৫,০০০)'),
                  const Divider(height: 16),
                  _buildBaselineRow('সক্রিয় লেনদেনের স্বাভাবিক সময়', 'সকাল ১০:০০ - রাত ৯:০০ ঘটিকা'),
                  const Divider(height: 16),
                  _buildBaselineRow('দৈনন্দিন লেনদেন গতি (Velocity)', 'গড়ে ২-৩ টি লেনদেন প্রতি দিন'),
                  const Divider(height: 16),
                  _buildBaselineRow('অ্যানোমালি ডিটেকশন মডেল', 'Isolation Forest Unsupervised AI (Active)'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4. Scam Text Intelligence (Interactive Live Demo for Scenario 4)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'স্ক্যাম টেক্সট ইন্টেলিজেন্স (বাংলা NLP)',
                  style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: UpayColors.textDark),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: UpayColors.accentYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ডেমো সিনারিও ৪',
                    style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: UpayColors.primaryDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'সন্দেহজনক মেসেজ বা অফার পেস্ট করে স্ক্যাম ও ফিশিং ঝুঁকি যাচাই করুন:',
              style: GoogleFonts.hindSiliguri(fontSize: 12, color: UpayColors.textMuted),
            ),
            const SizedBox(height: 10),

            // Scam Input & Preset Chips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: UpayColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _scamTextController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'মেসেজটি এখানে লিখুন বা পেস্ট করুন...',
                      hintStyle: GoogleFonts.hindSiliguri(fontSize: 13, color: UpayColors.textLight),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Preset chip shortcuts
                  Text(
                    'নমুনা স্ক্যাম মেসেজ ট্যাপ করুন:',
                    style: GoogleFonts.hindSiliguri(fontSize: 11, color: UpayColors.textMuted, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _presetScamTexts.map((text) {
                      return ActionChip(
                        label: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
                        labelStyle: GoogleFonts.hindSiliguri(fontSize: 11),
                        backgroundColor: UpayColors.bgLight,
                        onPressed: () {
                          _scamTextController.text = text;
                          _runScamAnalysis(text);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzingScam ? null : () => _runScamAnalysis(_scamTextController.text),
                      icon: _isAnalyzingScam
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.analytics_outlined, size: 18),
                      label: Text(
                        _isAnalyzingScam ? 'বিশ্লেষণ চলছে...' : 'AI স্ক্যাম বিশ্লেষণ করুন',
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UpayColors.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                  // Result display
                  if (_scamResult != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _scamResult!.isScam ? UpayColors.riskHigh.withOpacity(0.08) : UpayColors.riskLow.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _scamResult!.isScam ? UpayColors.riskHigh : UpayColors.riskLow,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _scamResult!.isScam ? Icons.warning_rounded : Icons.check_circle_rounded,
                                color: _scamResult!.isScam ? UpayColors.riskHigh : UpayColors.riskLow,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _scamResult!.isScam ? 'সতর্কতা: সম্ভাব্য প্রতারণা শনাক্ত!' : 'নিরাপদ বার্তা',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _scamResult!.isScam ? UpayColors.riskHigh : UpayColors.riskLow,
                                  ),
                                ),
                              ),
                              Text(
                                '${(_scamResult!.confidence * 100).toStringAsFixed(0)}% আত্মবিশ্বাস',
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'ধরন: ${_scamResult!.category}',
                            style: GoogleFonts.hindSiliguri(fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                          if (_scamResult!.detectedKeywords.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'শনাক্ত কীওয়ার্ড: ${_scamResult!.detectedKeywords.join(", ")}',
                              style: GoogleFonts.hindSiliguri(fontSize: 11.5, color: UpayColors.textMuted),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            _scamResult!.isScam
                                ? 'পরামর্শ: কখনোই অপরিচিত কাউকে আপনার পিন (PIN) বা ওটিপি (OTP) শেয়ার করবেন না। প্রয়োজনে ১৬২৬৮ হেল্পলাইনে যোগাযোগ করুন।'
                                : 'পরামর্শ: বার্তাটিতে কোনো ফিশিং বা পিন দাবির সংকেত পাওয়া যায়নি।',
                            style: GoogleFonts.hindSiliguri(fontSize: 11.5, color: UpayColors.textDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5. Suspicious Network & Money-Mule Discovery
            Text(
              'সন্দেহজনক নেটওয়ার্ক ও মানি-মিউল গোয়েন্দা নজরদারি',
              style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: UpayColors.textDark),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: UpayColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.hub_outlined, color: Colors.deepPurple, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'NetworkX গ্রাফ অ্যানালিটিক্স ইঞ্জিন',
                          style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: UpayColors.riskLow.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          'সক্রিয়',
                          style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: UpayColors.riskLow),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'সিস্টেম ক্রমাগত ফ্যান-ইন মানি-মিউল এগ্রিগেটর (Fan-In Aggregator) এবং সার্কুলার লেনদেন চক্র সনাক্ত করে গ্রাহকদের সুরক্ষিত রাখে।',
                    style: GoogleFonts.hindSiliguri(fontSize: 12, color: UpayColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: UpayColors.bgLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('শনাক্তকৃত সন্দেহভাজন সিন্ডিকেট নোড:', style: GoogleFonts.hindSiliguri(fontSize: 11.5, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('• ০১৯১১০-০২২৯৯ (Fan-In Aggregator flagged by Graph Intelligence)', style: GoogleFonts.inter(fontSize: 11, color: UpayColors.riskHigh)),
                        Text('• ০১৯৯৯৮-৮৭৭৬৬ (Smurfing Disperser flagged)', style: GoogleFonts.inter(fontSize: 11, color: UpayColors.riskHigh)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Emergency Helpline Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: UpayColors.primaryDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent_rounded, color: UpayColors.accentYellow, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '২৪x৭ সিকিউরিটি ইমার্জেন্সি সাপোর্ট',
                          style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'অ্যাকাউন্টে কোনো সন্দেহভাজন লেনদেন দেখলে কল করুন ১৬২৬৮',
                          style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String title,
    required String value,
    required bool isOk,
  }) {
    return Row(
      children: [
        Icon(icon, color: UpayColors.primaryBlue, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w600, color: UpayColors.textDark)),
              Text(value, style: GoogleFonts.inter(fontSize: 12, color: UpayColors.textMuted)),
            ],
          ),
        ),
        Icon(
          isOk ? Icons.check_circle : Icons.error,
          color: isOk ? UpayColors.riskLow : UpayColors.riskHigh,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildBaselineRow(String title, String detail) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(title, style: GoogleFonts.hindSiliguri(fontSize: 13, color: UpayColors.textDark, fontWeight: FontWeight.w500)),
        ),
        Text(detail, style: GoogleFonts.hindSiliguri(fontSize: 12, color: UpayColors.textMuted, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
