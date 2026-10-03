import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/quick_action.dart';
import '../../widgets/security_status.dart';
import '../../widgets/transaction_tile.dart';
import '../send_money/send_money_screen.dart';
import '../transactions/transaction_history_screen.dart';
import '../security/customer_security_center_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final recentTxns = context.watch<TransactionProvider>().recentTransactions;

    return Scaffold(
      backgroundColor: UpayColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Balance Card with Avatar & Security shortcut
              BalanceCard(
                onSecurityTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomerSecurityCenterScreen()),
                  );
                },
                onAdminTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                  );
                },
              ),

              const SizedBox(height: 16),

              // AI Fraud Shield Live Status Bar
              SecurityStatusBar(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomerSecurityCenterScreen()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Services Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'সেবাসমূহ (Services)',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: UpayColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 4x2 Grid of Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
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
                      icon: Icons.money_outlined,
                      title: 'ক্যাশ আউট',
                      iconColor: Colors.orange,
                      onTap: () => _showFeatureDialog('ক্যাশ আউট'),
                    ),
                    QuickActionItem(
                      icon: Icons.add_card_rounded,
                      title: 'অ্যাড মানি',
                      iconColor: Colors.teal,
                      onTap: () => _showFeatureDialog('অ্যাড মানি'),
                    ),
                    QuickActionItem(
                      icon: Icons.receipt_long_rounded,
                      title: 'বিল পে',
                      iconColor: Colors.deepPurpleAccent,
                      onTap: () => _showFeatureDialog('বিল পে'),
                    ),
                    QuickActionItem(
                      icon: Icons.shopping_bag_outlined,
                      title: 'পেমেন্ট',
                      iconColor: Colors.indigo,
                      onTap: () => _showFeatureDialog('পেমেন্ট'),
                    ),
                    QuickActionItem(
                      icon: Icons.phone_android_rounded,
                      title: 'রিচার্জ',
                      iconColor: Colors.pinkAccent,
                      onTap: () => _showFeatureDialog('মোবাইল রিচার্জ'),
                    ),
                    QuickActionItem(
                      icon: Icons.savings_outlined,
                      title: 'সেভিংস',
                      iconColor: Colors.amber.shade800,
                      onTap: () => _showFeatureDialog('সেভিংস'),
                    ),
                    QuickActionItem(
                      icon: Icons.grid_view_rounded,
                      title: 'আরও',
                      iconColor: Colors.blueGrey,
                      onTap: () => _showFeatureDialog('অন্যান্য সেবা'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recent Transactions Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'সাম্প্রতিক লেনদেন (Recent)',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: UpayColors.textDark,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
                        );
                      },
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

              // Recent Transactions List (Customer view - NO risk score!)
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
                ...recentTxns.map((t) => TransactionTile(transaction: t)),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
            ).then((_) => setState(() => _bottomNavIndex = 0));
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomerSecurityCenterScreen()),
            ).then((_) => setState(() => _bottomNavIndex = 0));
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ).then((_) => setState(() => _bottomNavIndex = 0));
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: UpayColors.primaryBlue,
        unselectedItemColor: UpayColors.textLight,
        selectedLabelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.hindSiliguri(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'হোম',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'লেনদেন',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security_rounded),
            label: 'সিকিউরিটি',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'প্রোফাইল',
          ),
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
