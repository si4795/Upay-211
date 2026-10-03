import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/colors.dart';
import '../core/utils/formatters.dart';
import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final (
      IconData icon,
      Color iconColor,
      String titlePrefix,
    ) = switch (transaction.type) {
      TransactionType.sendMoney => (
        Icons.arrow_upward_rounded,
        Colors.redAccent,
        'Send Money to ',
      ),
      TransactionType.cashOut => (
        Icons.account_balance_wallet_outlined,
        Colors.orange,
        'Cash Out ',
      ),
      TransactionType.addMoney => (
        Icons.arrow_downward_rounded,
        Colors.green,
        'Add Money from ',
      ),
      TransactionType.payBill => (
        Icons.receipt_outlined,
        Colors.purple,
        'Pay Bill: ',
      ),
    };

    final (String statusText, Color statusColor) = switch (transaction.status) {
      TransactionStatus.success => ('সফল', UpayColors.riskLow),
      TransactionStatus.verifyRequired => (
        'যাচাই প্রয়োজন',
        UpayColors.riskMedium,
      ),
      TransactionStatus.hold => ('পর্যালোচনাধীন', UpayColors.riskMedium),
      TransactionStatus.blocked => ('অস্থায়ী স্থগিত', UpayColors.riskHigh),
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: UpayColors.borderSubtle),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          '$titlePrefix${transaction.receiverName}',
          style: GoogleFonts.hindSiliguri(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: UpayColors.textDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              transaction.receiverPhone.isNotEmpty
                  ? transaction.receiverPhone
                  : transaction.receiverId,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: UpayColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              Formatters.formatTimestamp(transaction.timestamp),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: UpayColors.textLight,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '- ${Formatters.currency(transaction.amount)}',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: UpayColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusText,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
