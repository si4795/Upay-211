import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
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
import 'trust_profile_screen.dart';
import 'demo_scenarios_dialog.dart';
import 'admin_login_screen.dart';
import '../home/home_screen.dart';

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
  List<AuditLogEntry> _auditLogs = [];
  ModelEvaluationData _modelEval = const ModelEvaluationData();
  Map<String, dynamic>? _highRiskAlert;
  WebSocketChannel? _wsChannel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadDashboardData();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _wsChannel?.sink.close();
    _tabController.dispose();
    super.dispose();
  }

  void _connectWebSocket() {
    try {
      final wsUri = Uri.parse('${_adminService.apiService.wsUrl}/api/v1/ws/risk-events');
      _wsChannel = WebSocketChannel.connect(wsUri);
      _wsChannel?.stream.listen((message) {
        try {
          final data = jsonDecode(message);
          if (data is Map<String, dynamic> && data.containsKey('transaction_id')) {
            _handleIncomingRiskEvent(data);
          }
        } catch (_) {}
      }, onError: (_) {});
    } catch (_) {}
  }

  void _handleIncomingRiskEvent(Map<String, dynamic> event) {
    if (!mounted) return;
    final txnId = event['transaction_id'] as String? ?? 'TXN-${DateTime.now().millisecondsSinceEpoch}';
    final amount = (event['amount'] as num?)?.toDouble() ?? 500.0;
    final score = (event['risk_score'] as num?)?.toInt() ?? 20;
    final isHigh = event['is_high_risk'] == true || score >= 71;

    final riskLevel = isHigh
        ? RiskLevel.high
        : (score >= 31 ? RiskLevel.medium : RiskLevel.low);
    final decision = isHigh
        ? RiskDecision.hold
        : (score >= 31 ? RiskDecision.verify : RiskDecision.allow);

    final newTxn = TransactionModel(
      id: txnId,
      userId: event['user_id'] as String? ?? 'USER001',
      receiverId: 'USER_RECV',
      receiverName: 'Recipient',
      receiverPhone: '',
      amount: amount,
      fee: 5.0,
      total: amount + 5.0,
      timestamp: DateTime.now(),
      type: TransactionType.sendMoney,
      status: isHigh ? TransactionStatus.hold : (score >= 31 ? TransactionStatus.verifyRequired : TransactionStatus.success),
      deviceId: event['device_id'] as String? ?? 'DEVICE001',
      location: event['location'] as String? ?? 'Dhaka',
      riskResult: RiskResult(
        transactionId: txnId,
        riskScore: score,
        riskLevel: riskLevel,
        decision: decision,
        customerMessage: isHigh ? 'Transaction temporarily unavailable.' : 'Processed',
        riskFactors: ((event['indicators'] as List<dynamic>?) ?? [])
            .map((i) => RiskFactor(feature: 'signal', impact: 0.25, message: i.toString()))
            .toList(),
      ),
    );

    setState(() {
      _transactions.removeWhere((t) => t.id == txnId);
      _transactions.insert(0, newTxn);
      if (isHigh) {
        _highRiskAlert = event;
      }
    });
  }

  void _loadDashboardData() async {
    setState(() => _isLoading = true);
    final a = await _adminService.fetchAnalytics();
    final t = await _adminService.fetchAdminTransactions();
    final logs = await _adminService.fetchAuditLogs();
    final me = await _adminService.fetchModelEvaluation();
    if (mounted) {
      setState(() {
        _analytics = a;
        _transactions = t;
        _auditLogs = logs;
        _modelEval = me;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UpayColors.adminBg,
      appBar: AppBar(
        backgroundColor: UpayColors.adminSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: UpayColors.adminTextSecondary, size: 20),
          tooltip: 'Return to Consumer App',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
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
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: UpayColors.adminTextPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'User Trust Profile (USER001)',
            icon: const Icon(Icons.account_circle_outlined, color: UpayColors.adminCyan, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrustProfileScreen(userId: 'USER001')),
              );
            },
          ),
          IconButton(
            tooltip: 'Run Demo Scenarios (Judge Mode)',
            icon: const Icon(Icons.play_circle_fill_rounded, color: UpayColors.accentYellow, size: 26),
            onPressed: () => showDemoScenariosDialog(context),
          ),
          IconButton(
            tooltip: 'Refresh Intelligence',
            icon: const Icon(Icons.refresh_rounded, color: UpayColors.adminTextSecondary, size: 22),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            tooltip: 'Sign Out of SOC',
            icon: const Icon(Icons.logout_rounded, color: UpayColors.adminTextMuted, size: 20),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: UpayColors.accentYellow,
          unselectedLabelColor: UpayColors.adminTextMuted,
          indicatorColor: UpayColors.accentYellow,
          indicatorWeight: 3,
          isScrollable: true,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.radar_rounded), text: 'Live Risk Feed'),
            Tab(icon: Icon(Icons.insights_rounded), text: 'Security Analytics'),
            Tab(icon: Icon(Icons.hub_rounded), text: 'Mule Graph Intelligence'),
            Tab(icon: Icon(Icons.chat_bubble_outline_rounded), text: 'Bangla Scam NLP'),
            Tab(icon: Icon(Icons.history_edu_rounded), text: 'Audit Trail'),
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
                _buildAuditTrailTab(),
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
          if (_highRiskAlert != null) ...[
            _buildHighRiskAlertBanner(_highRiskAlert!),
            const SizedBox(height: 12),
          ],
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
        color: UpayColors.adminCard,
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
      color: UpayColors.adminCard,
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
              color: UpayColors.adminCard,
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
              color: UpayColors.adminCard,
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
          const SizedBox(height: 24),

          // Phase 14: Model Evaluation Metrics
          Text(
            'MODEL EVALUATION METRICS',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: UpayColors.adminCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Synthetic disclaimer badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.purpleAccent.withOpacity(0.4)),
                  ),
                  child: Text(
                    _modelEval.datasetSource,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.purpleAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${_modelEval.modelType} • ${_modelEval.evaluationSplit}',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 14),

                // 4 metrics grid
                Row(
                  children: [
                    Expanded(child: _metricPill('Precision', '${(_modelEval.precision * 100).toStringAsFixed(2)}%', Colors.cyanAccent)),
                    const SizedBox(width: 8),
                    Expanded(child: _metricPill('Recall', '${(_modelEval.recall * 100).toStringAsFixed(2)}%', Colors.greenAccent)),
                    const SizedBox(width: 8),
                    Expanded(child: _metricPill('F1-Score', _modelEval.f1Score.toStringAsFixed(4), Colors.amberAccent)),
                    const SizedBox(width: 8),
                    Expanded(child: _metricPill('ROC-AUC', _modelEval.rocAuc.toStringAsFixed(4), Colors.purpleAccent)),
                  ],
                ),
                const SizedBox(height: 16),

                // Confusion Matrix
                Text(
                  'Held-Out Confusion Matrix (1,200 Samples)',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: UpayColors.adminSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _cmCell('True Negative (Normal)', '${_modelEval.confusionMatrix['true_negative'] ?? 959}', Colors.greenAccent),
                          _cmCell('False Positive (Type I)', '${_modelEval.confusionMatrix['false_positive'] ?? 1}', Colors.orangeAccent),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _cmCell('False Negative (Type II)', '${_modelEval.confusionMatrix['false_negative'] ?? 0}', Colors.redAccent),
                          _cmCell('True Positive (Fraud)', '${_modelEval.confusionMatrix['true_positive'] ?? 240}', Colors.cyanAccent),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Ranked Feature Importances
                Text(
                  'Feature Importance Contribution (SHAP Ranking)',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                ..._modelEval.featuresRanked.map((f) {
                  final name = f['feature'] as String? ?? '';
                  final imp = (f['importance'] as num?)?.toDouble() ?? 0.1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 130,
                          child: Text(
                            name.replaceAll('_', ' ').toUpperCase(),
                            style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: imp / 0.4,
                              minHeight: 8,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(UpayColors.accentYellow),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '${(imp * 100).toInt()}%',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _metricPill(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: UpayColors.adminSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 10, color: Colors.white60)),
          const SizedBox(height: 4),
          Text(val, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _cmCell(String label, String count, Color color) {
    return Column(
      children: [
        Text(count, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white60)),
      ],
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

  // Tab 5: Audit Log & Analyst Actions
  Widget _buildAuditTrailTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AUDIT LOG & ANALYST ACTIONS',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                '${_auditLogs.length} Records',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_auditLogs.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Text(
                'No analyst audit entries recorded yet.',
                style: GoogleFonts.inter(color: Colors.white54),
              ),
            )
          else
            ..._auditLogs.map((log) => _buildAuditLogCard(log)),
        ],
      ),
    );
  }

  Widget _buildAuditLogCard(AuditLogEntry log) {
    final actionColor = switch (log.action.toUpperCase()) {
      'BLOCK' => UpayColors.riskHigh,
      'HOLD' => UpayColors.riskMedium,
      'REVIEW' => Colors.blueAccent,
      'FALSE POSITIVE' => Colors.greenAccent,
      _ => Colors.cyanAccent,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UpayColors.adminCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: actionColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: actionColor.withOpacity(0.6)),
                    ),
                    child: Text(
                      log.action,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: actionColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    log.logId,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                Formatters.formatTimestamp(DateTime.tryParse(log.timestamp) ?? DateTime.now()),
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Analyst: ${log.analystId}',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              Text(
                'Transaction: ${log.transactionId}',
                style: GoogleFonts.inter(fontSize: 12, color: UpayColors.accentYellow),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            log.notes,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildHighRiskAlertBanner(Map<String, dynamic> alert) {
    final txnId = alert['transaction_id']?.toString() ?? 'TXN-10453';
    final amount = (alert['amount'] as num?)?.toDouble() ?? 50000.0;
    final score = alert['risk_score']?.toString() ?? '94';
    final indicators = (alert['indicators'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        ['New Device', 'Unusual Location', 'High Velocity'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UpayColors.riskHigh.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: UpayColors.riskHigh, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: UpayColors.riskHigh.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: UpayColors.riskHigh, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '⚠ HIGH-RISK TRANSACTION DETECTED',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: UpayColors.riskHigh,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                onPressed: () => setState(() => _highRiskAlert = null),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Transaction: $txnId   •   Amount: ${Formatters.currency(amount)}   •   Risk Score: $score/100',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: indicators.map((ind) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: UpayColors.riskHigh.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ind,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFFFFB4B4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: UpayColors.riskHigh,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.search, size: 16),
                label: Text(
                  'Open Investigation',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                onPressed: () {
                  final matching = _transactions.where((t) => t.id == txnId).firstOrNull ??
                      TransactionModel(
                        id: txnId,
                        userId: alert['user_id']?.toString() ?? 'USER001',
                        receiverId: 'USER_ROGUE_99',
                        receiverName: 'Syndicate Node B',
                        receiverPhone: '01999887766',
                        amount: amount,
                        fee: 5.0,
                        total: amount + 5.0,
                        timestamp: DateTime.now(),
                        type: TransactionType.sendMoney,
                        status: TransactionStatus.hold,
                        deviceId: alert['device_id']?.toString() ?? 'DEVICE009',
                        location: alert['location']?.toString() ?? 'Chattogram',
                      );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RiskInvestigationScreen(transaction: matching),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
