import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../security/trust_and_safety_center_screen.dart';
import '../login/login_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UpayColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'আরো',
          style: GoogleFonts.hindSiliguri(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: UpayColors.primaryBlue,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prominent Trust & Safety Center Banner
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TrustAndSafetyCenterScreen()),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [UpayColors.primaryBlue, Color(0xFF133E68)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: UpayColors.primaryBlue.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: UpayColors.accentYellow.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_rounded, color: UpayColors.accentYellow, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'ট্রাস্ট অ্যান্ড সেফটি সেন্টার',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: UpayColors.riskLow,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'AI Shield',
                                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'অ্যাকাউন্ট টেকওভার, আচরণগত অ্যানোমালি ও স্ক্যাম ইন্টেলিজেন্স',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white70),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // সেকশন ১: সেটিংস (Settings)
            _buildSectionHeader('সেটিংস'),
            _buildSettingsItem(icon: Icons.lock_outline, title: 'পিন পরিবর্তন', onTap: () {}),
            _buildSettingsItem(icon: Icons.language, title: 'ভাষা পরিবর্তন', onTap: () {}),
            _buildSettingsItem(icon: Icons.toggle_on_outlined, title: 'অনুমতি পরিবর্তন', onTap: () {}),

            const SizedBox(height: 16),

            // সেকশন ২: উপায় সাপোর্ট (Upay Support)
            _buildSectionHeader('উপায় সাপোর্ট'),
            _buildSettingsItem(
              icon: Icons.support_agent_rounded,
              title: '২৪x৭ সেবা (১৬২৬৮)',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('১৬২৬৮ হেল্পলাইনে কল সংযুক্ত করা হচ্ছে...')),
                );
              },
            ),
            _buildSettingsItem(icon: Icons.help_outline_rounded, title: 'বহুল জিজ্ঞাসিত প্রশ্ন (FAQ)', onTap: () {}),

            const SizedBox(height: 16),

            // সেকশন ৩: অ্যাকাউন্ট সার্ভিস (Account Services)
            _buildSectionHeader('অ্যাকাউন্ট সার্ভিস'),
            _buildSettingsItem(icon: Icons.sim_card_outlined, title: 'MNP তথ্য আপডেট', onTap: () {}),
            _buildSettingsItem(icon: Icons.stars_rounded, title: 'উপায় চাকা', onTap: () {}),
            _buildSettingsItem(icon: Icons.fingerprint, title: 'ফিঙ্গারপ্রিন্ট/ফেস আইডি সচল করুন', onTap: () {}),
            _buildSettingsItem(icon: Icons.share_outlined, title: 'রেফার উপায়', onTap: () {}),

            const SizedBox(height: 16),

            // সেকশন ৪: নীতিমালা (Policy)
            _buildSectionHeader('নীতিমালা'),
            _buildSettingsItem(icon: Icons.description_outlined, title: 'শর্তাবলী', onTap: () {}),
            _buildSettingsItem(icon: Icons.policy_outlined, title: 'গোপনীয়তা নীতিমালা', onTap: () {}),
            _buildSettingsItem(icon: Icons.info_outline, title: 'অ্যাপ-এর তথ্য (Track 01 Prototype)', onTap: () {}),

            const SizedBox(height: 16),

            // লগ আউট (Logout)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: UpayColors.borderSubtle),
                ),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: Text(
                    'লগ আউট',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  onTap: () {
                    context.read<AuthProvider>().logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.hindSiliguri(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: UpayColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: UpayColors.borderSubtle),
        ),
        child: ListTile(
          onTap: onTap,
          dense: true,
          leading: Icon(icon, color: UpayColors.primaryBlue, size: 20),
          title: Text(
            title,
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: UpayColors.textDark,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, size: 18, color: UpayColors.textLight),
        ),
      ),
    );
  }
}

