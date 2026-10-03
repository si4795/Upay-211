import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/colors.dart';
import '../models/risk_result.dart';

class RiskBadge extends StatelessWidget {
  final RiskLevel level;
  final int? score;

  const RiskBadge({super.key, required this.level, this.score});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color text, String label) = switch (level) {
      RiskLevel.low => (
        UpayColors.riskLow.withOpacity(0.15),
        UpayColors.riskLow,
        'LOW RISK',
      ),
      RiskLevel.medium => (
        UpayColors.riskMedium.withOpacity(0.15),
        UpayColors.riskMedium,
        'MEDIUM RISK',
      ),
      RiskLevel.high => (
        UpayColors.riskHigh.withOpacity(0.15),
        UpayColors.riskHigh,
        'HIGH RISK',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: text.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: text, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            score != null ? '$label ($score/100)' : label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}
