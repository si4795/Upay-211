import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../core/utils/formatters.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import 'upay_icons.dart';

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
      color: UpayColors.accentYellow, // Authentic Upay Yellow (#FFC800)
      padding: const EdgeInsets.fromLTRB(16, 8, 14, 12),
      child: Row(
        children: [
          // 1. Authentic Upay Circular Logo Avatar matching pic1.jpeg
          InkWell(
            onTap: onSecurityTap,
            borderRadius: BorderRadius.circular(25),
            child: const UpayLogoAvatar(size: 46),
          ),
          const SizedBox(width: 12),

          // 2. User Name & Phone Number matching pic1.jpeg ("Homanur Bagum", "01303069631")
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user?.name ?? 'Homanur Bagum',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user?.phone ?? '01303069631',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF334155),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),

          // 3. "ব্যালেন্স" (Balance) Authentic Upay Blue Pill Button
          InkWell(
            onTap: () => walletProvider.toggleBalanceVisibility(),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF005CB9), // Upay Royal Blue
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF005CB9).withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: Text(
                  walletProvider.isBalanceVisible
                      ? Formatters.currency(walletProvider.balance)
                      : 'ব্যালেন্স',
                  key: ValueKey<bool>(walletProvider.isBalanceVisible),
                  style: GoogleFonts.hindSiliguri(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 4. Notification Bell Icon with Red Alert Dot matching pic1.jpeg
          InkWell(
            onTap: onDemoTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Stack(
                children: [
                  const Icon(
                    Icons.notifications_rounded,
                    color: Color(0xFF005CB9),
                    size: 27,
                  ),
                  Positioned(
                    right: 2,
                    top: 1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
