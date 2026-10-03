import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';

class TrustProfileScreen extends StatelessWidget {
  final String userId;

  const TrustProfileScreen({super.key, this.userId = 'USER001'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'Trust Intelligence Profile — $userId',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Hero
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: UpayColors.accentYellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: UpayColors.primaryBlue, size: 34),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Md. Rafiqul Islam ($userId)',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Phone: 01712345678 • Status: Active (Supervised)',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Profile Metrics specified in PDF Page 30-31
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _profileMetric('Account Age', '320 days', Icons.calendar_today_outlined),
                _profileMetric('Transactions', '842', Icons.sync_alt_rounded),
                _profileMetric('Avg Amount', '৳780', Icons.payments_outlined),
                _profileMetric('Devices', '2', Icons.devices_rounded),
                _profileMetric('Locations', '3', Icons.location_on_outlined),
                _profileMetric('Risk Events', '7', Icons.shield_outlined, isAlert: true),
                _profileMetric('Blocked Txns', '2', Icons.block_rounded, isAlert: true),
                _profileMetric('Trust Score', '86/100', Icons.verified_user_outlined),
                _profileMetric('Cluster Rank', 'Tier 1', Icons.hub_outlined),
              ],
            ),

            const SizedBox(height: 24),

            // Behavioural Timeline
            Text(
              'BEHAVIOURAL TIMELINE',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.1),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  _timelineItem('Today, 12:42 PM', 'Unrecognized device DEVICE009 logged in from Chattogram', true),
                  _timelineItem('Yesterday, 06:10 PM', 'Normal transaction ৳500 to Karim Ahmed (Dhaka)', false),
                  _timelineItem('24 Sep 2026', 'Normal transaction ৳1,450 to Shwapno Supershop', false),
                  _timelineItem('18 Sep 2026', 'High risk burst attempt blocked by policy rule', true),
                  _timelineItem('15 Aug 2025', 'Account registered and KYC verified', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileMetric(String label, String val, IconData icon, {bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isAlert ? UpayColors.riskHigh.withOpacity(0.4) : Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isAlert ? UpayColors.riskHigh : UpayColors.accentYellow, size: 20),
          const SizedBox(height: 6),
          Text(val, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _timelineItem(String time, String event, bool isWarning) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isWarning ? Icons.warning_rounded : Icons.check_circle_rounded,
            color: isWarning ? UpayColors.riskHigh : Colors.greenAccent,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event, style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                Text(time, style: GoogleFonts.inter(fontSize: 10, color: Colors.white54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
