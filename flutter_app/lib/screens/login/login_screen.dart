import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController =
      TextEditingController(text: AppConstants.demoUserPhone);
  final TextEditingController _pinController =
      TextEditingController(text: AppConstants.demoUserPin);

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _phoneController.text.trim(),
      _pinController.text.trim(),
    );
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: UpayColors.riskHigh,
        ),
      );
    }
  }

  void _handleDemoLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.loginDemo();
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 52,
      textStyle: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: UpayColors.primaryBlue,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UpayColors.borderSubtle, width: 1.5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: UpayColors.primaryBlue, width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: UpayColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Brand Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: UpayColors.accentYellow,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: UpayColors.accentYellow.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'upay',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: UpayColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'উপায়-এ স্বাগতম',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: UpayColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI চালিত নিরাপদ মোবাইল ফাইন্যান্সিয়াল সার্ভিস',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 13,
                        color: UpayColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Login Form Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'মোবাইল নম্বর',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: UpayColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(
                          hintText: '01XXXXXXXXX',
                          prefixIcon: Icon(Icons.phone_android, color: UpayColors.primaryBlue),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        '৪ ডিজিটের পিন (PIN)',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: UpayColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Pinput(
                          controller: _pinController,
                          length: 4,
                          obscureText: true,
                          obscuringCharacter: '●',
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          onCompleted: (_) => _handleLogin(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleLogin,
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'লগইন করুন',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Demo User Login Button
              OutlinedButton.icon(
                onPressed: auth.isLoading ? null : _handleDemoLogin,
                icon: const Icon(Icons.flash_on_rounded, color: UpayColors.primaryBlue),
                label: Text(
                  'Continue as Demo User (দ্রুত ডেমো প্রবেশ)',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: UpayColors.primaryBlue,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: UpayColors.primaryBlue, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Security notice
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: UpayColors.textLight),
                  const SizedBox(width: 6),
                  Text(
                    'সিমুলেশন মোড • কোনো আসল ডেটা সংরক্ষণ করা হয় না',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 11,
                      color: UpayColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

