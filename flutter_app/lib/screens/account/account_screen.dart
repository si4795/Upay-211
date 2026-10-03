import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: UpayColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'অ্যাকাউন্ট',
          style: GoogleFonts.hindSiliguri(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: UpayColors.primaryBlue,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: UpayColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: UpayColors.accentYellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: UpayColors.primaryBlue, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Demo User',
                          style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user?.phone ?? '01712345678',
                          style: GoogleFonts.inter(fontSize: 13, color: UpayColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('ব্যালেন্স', style: GoogleFonts.hindSiliguri(fontSize: 11, color: UpayColors.textMuted)),
                      Text(
                        Formatters.currency(wallet.balance),
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: UpayColors.primaryBlue),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Wallets Section Header
            Text(
              'ওয়ালেট',
              style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: UpayColors.textDark),
            ),
            const SizedBox(height: 12),

            // 2x2 Grid of Wallets (Primary, Disbursement, Secondary, Remittance)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildWalletCard(
                  title: 'প্রাইমারি',
                  amount: wallet.balance,
                  bgColor: const Color(0xFFE8F4FD),
                  icon: Icons.account_balance_wallet,
                ),
                _buildWalletCard(
                  title: 'ডিসবার্সমেন্ট',
                  amount: 0.0,
                  bgColor: const Color(0xFFFDF0E8),
                  icon: Icons.receipt_long,
                ),
                _buildWalletCard(
                  title: 'সেকেন্ডারি',
                  amount: 0.0,
                  bgColor: const Color(0xFFF3E8FD),
                  icon: Icons.wallet,
                ),
                _buildWalletCard(
                  title: 'রেমিট্যান্স',
                  amount: 0.0,
                  bgColor: const Color(0xFFF0FDE8),
                  icon: Icons.public,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Cash Reward Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.card_giftcard, color: Colors.amber, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'ক্যাশ রিওয়ার্ড',
                            style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        '৳ ৫০.০০',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: UpayColors.primaryDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'আপনি মোবাইল রিচার্জসহ, সব ধরণের পেমেন্ট এবং বিল পরিশোধের জন্য এই ক্যাশ রিওয়ার্ড ব্যালেন্স ব্যবহার করতে পারবেন।',
                    style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.brown.shade700),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Linked Services
            _buildActionItem(
              title: 'প্রিপেইড কার্ড',
              actionLabel: '+ রিকোয়েস্ট',
              icon: Icons.credit_card,
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _buildActionItem(
              title: 'লিংকড ক্রেডিট কার্ড (শুধুমাত্র ইউসিবি)',
              actionLabel: '+ লিঙ্ক',
              icon: Icons.add_card,
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _buildActionItem(
              title: 'লিংকড অ্যাকাউন্ট (শুধুমাত্র ইউসিবি)',
              actionLabel: '+ লিঙ্ক',
              icon: Icons.account_balance,
              onTap: () {},
            ),

            const SizedBox(height: 16),

            // Info rows
            _buildNavRow('লিমিট ও ইউসেজ', Icons.tune, () {}),
            const SizedBox(height: 10),
            _buildNavRow('সার্ভিস চার্জ', Icons.percent, () {}),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard({
    required String title,
    required double amount,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.bold, color: UpayColors.textDark),
              ),
              Icon(icon, size: 18, color: UpayColors.primaryBlue.withOpacity(0.5)),
            ],
          ),
          Text(
            Formatters.currency(amount),
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: UpayColors.primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required String title,
    required String actionLabel,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: UpayColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: UpayColors.primaryBlue, size: 20),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          Text(actionLabel, style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
        ],
      ),
    );
  }

  Widget _buildNavRow(String title, IconData icon, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: UpayColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: UpayColors.primaryBlue, size: 20),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const Icon(Icons.chevron_right, color: UpayColors.textLight, size: 20),
        ],
      ),
    );
  }
}

