import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/transaction_tile.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txnProvider = context.watch<TransactionProvider>();

    return Scaffold(
      backgroundColor: UpayColors.bgLight,
      appBar: AppBar(
        title: Text(
          'লেনদেনের বিবরণ (Statement)',
          style: GoogleFonts.hindSiliguri(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: UpayColors.accentYellow,
          unselectedLabelColor: Colors.white70,
          indicatorColor: UpayColors.accentYellow,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: GoogleFonts.hindSiliguri(fontSize: 14),
          tabs: const [
            Tab(text: 'সবগুলো (Recent)'),
            Tab(text: 'আজকের (Today)'),
            Tab(text: 'এই সপ্তাহের (This Week)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(txnProvider.transactions),
          _buildTransactionList(txnProvider.todayTransactions),
          _buildTransactionList(txnProvider.thisWeekTransactions),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 60, color: UpayColors.textLight.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              'কোন লেনদেন পাওয়া যায়নি',
              style: GoogleFonts.hindSiliguri(
                fontSize: 15,
                color: UpayColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final txn = transactions[index];
        return TransactionTile(
          transaction: txn,
          onTap: () => _showTransactionDetails(context, txn),
        );
      },
    );
  }

  void _showTransactionDetails(BuildContext context, dynamic txn) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'রসিদ বিবরণ',
                  style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _detailRow('ট্রানজেকশন আইডি', txn.id),
            _detailRow('প্রাপক', txn.receiverName),
            _detailRow('প্রাপক নম্বর', txn.receiverPhone),
            _detailRow('পরিমাণ', '৳${txn.amount.toStringAsFixed(2)}'),
            _detailRow('চার্জ', '৳${txn.fee.toStringAsFixed(2)}'),
            _detailRow('সর্বমোট', '৳${txn.total.toStringAsFixed(2)}'),
            _detailRow('স্ট্যাটাস', txn.status.name.toUpperCase()),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.hindSiliguri(color: UpayColors.textMuted, fontSize: 13)),
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
