import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';
import '../screens/send_money/send_money_screen.dart';
import '../screens/security/trust_and_safety_center_screen.dart';

class DemoScenarioSheet extends StatelessWidget {
  const DemoScenarioSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DemoScenarioSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.play_circle_fill_rounded, color: UpayColors.primaryBlue, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'হ্যাকথন ডেমো সিনারিও (Judge Scenarios)',
                    style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: UpayColors.primaryBlue),
                  ),
                ],
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          Text(
            'ট্র্যাক ০১ — ট্রাস্ট অ্যান্ড রিস্ক ইন্টেলিজেন্স মূল্যায়নের জন্য যেকোনো সিনারিও ট্যাপ করুন:',
            style: GoogleFonts.hindSiliguri(fontSize: 12, color: UpayColors.textMuted),
          ),
          const SizedBox(height: 16),

          // Scenario 1: Normal Transaction (LOW RISK)
          _buildScenarioCard(
            title: 'সিনারিও ১: স্বাভাবিক নিরাপদ লেনদেন (LOW RISK)',
            subtitle: '৳৫০০ • পরিচিত বন্ধু (Karim Ahmed) • বিশ্বস্ত ডিভাইস • ঢাকা',
            tag: 'স্কোর: ১২/১০০ (ALLOW)',
            tagColor: UpayColors.riskLow,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SendMoneyScreen(
                    initialAmount: 500,
                    initialReceiverName: 'Karim Ahmed',
                    initialReceiverPhone: '01819283746',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Scenario 2: Suspicious Transaction (MEDIUM RISK)
          _buildScenarioCard(
            title: 'সিনারিও ২: সন্দেহভাজন লেনদেন (MEDIUM RISK)',
            subtitle: '৳৮,৫০০ • নতুন অপরিচিত প্রাপক • অতিরিক্ত যাচাই প্রয়োজন (Challenge OTP)',
            tag: 'স্কোর: ৫৬/১০০ (VERIFY)',
            tagColor: UpayColors.riskMedium,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SendMoneyScreen(
                    initialAmount: 8500,
                    initialReceiverName: 'Anisur Rahman',
                    initialReceiverPhone: '01799887766',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Scenario 3: High-Risk Account Takeover (HIGH RISK)
          _buildScenarioCard(
            title: 'সিনারিও ৩: হাই-রিস্ক অ্যাকাউন্ট টেকওভার ও মানি-মিউল (HIGH RISK)',
            subtitle: '৳৫০,০০০ • অপরিচিত ডিভাইস (DEVICE009) • চট্টগ্রাম হপ • ৩ বার ভুল পিন',
            tag: 'স্কোর: ৯৪/১০০ (HOLD/REVIEW)',
            tagColor: UpayColors.riskHigh,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SendMoneyScreen(
                    initialAmount: 50000,
                    initialReceiverName: 'Syndicate Mule Node',
                    initialReceiverPhone: '01911002299',
                    isNewDeviceSimulation: true,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Scenario 4: Scam Text Intelligence
          _buildScenarioCard(
            title: 'সিনারিও ৪: স্ক্যাম টেক্সট ও ফিশিং ইন্টেলিজেন্স (বাংলা NLP)',
            subtitle: 'ভুয়া লটারি ও পিন চাওয়া মেসেজ শনাক্তকরণ • ট্রাস্ট অ্যান্ড সেফটি সেন্টার',
            tag: 'NLP SCAM DETECT',
            tagColor: Colors.deepPurple,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrustAndSafetyCenterScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioCard({
    required String title,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: UpayColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: tagColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: tagColor.withOpacity(0.4), width: 0.8),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: tagColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold, color: UpayColors.textDark),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.hindSiliguri(fontSize: 11, color: UpayColors.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: UpayColors.textLight),
          ],
        ),
      ),
    );
  }
}

