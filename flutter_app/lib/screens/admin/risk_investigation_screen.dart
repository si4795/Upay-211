import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/transaction.dart';
import '../../models/risk_result.dart';
import '../../services/admin_service.dart';

class RiskInvestigationScreen extends StatefulWidget {
  final TransactionModel transaction;

  const RiskInvestigationScreen({super.key, required this.transaction});

  @override
  State<RiskInvestigationScreen> createState() => _RiskInvestigationScreenState();
}

class _RiskInvestigationScreenState extends State<RiskInvestigationScreen> {
  final AdminService _adminService = AdminService();
  bool _isActionInProgress = false;
  String? _lastActionTaken;

  void _handleAction(String action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Confirm $action Action',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to apply action "$action" to transaction ${widget.transaction.id} for user ${widget.transaction.userId}?',
          style: GoogleFonts.hindSiliguri(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'BLOCK'
                  ? UpayColors.riskHigh
                  : (action == 'HOLD' ? UpayColors.riskMedium : UpayColors.primaryBlue),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Confirm $action'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isActionInProgress = true);
      await _adminService.takeAdminAction(
        transactionId: widget.transaction.id,
        action: action,
        analystId: 'ADMIN001',
        notes: 'Action taken via Risk Investigation Console',
      );
      setState(() {
        _isActionInProgress = false;
        _lastActionTaken = action;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action $action recorded successfully by ADMIN001.'),
            backgroundColor: action == 'BLOCK' ? UpayColors.riskHigh : Colors.black87,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final txn = widget.transaction;
    final risk = txn.riskResult ??
        const RiskResult(
          transactionId: 'TXN-UNKNOWN',
          riskScore: 94,
          riskLevel: RiskLevel.high,
          decision: RiskDecision.hold,
          customerMessage: 'Under review',
        );

    final (Color badgeBg, Color badgeFg, String riskText) = switch (risk.riskLevel) {
      RiskLevel.low => (UpayColors.riskLow.withOpacity(0.15), UpayColors.riskLow, 'LOW RISK'),
      RiskLevel.medium => (UpayColors.riskMedium.withOpacity(0.15), UpayColors.riskMedium, 'MEDIUM RISK'),
      RiskLevel.high => (UpayColors.riskHigh.withOpacity(0.15), UpayColors.riskHigh, 'HIGH RISK'),
    };

    return Scaffold(
      backgroundColor: UpayColors.adminBg, // Dark investigation console
      appBar: AppBar(
        backgroundColor: UpayColors.adminSurface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Investigation Console',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${txn.id} • Analyst: ADMIN001',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: badgeFg.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.shield, color: badgeFg, size: 16),
                const SizedBox(width: 6),
                Text(
                  '$riskText (${risk.riskScore}/100)',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: badgeFg),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_lastActionTaken != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade400),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.greenAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Analyst Action Applied: $_lastActionTaken by ADMIN001 at ${Formatters.formatTimestamp(DateTime.now())}',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            // Top Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Amount',
                    value: Formatters.currency(txn.amount),
                    subtitle: 'Baseline avg: ৳2,500',
                    color: txn.amount >= 20000 ? UpayColors.riskHigh : Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Risk Score',
                    value: '${risk.riskScore}/100',
                    subtitle: risk.riskLevel.name.toUpperCase(),
                    color: badgeFg,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Anomaly Score',
                    value: risk.anomalyScore != null ? '${(risk.anomalyScore! * 100).toInt()}%' : '89%',
                    subtitle: 'Isolation Forest',
                    color: Colors.cyanAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Main Investigation Panel
            _buildSectionContainer(
              title: 'Explainable AI — SHAP Feature Contributions',
              icon: Icons.auto_awesome,
              iconColor: UpayColors.accentYellow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why was this transaction flagged by the risk intelligence engine?',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  if (risk.riskFactors.isEmpty)
                    Text('No elevated risk signals detected.', style: GoogleFonts.inter(color: Colors.white60))
                  else
                    ...risk.riskFactors.map((rf) => _buildShapBar(rf)),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Behavioral & Identity Intelligence (ATO Indicators)
            _buildSectionContainer(
              title: 'Account Takeover (ATO) & Behavioral Signals',
              icon: Icons.fingerprint_rounded,
              iconColor: Colors.deepOrangeAccent,
              child: Column(
                children: [
                  _buildSignalRow(
                    label: 'Device Signature',
                    val: '${txn.deviceId} (Unrecognized Device)',
                    isWarning: txn.deviceId != 'DEVICE001',
                    badge: txn.deviceId != 'DEVICE001' ? 'NEW DEVICE' : 'TRUSTED',
                  ),
                  const Divider(color: Colors.white12),
                  _buildSignalRow(
                    label: 'Geo-Location Hop',
                    val: '${txn.location} (Home: Dhaka)',
                    isWarning: txn.location.toLowerCase() != 'dhaka',
                    badge: txn.location.toLowerCase() != 'dhaka' ? 'ABNORMAL HOP' : 'DOMESTIC',
                  ),
                  const Divider(color: Colors.white12),
                  _buildSignalRow(
                    label: 'Transaction Velocity',
                    val: '8 transactions in last 60 minutes',
                    isWarning: true,
                    badge: 'VELOCITY SURGE',
                  ),
                  const Divider(color: Colors.white12),
                  _buildSignalRow(
                    label: 'Failed PIN Attempts',
                    val: '3 consecutive PIN failures before transfer',
                    isWarning: true,
                    badge: 'FAILED PINS',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Participant Details
            _buildSectionContainer(
              title: 'Participant & Entity Connections',
              icon: Icons.hub_rounded,
              iconColor: Colors.blueAccent,
              child: Column(
                children: [
                  _buildDetailRow('Sender User ID', txn.userId),
                  _buildDetailRow('Sender Device Fingerprint', txn.deviceId),
                  _buildDetailRow('Receiver Account ID', txn.receiverId),
                  _buildDetailRow('Receiver Name', txn.receiverName),
                  _buildDetailRow('Receiver Phone', txn.receiverPhone),
                  _buildDetailRow('Execution Timestamp', Formatters.formatTimestamp(txn.timestamp)),
                  _buildDetailRow('Policy Engine Decision', risk.decision.name.toUpperCase()),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons Console
            Text(
              'FRAUD ANALYST ACTIONS',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton('REVIEW', Icons.search_rounded, Colors.blueAccent),
                _buildActionButton('HOLD', Icons.pause_circle_outline, Colors.orangeAccent),
                _buildActionButton('BLOCK', Icons.block_rounded, UpayColors.riskHigh),
                _buildActionButton('MONITOR', Icons.remove_red_eye_outlined, Colors.purpleAccent),
                _buildActionButton('FLAG ACCOUNT', Icons.flag_rounded, Colors.amberAccent),
                _buildActionButton('ESCALATE', Icons.crisis_alert_rounded, Colors.redAccent),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UpayColors.adminCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: UpayColors.adminCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildShapBar(RiskFactor rf) {
    final pct = (rf.impact * 100).toInt();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  rf.message,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
              Text(
                'SHAP Impact: $pct%',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: UpayColors.accentYellow),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: rf.impact.clamp(0.05, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                rf.impact > 0.3 ? UpayColors.riskHigh : UpayColors.accentYellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalRow({
    required String label,
    required String val,
    required bool isWarning,
    required String badge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
              const SizedBox(height: 2),
              Text(val, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (isWarning ? UpayColors.riskHigh : UpayColors.riskLow).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isWarning ? UpayColors.riskHigh : UpayColors.riskLow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
          Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: _isActionInProgress ? null : () => _handleAction(label),
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.85),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
