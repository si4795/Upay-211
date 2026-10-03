import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';

class CustomerSecurityCenterScreen extends StatelessWidget {
  const CustomerSecurityCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: UpayColors.bgLight,
      appBar: AppBar(
        title: Text(
          'নিরাপত্তা কেন্দ্র (Security Center)',
          style: GoogleFonts.hindSiliguri(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
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
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: UpayColors.riskLow.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: UpayColors.riskLow,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'অ্যাকাউন্ট সুরক্ষিত (Account Protected)',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'upay AI Fraud Shield আপনার প্রতিটি লেনদেন সার্বক্ষণিক পর্যবেক্ষণ করছে',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'সুরক্ষা স্ট্যাটাস (Protection Checklist)',
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: UpayColors.textDark,
              ),
            ),
            const SizedBox(height: 12),

            _buildStatusTile(
              icon: Icons.smartphone_rounded,
              title: 'বিশ্বস্ত ডিভাইস (Trusted Device)',
              subtitle: 'আপনার প্রাইমারি ডিভাইস তালিকাভুক্ত রয়েছে',
              status: 'সক্রিয় (✓)',
              isOk: true,
            ),
            _buildStatusTile(
              icon: Icons.login_rounded,
              title: 'সাম্প্রতিক লগইন (Recent Login)',
              subtitle: 'আজকে স্বাভাবিক লোকেশন (ঢাকা) থেকে লগইন সম্পন্ন',
              status: 'নিরাপদ (✓)',
              isOk: true,
            ),
            _buildStatusTile(
              icon: Icons.shield_rounded,
              title: 'নিরাপত্তা পর্যবেক্ষণ (Security Monitoring)',
              subtitle: 'AI রিয়েল-টাইম আচরণগত ঝুঁকি যাচাই চলছে',
              status: 'Active (✓)',
              isOk: true,
            ),

            const SizedBox(height: 24),
            Text(
              'নিবন্ধিত ডিভাইস তালিকা',
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: UpayColors.textDark,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.phone_android, color: UpayColors.primaryBlue),
                      title: Text(
                        'Samsung Galaxy S23 (বর্তমান ডিভাইস)',
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        'ডিভাইস আইডি: ${user?.currentDeviceId ?? "DEVICE001"} • লোকেশন: ${user?.currentLocation ?? "Dhaka"}',
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: UpayColors.riskLow.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Primary',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: UpayColors.riskLow,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            // Safety tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: UpayColors.accentYellow.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: UpayColors.accentYellow.withOpacity(0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: UpayColors.accentGold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'নিরাপত্তা টিপস',
                          style: GoogleFonts.hindSiliguri(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: UpayColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'উপায় কর্তৃপক্ষ কখনও আপনার পিন বা ওটিপি জানতে চাইবে না। কোনো অবস্থাতেই অপরিচিত কাউকে আপনার পিন শেয়ার করবেন না।',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            color: UpayColors.textDark.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required bool isOk,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: UpayColors.borderSubtle),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isOk ? UpayColors.riskLow : UpayColors.riskMedium).withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isOk ? UpayColors.riskLow : UpayColors.riskMedium, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.hindSiliguri(fontSize: 12, color: UpayColors.textMuted),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (isOk ? UpayColors.riskLow : UpayColors.riskMedium).withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: GoogleFonts.hindSiliguri(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isOk ? UpayColors.riskLow : UpayColors.riskMedium,
            ),
          ),
        ),
      ),
    );
  }
}
