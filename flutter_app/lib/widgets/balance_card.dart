import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../core/utils/formatters.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';

class BalanceCard extends StatelessWidget {
  final VoidCallback? onSecurityTap;
  final VoidCallback? onDemoTap;

  const BalanceCard({super.key, this.onSecurityTap, this.onDemoTap});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final walletProvider = context.watch<WalletProvider>();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: UpayColors.accentYellow, // Authentic Upay Signature Yellow
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        children: [
          Row(
            children: [
              // Upay Avatar
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.person, color: UpayColors.primaryBlue, size: 28),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: UpayColors.riskLow,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // User Name & Phone (Synthetic Demo Data)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Demo User (Rahim)',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: UpayColors.primaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user?.phone ?? '01712345678',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: UpayColors.primaryDark.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),

              // "ব্যালেন্স" (Balance) Navy Button
              InkWell(
                onTap: () => walletProvider.toggleBalanceVisibility(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: UpayColors.primaryBlue,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          walletProvider.isBalanceVisible
                              ? Formatters.currency(walletProvider.balance)
                              : 'ব্যালেন্স',
                          key: ValueKey<bool>(walletProvider.isBalanceVisible),
                          style: GoogleFonts.hindSiliguri(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        walletProvider.isBalanceVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Notification Bell
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  tooltip: 'বিজ্ঞপ্তি',
                  icon: const Icon(Icons.notifications_none_rounded, color: UpayColors.primaryDark, size: 22),
                  onPressed: onDemoTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

