import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../send_money/send_money_screen.dart';

void showDemoScenariosDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          const Icon(Icons.psychology_alt_rounded, color: UpayColors.accentYellow, size: 28),
          const SizedBox(width: 10),
          Text(
            'Track 01 Demo Scenarios',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select one of the 3 official predefined track scenarios to run:',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 16),

            // Scenario 1
            _scenarioCard(
              ctx,
              title: 'Scenario 1 — NORMAL (৳500)',
              subtitle: 'Trusted Device • Dhaka • Normal Velocity\nBackend: Low Risk (12/100) → ALLOW\nCustomer: Money Sent Successfully',
              badge: 'ALLOW',
              badgeColor: UpayColors.riskLow,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SendMoneyScreen(
                      initialAmount: 500,
                      initialReceiverName: 'Karim Ahmed',
                      initialReceiverPhone: '01819283746',
                      isNewDeviceSimulation: false,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            // Scenario 2
            _scenarioCard(
              ctx,
              title: 'Scenario 2 — SUSPICIOUS (৳8,000)',
              subtitle: 'New Receiver • Moderate Deviation\nBackend: Medium Risk (56/100) → VERIFY\nCustomer: Additional verification is required.',
              badge: 'VERIFY',
              badgeColor: UpayColors.riskMedium,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SendMoneyScreen(
                      initialAmount: 8000,
                      initialReceiverName: 'Anisur Rahman (New)',
                      initialReceiverPhone: '01799887766',
                      isNewDeviceSimulation: false,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            // Scenario 3
            _scenarioCard(
              ctx,
              title: 'Scenario 3 — HIGH RISK (৳50,000)',
              subtitle: 'New Device (DEVICE009) • Chattogram Hop • Burst\nBackend: High Risk (94/100) → HOLD / BLOCK\nCustomer: Transaction temporarily unavailable.',
              badge: 'HOLD / BLOCK',
              badgeColor: UpayColors.riskHigh,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SendMoneyScreen(
                      initialAmount: 50000,
                      initialReceiverName: 'Unknown Recipient',
                      initialReceiverPhone: '01999887766',
                      isNewDeviceSimulation: true,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Close', style: GoogleFonts.inter(color: Colors.white60)),
        ),
      ],
    ),
  );
}

Widget _scenarioCard(
  BuildContext ctx, {
  required String title,
  required String subtitle,
  required String badge,
  required Color badgeColor,
  required VoidCallback onTap,
}) {
  return Card(
    color: const Color(0xFF0F172A),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: badgeColor.withOpacity(0.4)),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, height: 1.3),
            ),
          ],
        ),
      ),
    ),
  );
}
