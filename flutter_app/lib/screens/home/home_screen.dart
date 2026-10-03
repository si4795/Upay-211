import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/upay_icons.dart';
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
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(
              index: _bottomNavIndex,
              children: [
                _buildHomeContent(),
                const AccountScreen(),
                const TransactionHistoryScreen(),
                const MoreScreen(),
              ],
            ),

            // Dual Floating Pills ("উপায় কার্ড" and "উপায় অফার") matching pic1.jpeg & pic2.jpeg
            if (_bottomNavIndex == 0)
              Positioned(
                left: 10,
                right: 10,
                bottom: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _buildFloatingPill(
                          label: 'উপায় কার্ড',
                          iconWidget: Container(
                            width: 24,
                            height: 16,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF005CB9), Color(0xFF0089D0)],
                              ),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFC800),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          onTap: () => _showFeatureModal(context, 'উপায় কার্ড', 'আপনার প্রিপেইড ও ভার্চুয়াল উপায় কার্ড ব্যবস্থাপনা করুন।'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _buildFloatingPill(
                          label: 'উপায় অফার',
                          iconWidget: const Icon(
                            Icons.card_giftcard_rounded,
                            color: Color(0xFF005CB9),
                            size: 20,
                          ),
                          onTap: () => DemoScenarioSheet.show(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 22),
        width: 64,
        height: 64,
        child: FloatingActionButton(
          elevation: 4,
          backgroundColor: Colors.white,
          shape: const CircleBorder(
            side: BorderSide(color: Color(0xFF005CB9), width: 3.5),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BanglaQrScreen()),
            );
          },
          child: const BanglaQrIcon(size: 44),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 62,
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
              const SizedBox(width: 64), // Center notch spacer for BANGLA QR
              Expanded(
                child: _buildBottomNavItem(
                  index: 2,
                  icon: Icons.access_time_filled_rounded,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? const Color(0xFF005CB9) : const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.hindSiliguri(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected ? const Color(0xFF005CB9) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingPill({
    required String label,
    required Widget iconWidget,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9E6), // Cream-Yellow Pill Background
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFE082), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 8),
            iconWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Authentic Upay Signature Yellow Header matching pic1.jpeg
          BalanceCard(
            onSecurityTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrustAndSafetyCenterScreen()),
              );
            },
            onDemoTap: () => DemoScenarioSheet.show(context),
          ),

          // 2. Primary Upay Services Grid (White Card Container) matching pic1.jpeg
          Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Row 1: সেন্ড মানি, মোবাইল রিচার্জ, ক্যাশ আউট, পে বিল
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPrimaryService(
                      label: 'সেন্ড মানি',
                      icon: _buildSvgLikeIcon(
                        bg: const Color(0xFFE0F2FE),
                        child: const Icon(Icons.arrow_outward_rounded, color: Color(0xFF0284C7), size: 24),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SendMoneyScreen()),
                        );
                      },
                    ),
                    _buildPrimaryService(
                      label: 'মোবাইল রিচার্জ',
                      icon: _buildSvgLikeIcon(
                        bg: const Color(0xFFE0F2FE),
                        child: const Icon(Icons.phone_android_rounded, color: Color(0xFF0284C7), size: 24),
                      ),
                      onTap: () => _showFeatureModal(context, 'মোবাইল রিচার্জ', 'যেকোনো মোবাইল অপারেটরে রিচার্জ করুন ক্যাশব্যাক সহ।'),
                    ),
                    _buildPrimaryService(
                      label: 'ক্যাশ আউট',
                      icon: _buildSvgLikeIcon(
                        bg: const Color(0xFFE0F2FE),
                        child: const Icon(Icons.outbox_rounded, color: Color(0xFF0284C7), size: 24),
                      ),
                      onTap: () => _showFeatureModal(context, 'ক্যাশ আউট', 'নিকটস্থ উপায় এজেন্ট পয়েন্ট থেকে সর্বনিম্ন খরচে ক্যাশ আউট করুন।'),
                    ),
                    _buildPrimaryService(
                      label: 'পে বিল',
                      icon: _buildSvgLikeIcon(
                        bg: const Color(0xFFE0F2FE),
                        child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF0284C7), size: 24),
                      ),
                      onTap: () => _showFeatureModal(context, 'পে বিল', 'বিদ্যুৎ, গ্যাস, পানি এবং ইন্টারনেট বিল পরিশোধ করুন কোনো চার্জ ছাড়াই।'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Row 2: অ্যাড মানি, সঞ্চয়, ফান্ড ট্রান্সফার, রিকোয়েস্ট মানি
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPrimaryService(
                      label: 'অ্যাড মানি',
                      icon: _buildSvgLikeIcon(
                        bg: const Color(0xFFF3E8FF),
                        child: const Icon(Icons.add_card_rounded, color: Color(0xFF7C3AED), size: 24),
                      ),
                      onTap: () => _showFeatureModal(context, 'অ্যাড মানি', 'ব্যাংক বা ভিসা/মাস্টারকার্ড থেকে সহজে ফান্ড যোগ করুন।'),
                    ),
                    _buildPrimaryService(
                      label: 'সঞ্চয়',
                      icon: _buildSvgLikeIcon(
                        bg: const Color(0xFFFEF3C7),
                        child: const Icon(Icons.savings_rounded, color: Color(0xFFD97706), size: 24),
                      ),
                      onTap: () => _showFeatureModal(context, 'সঞ্চয়', 'উপায় ডিজিটাল সেভিংস দিয়ে নিশ্চিত মুনাফা অর্জন করুন।'),
                    ),
                    _buildPrimaryService(
                      label: 'ফান্ড ট্রান্সফার',
                      icon: _buildSvgLikeIcon(
                        bg: const Color(0xFFE0F2FE),
                        child: const Icon(Icons.account_balance_rounded, color: Color(0xFF0284C7), size: 24),
                      ),
                      onTap: () => _showFeatureModal(context, 'ফান্ড ট্রান্সফার', 'যেকোনো ব্যাংক অ্যাকাউন্টে তাৎক্ষণিক টাকা পাঠান।'),
                    ),
                    _buildPrimaryService(
                      label: 'রিকোয়েস্ট মানি',
                      icon: _buildSvgLikeIcon(
                        bg: const Color(0xFFFCE7F3),
                        child: const Icon(Icons.mark_unread_chat_alt_rounded, color: Color(0xFFDB2777), size: 24),
                      ),
                      onTap: () => _showFeatureModal(context, 'রিকোয়েস্ট মানি', 'প্রিয়জনদের কাছে সহজে টাকার রিকোয়েস্ট পাঠান।'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Row 3: মেক পেমেন্ট, রেফার ও আর্ন, এনপিএসবি
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPrimaryService(
                      label: 'মেক পেমেন্ট',
                      icon: _buildSvgLikeIcon(
                        bg: const Color(0xFFE0F2FE),
                        child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF0284C7), size: 24),
                      ),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BanglaQrScreen())),
                    ),
                    _buildPrimaryService(
                      label: 'রেফার ও আর্ন',
                      icon: _buildSvgLikeIcon(
                        bg: const Color(0xFFE0F2FE),
                        child: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF0284C7), size: 24),
                      ),
                      onTap: () => _showFeatureModal(context, 'রেফার ও আর্ন', 'বন্ধুদের উপায় অ্যাপ রেফার করে জিতে নিন নগদ বোনাস!'),
                    ),
                    _buildPrimaryService(
                      label: 'এনপিএসবি',
                      icon: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Center(
                          child: Text(
                            'NPSB',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF005CB9),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      onTap: () => _showFeatureModal(context, 'NPSB', 'National Payment Switch Bangladesh (NPSB) কানেক্টিভিটি।'),
                    ),
                    const SizedBox(width: 72), // Empty balance column to align with 4-item grid
                  ],
                ),
              ],
            ),
          ),

          // 3. Promotional Banner Carousel (Cirkle Recharge Cashback) matching pic1.jpeg
          _buildPromotionalBanner(),

          const SizedBox(height: 14),

          // 4. "উপায় পেমেন্ট" Section matching pic1.jpeg & pic2.jpeg
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'উপায় পেমেন্ট',
              style: GoogleFonts.hindSiliguri(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF005CB9),
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 0.86,
              children: [
                _buildPaymentItem('ট্রাফিক ফাইন', Icons.traffic_rounded, const Color(0xFF16A34A)),
                _buildPaymentItem('টোল পেমেন্ট', Icons.garage_rounded, const Color(0xFF0284C7)),
                _buildPaymentItem('সরকারি পেমেন্ট', Icons.account_balance_rounded, const Color(0xFFDC2626)),
                _buildPaymentItem('এডুকেশন', Icons.school_rounded, const Color(0xFF9333EA)),
                _buildPaymentItem('এন জি ও', Icons.volunteer_activism_rounded, const Color(0xFF0284C7)),
                _buildPaymentItem('বীমা', Icons.health_and_safety_rounded, const Color(0xFF0D9488)),
                _buildPaymentItem('ডোনেশন', Icons.card_giftcard_rounded, const Color(0xFF2563EB)),
                _buildPaymentItem('যাকাত পেমেন্ট', Icons.monetization_on_rounded, const Color(0xFF16A34A)),
                _buildPaymentItem('টিকেট', Icons.confirmation_number_rounded, const Color(0xFF7C3AED)),
                _buildPaymentItem('জিপি ফ্লেক্সিপ্ল্যান', Icons.apps_rounded, const Color(0xFF0284C7)),
                _buildPaymentItem('হোটেল', Icons.apartment_rounded, const Color(0xFFEA580C)),
                _buildPaymentItem('আবেদন ফি', Icons.description_rounded, const Color(0xFF0284C7)),
                _buildPaymentItem('Othoba', Icons.shopping_bag_rounded, const Color(0xFF2563EB)),
                _buildPaymentItem('মেট্রোরেল', Icons.train_rounded, const Color(0xFF16A34A)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 5. "অন্যান্য সার্ভিস" Section matching pic2.jpeg
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'অন্যান্য সার্ভিস',
              style: GoogleFonts.hindSiliguri(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF005CB9),
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 0.86,
              children: [
                _buildPaymentItem('পেওনিয়ার', Icons.change_circle_rounded, const Color(0xFFEA580C)),
                _buildPaymentItem('উপায় চাকা', Icons.pie_chart_rounded, const Color(0xFFEAB308)),
                _buildPaymentItem('মিউজিক', Icons.music_note_rounded, const Color(0xFF0284C7)),
                _buildPaymentItem('ই-লার্নিং', Icons.menu_book_rounded, const Color(0xFF2563EB)),
                _buildPaymentItem('গেমস', Icons.sports_esports_rounded, const Color(0xFF7C3AED)),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPrimaryService({
    required String label,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.hindSiliguri(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSvgLikeIcon({required Color bg, required Widget child}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: child),
    );
  }

  Widget _buildPaymentItem(String label, IconData icon, Color color) {
    return InkWell(
      onTap: () => _showFeatureModal(context, label, '$label পেমেন্ট প্রক্রিয়াধীন। নিরাপদে বিল পরিশোধ করুন।'),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.hindSiliguri(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionalBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF003875), Color(0xFF005CB9)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF005CB9).withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'cirkle',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'upay থেকে cirkle রিচার্জে আনলিমিটেড ক্যাশব্যাক',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _buildOfferTag('৳১০ ক্যাশব্যাক (২২৮৳ ৩০ জিবি)'),
                          _buildOfferTag('৳৯ ক্যাশব্যাক (২৪৯৳ ২৫ জিবি)'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => DemoScenarioSheet.show(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC800),
                    foregroundColor: const Color(0xFF003875),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(
                    'ক্লিক করুন',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // 3 indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIndicatorDot(active: true),
              const SizedBox(width: 5),
              _buildIndicatorDot(active: false),
              const SizedBox(width: 5),
              _buildIndicatorDot(active: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfferTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.hindSiliguri(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildIndicatorDot({required bool active}) {
    return Container(
      width: active ? 14 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF005CB9) : const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  void _showFeatureModal(BuildContext context, String title, String description) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const UpayLogoAvatar(size: 36),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF005CB9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005CB9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
                child: Text(
                  'ঠিক আছে',
                  style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
