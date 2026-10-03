import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';
import '../core/utils/formatters.dart';
import '../models/transaction.dart';
import '../models/risk_result.dart';

class TransactionRiskDetailSheet extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionRiskDetailSheet({super.key, required this.transaction});

  static void show(BuildContext context, TransactionModel transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionRiskDetailSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final risk = transaction.riskResult;
    final score = risk?.riskScore ?? (transaction.status == TransactionStatus.hold ? 94 : 12);
    final level = risk?.riskLevel ?? RiskResult.calculateLevel(score);

    final (Color themeColor, String levelText, IconData levelIcon) = switch (level) {
      RiskLevel.low => (UpayColors.riskLow, 'নিম্ন ঝুঁকি (LOW RISK)', Icons.shield_rounded),
      RiskLevel.medium => (UpayColors.riskMedium, 'মধ্যম ঝুঁকি (MEDIUM RISK)', Icons.warning_amber_rounded),
      RiskLevel.high => (UpayColors.riskHigh, 'উচ্চ ঝুঁকি (HIGH RISK)', Icons.gpp_bad_rounded),
    };

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'লেনদেন ও নিরাপত্তা বিশ্লেষণ',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: UpayColors.textDark,
                      ),
                    ),
                    Text(
                      'ID: ${transaction.id}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: UpayColors.textMuted,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Receipt Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: UpayColors.bgLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: UpayColors.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        Text(
                          Formatters.currency(transaction.amount),
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: UpayColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'প্রাপক: ${transaction.receiverName} (${transaction.receiverPhone.isNotEmpty ? transaction.receiverPhone : transaction.receiverId})',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            color: UpayColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              Formatters.formatTimestamp(transaction.timestamp),
                              style: GoogleFonts.inter(fontSize: 11, color: UpayColors.textLight),
                            ),
                            const Text(' • '),
                            Text(
                              transaction.location,
                              style: GoogleFonts.inter(fontSize: 11, color: UpayColors.textLight),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Risk Intelligence Hero Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: themeColor.withOpacity(0.35), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(levelIcon, color: themeColor, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  levelText,
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: themeColor,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: themeColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'স্কোর: $score/১০০',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: score / 100.0,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                          borderRadius: BorderRadius.circular(6),
                          minHeight: 7,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('০-৩৯ নিম্ন', style: GoogleFonts.hindSiliguri(fontSize: 10, color: UpayColors.riskLow)),
                            Text('৪০-৬৯ মধ্যম', style: GoogleFonts.hindSiliguri(fontSize: 10, color: UpayColors.riskMedium)),
                            Text('৭০-১০০ উচ্চ ঝুঁকি', style: GoogleFonts.hindSiliguri(fontSize: 10, color: UpayColors.riskHigh)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Explainable Risk Factors Section
                  Text(
                    'সনাক্তকৃত ঝুঁকি ও ব্যাখ্যামূলক ফ্যাক্টর (Explainable AI)',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: UpayColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (risk != null && risk.riskFactors.isNotEmpty)
                    ...risk.riskFactors.map((factor) => _buildFactorTile(factor))
                  else
                    _buildDefaultFactors(score),

                  const SizedBox(height: 24),

                  // AI Security Assistant (Answers the 3 Required Questions)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          UpayColors.primaryDark,
                          UpayColors.primaryBlue,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: UpayColors.primaryBlue.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: UpayColors.accentYellow.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.auto_awesome, color: UpayColors.accentYellow, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'AI সিকিউরিটি অ্যাসিস্ট্যান্ট ইনভেস্টিগেশন',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Question 1: What happened?
                        _buildAiQuestionCard(
                          question: '১. ঘটনাটি কী ছিল? (What happened?)',
                          answer: risk?.whatHappened ??
                              'আজ ${transaction.timestamp.hour}:${transaction.timestamp.minute.toString().padLeft(2, '0')} ঘটিকায় '
                              '${transaction.location} থেকে ${transaction.receiverName} নম্বরে ${Formatters.currency(transaction.amount)} পাঠানোর অনুরোধ প্রক্রিয়া হয়।',
                          icon: Icons.info_outline,
                        ),

                        const SizedBox(height: 12),

                        // Question 2: Why is this transaction risky?
                        _buildAiQuestionCard(
                          question: '২. কেন এটি ঝুঁকিপূর্ণ? (Why is this transaction risky?)',
                          answer: risk?.whyRisky ??
                              (score >= 70
                                  ? 'অ্যাকাউন্ট টেকওভার (ATO) এবং মানি-মিউল সিন্ডিকেটের সংকেত মিলেছে। ঐতিহাসিক ব্যবহারের চেয়ে বহুগুণ বেশি অংক এবং নতুন ডিভাইস সংকেত রয়েছে।'
                                  : score >= 40
                                      ? 'নতুন অপরিচিত প্রাপক অ্যাকাউন্টে অস্বাভাবিক অংক পাঠানো হয়েছে, যা সাধারণ লেনদেনের গড়ের চেয়ে বেশি।'
                                      : 'কোনো অস্বাভাবিকতা মেলেনি। বিশ্বস্ত ডিভাইস এবং অবস্থান থেকে সম্পন্ন নিরাপদ স্বাভাবিক লেনদেন।'),
                          icon: Icons.psychology_outlined,
                        ),

                        const SizedBox(height: 12),

                        // Question 3: What should the app/user do next?
                        _buildAiQuestionCard(
                          question: '৩. পরবর্তী করণীয় কী? (What should the user/app do next?)',
                          answer: risk?.whatNext ??
                              (score >= 70
                                  ? '১. লেনদেনটি নিরাপত্তার স্বার্থে সাময়িক স্থগিত (HOLD) রাখা হয়েছে।\n২. আপনি নিজে এই লেনদেন না করে থাকলে এক্ষুনি অ্যাকাউন্ট ফ্রিজ করুন।\n৩. ১৬২৬৮ হেল্পলাইনে কল করুন।'
                                  : score >= 40
                                      ? '১. লেনদেন সম্পন্ন করতে ওটিপি কোড বা বায়োমেট্রিক কনফার্ম করুন।\n২. প্রাপকের পরিচয় নিশ্চিত হয়ে সেন্ড মানি করুন।'
                                      : 'লেনদেন সম্পূর্ণ নিরাপদ। কোনো পদক্ষেপ নেয়ার প্রয়োজন নেই।'),
                          icon: Icons.next_plan_outlined,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bottom Action Buttons
                  Row(
                    children: [
                      if (score >= 70) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('অ্যাকাউন্ট সাময়িক সুরক্ষা লক করা হয়েছে। আনলক করতে হেল্পলাইনে কল করুন।'),
                                  backgroundColor: UpayColors.riskHigh,
                                ),
                              );
                            },
                            icon: const Icon(Icons.lock, size: 18),
                            label: Text('অ্যাকাউন্ট ফ্রিজ করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: UpayColors.riskHigh,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: UpayColors.primaryBlue),
                          ),
                          child: Text(
                            'ঠিক আছে (Done)',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: UpayColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorTile(RiskFactor factor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UpayColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: UpayColors.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${(factor.impact * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: UpayColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              factor.message,
              style: GoogleFonts.hindSiliguri(
                fontSize: 13,
                color: UpayColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultFactors(int score) {
    if (score >= 70) {
      return Column(
        children: [
          _buildFactorTile(const RiskFactor(feature: 'device', impact: 0.38, message: 'অপরিচিত ডিভাইস ফিঙ্গারপ্রিন্ট শনাক্ত')),
          _buildFactorTile(const RiskFactor(feature: 'amount', impact: 0.32, message: 'ঐতিহাসিক গড়ের চেয়ে বহুগুণ বড় অংক')),
          _buildFactorTile(const RiskFactor(feature: 'velocity', impact: 0.24, message: 'স্বল্প সময়ে একাধিক অস্বাভাবিক লেনদেনের চেষ্টা')),
        ],
      );
    } else if (score >= 40) {
      return Column(
        children: [
          _buildFactorTile(const RiskFactor(feature: 'receiver', impact: 0.42, message: 'প্রথমবারের মতো নতুন প্রাপক নম্বরে টাকা প্রেরণ')),
          _buildFactorTile(const RiskFactor(feature: 'amount', impact: 0.30, message: 'সাপ্তাহিক স্বাভাবিক গড়ের চেয়ে বেশি পরিমাণ')),
        ],
      );
    }
    return Column(
      children: [
        _buildFactorTile(const RiskFactor(feature: 'device', impact: 0.05, message: 'স্বীকৃত প্রাইমারি বিশ্বস্ত ডিভাইস')),
        _buildFactorTile(const RiskFactor(feature: 'location', impact: 0.04, message: 'নিয়মিত ভৌগোলিক অবস্থান (ঢাকা)')),
      ],
    );
  }

  Widget _buildAiQuestionCard({
    required String question,
    required String answer,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: UpayColors.accentYellow, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: UpayColors.accentYellow,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: GoogleFonts.hindSiliguri(
              fontSize: 12.5,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
