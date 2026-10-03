import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/routes/app_routes.dart';
import '../security/trust_and_safety_center_screen.dart';
import '../../widgets/demo_scenario_sheet.dart';
import '../login/login_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: Colors.white,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: SafeArea(
            bottom: false,
            child: Text(
              'আরো',
              style: GoogleFonts.hindSiliguri(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E3A5F),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. সেটিংস (Settings) matching pic3.jpeg
            _buildSectionHeader('সেটিংস'),
            _buildCardGroup([
              _buildMenuItem(
                iconColor: const Color(0xFFFFB800),
                icon: Icons.lock_outline_rounded,
                title: 'পিন পরিবর্তন',
                onTap: () => _showActionSnackBar(context, 'পিন পরিবর্তন সুবিধাটি শীঘ্রই আসছে'),
              ),
              const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),
              _buildMenuItem(
                iconColor: const Color(0xFF22C55E),
                icon: Icons.chat_bubble_outline_rounded,
                title: 'ভাষা পরিবর্তন',
                onTap: () => _showActionSnackBar(context, 'ভাষা: বাংলা (সক্রিয়)'),
              ),
              const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),
              _buildMenuItem(
                iconColor: const Color(0xFF2563EB),
                icon: Icons.toggle_on_outlined,
                title: 'অনুমতি পরিবর্তন',
                onTap: () => _showActionSnackBar(context, 'সব প্রয়োজনীয় অনুমতি সক্রিয় রয়েছে'),
              ),
            ]),

            // 2. উপায় সাপোর্ট (Upay Support) matching pic3.jpeg
            _buildSectionHeader('উপায় সাপোর্ট'),
            _buildCardGroup([
              _buildMenuItem(
                iconColor: const Color(0xFFEF4444),
                icon: Icons.support_agent_rounded,
                title: '২৪x৭ সেবা',
                onTap: () => _showSupportModal(context),
              ),
              const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),
              _buildMenuItem(
                iconColor: const Color(0xFFF97316),
                icon: Icons.question_answer_outlined,
                title: 'বহুল জিজ্ঞাসিত প্রশ্ন',
                onTap: () => _showActionSnackBar(context, '১৬২৬৮ নম্বরে কল করুন অথবা FAQ দেখুন'),
              ),
            ]),

            // 3. অ্যাকাউন্ট সার্ভিস (Account Services) matching pic3.jpeg
            _buildSectionHeader('অ্যাকাউন্ট সার্ভিস'),
            _buildCardGroup([
              _buildMenuItem(
                iconColor: const Color(0xFF1D4ED8),
                icon: Icons.sim_card_outlined,
                title: 'MNP তথ্য আপডেট',
                onTap: () => _showActionSnackBar(context, 'আপনার সিমের MNP তথ্য যাচাই করা হয়েছে'),
              ),
              const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),
              _buildMenuItem(
                iconColor: const Color(0xFFF59E0B),
                icon: Icons.adjust_rounded,
                title: 'উপায় চাকা',
                onTap: () => _showActionSnackBar(context, 'উপায় চাকা ঘুরিয়ে আকর্ষণীয় ক্যাশব্যাক জিতুন!'),
              ),
              const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),
              _buildMenuItem(
                iconColor: const Color(0xFFEAB308),
                icon: Icons.sentiment_satisfied_alt_rounded,
                title: 'ফিঙ্গারপ্রিন্ট/ফেস আইডি সচল করুন',
                onTap: () => _showActionSnackBar(context, 'বায়োমেট্রিক সিকিউরিটি সচল রয়েছে'),
              ),
              const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),
              _buildMenuItem(
                iconColor: const Color(0xFF2563EB),
                icon: Icons.group_add_outlined,
                title: 'রেফার উপায়',
                onTap: () => _showActionSnackBar(context, 'বন্ধুদের রেফার করে জিতে নিন ৫০ টাকা বোনাস!'),
              ),
            ]),

            // 4. নীতিমালা (Policies) matching pic3.jpeg
            _buildSectionHeader('নীতিমালা'),
            _buildCardGroup([
              _buildMenuItem(
                iconColor: const Color(0xFFFBBF24),
                icon: Icons.description_outlined,
                title: 'শর্তাবলী',
                onTap: () => _showActionSnackBar(context, 'উপায় ব্যবহারের সাধারণ শর্তাবলী ও নীতিমালা'),
              ),
              const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),
              _buildMenuItem(
                iconColor: const Color(0xFF10B981),
                icon: Icons.verified_user_outlined,
                title: 'প্রাইভেসি পলিসি',
                onTap: () => _showActionSnackBar(context, 'আপনার তথ্য সম্পূর্ণ সুরক্ষিত ও এনক্রিপ্টেড'),
              ),
            ]),

            // 5. Track 01 — Trust & Risk Intelligence Specialized Entry
            _buildSectionHeader('ট্রাস্ট ও সিকিউরিটি ইন্টেলিজেন্স (Track 01)'),
            _buildCardGroup([
              _buildMenuItem(
                iconColor: const Color(0xFF005CB9),
                icon: Icons.shield_rounded,
                title: 'ট্রাস্ট অ্যান্ড সেফটি সেন্টার',
                subtitle: 'AI রিয়েল-টাইম প্রোটেকশন, ট্রাস্টেড ডিভাইস ও লগইন স্টেট',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TrustAndSafetyCenterScreen()),
                  );
                },
              ),
              const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),
              _buildMenuItem(
                iconColor: const Color(0xFF8B5CF6),
                icon: Icons.play_circle_outline_rounded,
                title: 'হ্যাকথন ডেমো সিনারিও',
                subtitle: 'Normal, Suspicious, Account Takeover ও Scam NLP টেস্ট করুন',
                onTap: () => DemoScenarioSheet.show(context),
              ),
              const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),
              _buildMenuItem(
                iconColor: const Color(0xFF0A2540),
                icon: Icons.admin_panel_settings_rounded,
                title: 'অ্যাডমিন / ফ্রড অ্যানালিস্ট কনসোল',
                subtitle: 'রিয়েল-টাইম রিক্স ফিড, SHAP চার্ট, ATO ও মানি-মিউল গ্রাফ',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.adminLogin);
                },
              ),
            ]),

            const SizedBox(height: 16),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                  label: Text(
                    'লগআউট করুন',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: GoogleFonts.hindSiliguri(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF64748B),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required Color iconColor,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showActionSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.hindSiliguri()),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSupportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'উপায় হেল্পলাইন ২৪x৭',
              style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'যেকোনো জরুরি প্রয়োজনে ১৬২৬৮ নম্বরে কল করুন অথবা সাপোর্ট টিকেট ওপেন করুন।',
              style: GoogleFonts.hindSiliguri(color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone_rounded, color: Color(0xFF005CB9)),
              title: const Text('১৬২৬৮ (হটলাইন)'),
              subtitle: const Text('টোল ফ্রি ২৪/৭ গ্রাহক সেবা'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
