import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/admin_intelligence.dart';
import '../../models/transaction.dart';
import '../../models/risk_result.dart';
import '../../services/admin_service.dart';
import 'risk_investigation_screen.dart';
import 'fraud_cases_screen.dart';
import 'graph_intelligence_screen.dart';
import 'scam_nlp_screen.dart';
import 'demo_scenarios_dialog.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  late TabController _tabController;

  AnalyticsData _analytics = const AnalyticsData();
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDashboardData() async {
    setState(() => _isLoading = true);
    final a = await _adminService.fetchAnalytics();
    final t = await _adminService.fetchAdminTransactions();
    if (mounted) {
      setState(() {
        _analytics = a;
        _transactions = t;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B), // Modern Fintech Dark Theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2541),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: UpayColors.accentYellow,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'upay',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: UpayColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Trust & Risk Intelligence Console',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Run Demo Scenarios (Judge Mode)',
            icon: const Icon(Icons.play_circle_fill_rounded, color: UpayColors.accentYellow, size: 28),
            onPressed: () => showDemoScenariosDialog(context),
          ),
          IconButton(
            tooltip: 'Refresh Intelligence',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadDashboardData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: UpayColors.accentYellow,
          unselectedLabelColor: Colors.white60,
          indicatorColor: UpayColors.accentYellow,
          indicatorWeight: 3,
          isScrollable: true,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.radar_rounded), text: 'Live Risk Feed'),
            Tab(icon: Icon(Icons.insights_rounded), text: 'Security Analytics'),
            Tab(icon: Icon(Icons.hub_rounded), text: 'Mule Graph Intelligence'),
            Tab(icon: Icon(Icons.chat_bubble_outline_rounded), text: 'Bangla Scam NLP'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: UpayColors.accentYellow))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLiveFeedTab(),
                _buildAnalyticsTab(),
                const GraphIntelligenceScreen(),
                const ScamNlpScreen(),
              ],
            ),
    );
  }

  // Tab 1: Live Risk Feed
  Widget _buildLiveFeedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 5 Core KPI Counters specified in PDF Page 21
          Row(
            children: [
              Expanded(
                child: _buildKpiCard('Total Transactions', '25,430', Icons.analytics_outlined, Colors.blue),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildKpiCard('High Risk', '42', Icons.error_outline, UpayColors.riskHigh),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildKpiCard('Medium Risk', '186', Icons.warning_amber_rounded, UpayColors.riskMedium),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard('Blocked', '31', Icons.block_flipped, Colors.redAccent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildKpiCard('Under Review', '18', Icons.pending_actions_rounded, Colors.amber),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FraudCasesScreen()),
                    );
                  },
                  child: _buildKpiCard('Active Cases', '3 Cases', Icons.folder_shared_outlined, Colors.cyan, isClickable: true),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Live Risk Feed Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE RISK FEED',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                'Showing recent incoming transactions',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Transaction cards
          if (_transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              alignment: Alignment.center,
              child: Text('No transactions recorded yet.', style: GoogleFonts.inter(color: Colors.white54)),
            )
          else
            ..._transactions.map((t) => _buildLiveTransactionCard(t)),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color, {bool isClickable = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2541),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              if (isClickable)
                const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 12),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTransactionCard(TransactionModel t) {
    final risk = t.riskResult;
    final score = risk?.riskScore ?? (t.amount >= 40000 ? 94 : (t.amount >= 8000 ? 56 : 12));
    final level = risk?.riskLevel ?? (score >= 71 ? RiskLevel.high : (score >= 31 ? RiskLevel.medium : RiskLevel.low));

    final (Color badgeColor, String levelText) = switch (level) {
      RiskLevel.high => (UpayColors.riskHigh, 'HIGH RISK'),
      RiskLevel.medium => (UpayColors.riskMedium, 'MEDIUM RISK'),
      RiskLevel.low => (UpayColors.riskLow, 'LOW RISK'),
    };

    return Card(
      color: const Color(0xFF1C2541),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: level == RiskLevel.high ? UpayColors.riskHigh.withOpacity(0.5) : Colors.white12,
          width: level == RiskLevel.high ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RiskInvestigationScreen(transaction: t),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        t.id,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• User: ${t.userId}',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: badgeColor.withOpacity(0.6)),
                    ),
                    child: Text(
                      'Risk: $score/100',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount: ${Formatters.currency(t.amount)}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    Formatters.formatTimestamp(t.timestamp),
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Indicators chip row
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _indicatorChip(t.deviceId != 'DEVICE001' ? 'New Device' : 'Trusted Device', t.deviceId != 'DEVICE001'),
                  _indicatorChip(t.location.toLowerCase() != 'dhaka' ? 'Unusual Location' : 'Normal Location', t.location.toLowerCase() != 'dhaka'),
                  if (t.amount >= 20000) _indicatorChip('High Amount', true),
                  if (score >= 70) _indicatorChip('Rapid Transactions', true),
                ],
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap to Investigate (SHAP & Graph) →',
                    style: GoogleFonts.inter(fontSize: 12, color: UpayColors.accentYellow, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _indicatorChip(String text, bool isAlert) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAlert ? UpayColors.riskHigh.withOpacity(0.2) : Colors.white10,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isAlert ? UpayColors.riskHigh.withOpacity(0.4) : Colors.white12),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isAlert ? const Color(0xFFFF8B8B) : Colors.white70,
        ),
      ),
    );
  }

  // Tab 2: Security Analytics with fl_chart
  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RISK SCORE DISTRIBUTION',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.1),
          ),
          const SizedBox(height: 12),

          Container(
            height: 220,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2541),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 25000,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        const labels = ['0-20', '21-40', '41-60', '61-80', '81-100'];
                        final idx = val.toInt();
                        if (idx >= 0 && idx < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(labels[idx], style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 21400, color: UpayColors.riskLow, width: 24, borderRadius: BorderRadius.circular(6))]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 3802, color: Colors.greenAccent, width: 24, borderRadius: BorderRadius.circular(6))]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 800, color: UpayColors.riskMedium, width: 24, borderRadius: BorderRadius.circular(6))]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 450, color: Colors.orangeAccent, width: 24, borderRadius: BorderRadius.circular(6))]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 320, color: UpayColors.riskHigh, width: 24, borderRadius: BorderRadius.circular(6))]),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'WEEKLY NORMAL VS FLAGGED VOLUME',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.1),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2541),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendItem('Normal Transactions', Colors.blueAccent),
                    const SizedBox(width: 16),
                    _legendItem('Flagged / High Risk', UpayColors.riskHigh),
                  ],
                ),
                const SizedBox(height: 16),
                ..._analytics.recentTrend.map((t) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 38,
                          child: Text(t['day'] as String, style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (t['normal'] as num) / 5000.0,
                              minHeight: 10,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${t['flagged']} flagged',
                          style: GoogleFonts.inter(color: UpayColors.riskHigh, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _legendItem(String text, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}
