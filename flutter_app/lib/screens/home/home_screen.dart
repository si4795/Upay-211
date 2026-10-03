import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/quick_action.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/transaction_risk_detail_sheet.dart';
import '../../widgets/demo_scenario_sheet.dart';
import '../send_money/send_money_screen.dart';
import '../transactions/transaction_history_screen.dart';
import '../account/account_screen.dart';
import '../more/more_screen.dart';
import '../qr/bangla_qr_screen.dart';
import '../security/trust_and_safety_center_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomNavIndex = 0; // 0: Home, 1: Account, 2: History, 3: More

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UpayColors.bgLight,
      body: SafeArea(
        child: IndexedStack(
          index: _bottomNavIndex,
          children: [
            _buildHomeContent(),
            const AccountScreen(),
            const TransactionHistoryScreen(),
            const MoreScreen(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 24),
        child: FloatingActionButton(
          elevation: 4,
          backgroundColor: Colors.white,
          shape: const CircleBorder(
            side: BorderSide(color: UpayColors.primaryBlue, width: 3),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BanglaQrScreen()),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_scanner_rounded, color: Colors.teal, size: 24),
              Text(
                'BANGLA QR',
                style: GoogleFonts.inter(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: UpayColors.primaryBlue,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        color: Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              Expanded(
                child: _buildBottomNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'হোম',
                ),
              ),
              Expanded(
                child: _buildBottomNavItem(
                  index: 1,
                  icon: Icons.wallet_rounded,
                  label: 'অ্যাকাউন্ট',
                ),
              ),
              const SizedBox(width: 48), // Spacer for center BANGLA QR button
              Expanded(
                child: _buildBottomNavItem(
                  index: 2,
                  icon: Icons.history_rounded,
                  label: 'হিস্টরি',
                ),
              ),
              Expanded(
                child: _buildBottomNavItem(
                  index: 3,
                  icon: Icons.more_horiz_rounded,
                  label: 'আরো',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _bottomNavIndex == index;
    return InkWell(
      onTap: () => setState(() => _bottomNavIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? UpayColors.primaryBlue : UpayColors.textLight,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.hindSiliguri(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? UpayColors.primaryBlue : UpayColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    final recentTxns = context.watch<TransactionProvider>().recentTransactions;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Authentic Upay Yellow Balance Header
          BalanceCard(
            onSecurityTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrustAndSafetyCenterScreen()),
              );
            },
            onDemoTap: () => DemoScenarioSheet.show(context),
          ),

          // 2. AI Fraud Shield Live Status Bar & Demo Launch
          Container(
            margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: UpayColors.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: UpayColors.riskLow.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_rounded, color: UpayColors.riskLow, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TrustAndSafetyCenterScreen()),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI ট্রাস্ট অ্যান্ড সেফটি শিল্ড সক্রিয় (৯৮%)',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: UpayColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'রিয়েল-টাইম আচরণ ও নেটওয়ার্ক নজরদারি চলছে',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 10.5,
                            color: UpayColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: () => DemoScenarioSheet.show(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    backgroundColor: UpayColors.accentYellow.withOpacity(0.25),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'ডেমো সিনারিও',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: UpayColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 3. Quick Actions Grid (Inspired by Upay MFS App)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 10,
              mainAxisExtent: 90,
              children: [
                QuickActionItem(
                  icon: Icons.send_rounded,
                  title: 'সেন্ড মানি',
                  iconColor: Colors.blueAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SendMoneyScreen()),
                    );
                  },
                ),
                QuickActionItem(
                  icon: Icons.phone_android_rounded,
                  title: 'মোবাইল রিচার্জ',
                  iconColor: Colors.teal,
                  onTap: () => _showFeatureDialog('মোবাইল রিচার্জ'),
                ),
                QuickActionItem(
                  icon: Icons.money_outlined,
                  title: 'ক্যাশ আউট',
                  iconColor: Colors.orange,
                  onTap: () => _showFeatureDialog('ক্যাশ আউট'),
                ),
                QuickActionItem(
                  icon: Icons.receipt_long_rounded,
                  title: 'পে বিল',
                  iconColor: Colors.deepPurpleAccent,
                  onTap: () => _showFeatureDialog('পে বিল'),
                ),
                QuickActionItem(
                  icon: Icons.add_card_rounded,
                  title: 'অ্যাড মানি',
                  iconColor: Colors.indigo,
                  onTap: () => _showFeatureDialog('অ্যাড মানি'),
                ),
                QuickActionItem(
                  icon: Icons.savings_outlined,
                  title: 'সঞ্চয়',
                  iconColor: Colors.amber.shade800,
                  onTap: () => _showFeatureDialog('সঞ্চয়'),
                ),
                QuickActionItem(
                  icon: Icons.sync_alt_rounded,
                  title: 'ফান্ড ট্রান্সফার',
                  iconColor: Colors.cyan.shade700,
                  onTap: () => _showFeatureDialog('ফান্ড ট্রান্সফার'),
                ),
                QuickActionItem(
                  icon: Icons.request_page_outlined,
                  title: 'রিকোয়েস্ট মানি',
                  iconColor: Colors.pinkAccent,
                  onTap: () => _showFeatureDialog('রিকোয়েস্ট মানি'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Promotional Banner (Upay Offers Carousel Simulation)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D325E), Color(0xFF1E5B99)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: UpayColors.accentYellow,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ট্র্যাক ০১ প্রেজেন্টেশন',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: UpayColors.primaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'upay ট্রাস্ট অ্যান্ড রিস্ক ইন্টেলিজেন্স',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'প্রতিটি লেনদেনে মেশিন লার্নিং ও গ্রাফ ফ্রড গার্ড',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.security_update_good_rounded, color: UpayColors.accentYellow, size: 40),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 5. Recent Transactions Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'সাম্প্রতিক লেনদেন (Recent)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: UpayColors.textDark,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _bottomNavIndex = 2),
                  child: Text(
                    'সব দেখুন',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: UpayColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Recent Transactions List (Customer View with Risk Indicators)
          if (recentTxns.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'কোনো সাম্প্রতিক লেনদেন নেই',
                  style: GoogleFonts.hindSiliguri(color: UpayColors.textMuted),
                ),
              ),
            )
          else
            ...recentTxns.map((t) {
              return TransactionTile(
                transaction: t,
                onTap: () => TransactionRiskDetailSheet.show(context, t),
              );
            }),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showFeatureDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
        content: Text(
          '$feature সেবাটি এই ট্র্যাক ০১ সিমুলেশনে ডেমো হিসাবে অন্তর্ভুক্ত। প্রধান ফোকাস সেন্ড মানি এবং ট্রাস্ট অ্যান্ড রিস্ক ইন্টেলিজেন্স ইঞ্জিনের উপর।',
          style: GoogleFonts.hindSiliguri(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ঠিক আছে', style: GoogleFonts.hindSiliguri()),
          ),
        ],
      ),
    );
  }
}

