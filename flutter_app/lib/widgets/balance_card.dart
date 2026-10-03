import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../core/utils/formatters.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';

class BalanceCard extends StatelessWidget {
  final VoidCallback? onSecurityTap;
  final VoidCallback? onAdminTap;

  const BalanceCard({super.key, this.onSecurityTap, this.onAdminTap});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final walletProvider = context.watch<WalletProvider>();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: UpayColors.primaryBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Profile row
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: UpayColors.accentYellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: UpayColors.primaryBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'উপায় ইউজার',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      user?.phone ?? '01700000000',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              if (onSecurityTap != null)
                IconButton(
                  tooltip: 'Security Status',
                  icon: const Icon(
                    Icons.security,
                    color: UpayColors.accentYellow,
                    size: 24,
                  ),
                  onPressed: onSecurityTap,
                ),
              if (onAdminTap != null)
                IconButton(
                  tooltip: 'Admin / Fraud Analyst Portal',
                  icon: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: onAdminTap,
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Tap to reveal balance container
          Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => walletProvider.toggleBalanceVisibility(),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: UpayColors.accentYellow.withOpacity(0.6),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: UpayColors.accentYellow,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          walletProvider.isBalanceVisible
                              ? Formatters.currency(walletProvider.balance)
                              : 'ব্যালেন্স দেখতে ট্যাপ করুন',
                          key: ValueKey<bool>(walletProvider.isBalanceVisible),
                          style: GoogleFonts.hindSiliguri(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        walletProvider.isBalanceVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

