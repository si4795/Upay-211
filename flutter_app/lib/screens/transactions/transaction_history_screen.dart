import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/transaction_risk_detail_sheet.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilterIndex = 0;

  final List<String> _filterCategories = [
    'সব',
    'সেন্ড মানি',
    'রিসিভড মানি',
    'মোবাইল রিচার্জ',
    'পে বিল',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txnProvider = context.watch<TransactionProvider>();
    final allTxns = txnProvider.transactions;

    return Scaffold(
      backgroundColor: UpayColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: UpayColors.textDark,
        elevation: 0,
        title: Text(
          'হিস্টরি',
          style: GoogleFonts.hindSiliguri(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: UpayColors.primaryBlue,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: UpayColors.accentYellow,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: UpayColors.primaryDark,
              unselectedLabelColor: UpayColors.textMuted,
              labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: const [
                Tab(text: 'লেনদেন বিবরণী'),
                Tab(text: 'লেনদেন সারসংক্ষেপ'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatementTab(allTxns),
          _buildSummaryTab(allTxns),
        ],
      ),
    );
  }

  // Tab 1: লেনদেন বিবরণী (Statement with filter chips & risk-badged list)
  Widget _buildStatementTab(List<TransactionModel> transactions) {
    final filtered = _getFilteredTransactions(transactions);

    return Column(
      children: [
        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: List.generate(_filterCategories.length, (index) {
              final isSelected = _selectedFilterIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_filterCategories[index]),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFilterIndex = index);
                  },
                  selectedColor: UpayColors.accentYellow,
                  backgroundColor: Colors.white,
                  labelStyle: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? UpayColors.primaryDark : UpayColors.textDark,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? UpayColors.accentYellow : UpayColors.borderSubtle,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // Transaction list
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final txn = filtered[index];
                    return TransactionTile(
                      transaction: txn,
                      onTap: () => TransactionRiskDetailSheet.show(context, txn),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<TransactionModel> _getFilteredTransactions(List<TransactionModel> list) {
    switch (_selectedFilterIndex) {
      case 1:
        return list.where((t) => t.type == TransactionType.sendMoney).toList();
      case 2:
        return list.where((t) => t.type == TransactionType.addMoney).toList();
      case 3:
        return list.where((t) => t.receiverName.contains('Recharge')).toList();
      case 4:
        return list.where((t) => t.type == TransactionType.payBill).toList();
      case 0:
      default:
        return list;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: UpayColors.accentYellow.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded, size: 40, color: UpayColors.primaryBlue),
          ),
          const SizedBox(height: 16),
          Text(
            'আপনার এখনো কোনো ট্রানজেকশন রেকর্ড নেই।',
            style: GoogleFonts.hindSiliguri(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: UpayColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // Tab 2: লেনদেন সারসংক্ষেপ (Summary with Category Donut Chart)
  Widget _buildSummaryTab(List<TransactionModel> transactions) {
    double totalSendMoney = 0;
    double totalBills = 0;
    double totalCashOut = 0;

    for (final t in transactions) {
      if (t.type == TransactionType.sendMoney) totalSendMoney += t.amount;
      if (t.type == TransactionType.payBill) totalBills += t.amount;
      if (t.type == TransactionType.cashOut) totalCashOut += t.amount;
    }

    final totalExpense = totalSendMoney + totalBills + totalCashOut;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'October 2026 (সমস্ত খরচ)',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: UpayColors.primaryBlue,
                ),
              ),
              const Icon(Icons.chevron_right, color: UpayColors.textMuted),
            ],
          ),
          const SizedBox(height: 20),

          // Donut Chart Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: UpayColors.borderSubtle),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 55,
                          sections: [
                            PieChartSectionData(
                              value: totalSendMoney > 0 ? totalSendMoney : 1,
                              color: Colors.blueAccent,
                              title: '',
                              radius: 22,
                            ),
                            PieChartSectionData(
                              value: totalBills > 0 ? totalBills : 1,
                              color: Colors.deepPurpleAccent,
                              title: '',
                              radius: 22,
                            ),
                            PieChartSectionData(
                              value: totalCashOut > 0 ? totalCashOut : 1,
                              color: Colors.orange,
                              title: '',
                              radius: 22,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ব্যয়',
                            style: GoogleFonts.hindSiliguri(fontSize: 12, color: UpayColors.textMuted),
                          ),
                          Text(
                            Formatters.currency(totalExpense),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: UpayColors.primaryBlue,
                            ),
                          ),
                          Text(
                            'October',
                            style: GoogleFonts.inter(fontSize: 11, color: UpayColors.textLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSummaryCategoryRow('সেন্ড মানি', totalSendMoney, Colors.blueAccent),
                _buildSummaryCategoryRow('পে বিল', totalBills, Colors.deepPurpleAccent),
                _buildSummaryCategoryRow('ক্যাশ আউট', totalCashOut, Colors.orange),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'সারসংক্ষেপ বিবরণ',
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: UpayColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          _buildStatementTile('ক্যাশ ইন', 0.0, Icons.phone_android_rounded),
          _buildStatementTile('অ্যাড মানি', 0.0, Icons.account_balance_wallet_outlined),
          _buildStatementTile('রিসিভড মানি', 0.0, Icons.download_rounded),
          _buildStatementTile('রেমিট্যান্স', 0.0, Icons.public_rounded),
        ],
      ),
    );
  }

  Widget _buildSummaryCategoryRow(String title, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.hindSiliguri(fontSize: 13, color: UpayColors.textDark)),
            ],
          ),
          Text(Formatters.currency(amount), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatementTile(String title, double amount, IconData icon) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: UpayColors.borderSubtle),
      ),
      child: ListTile(
        leading: Icon(icon, color: UpayColors.primaryBlue),
        title: Text(title, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
        trailing: Text(Formatters.currency(amount), style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

