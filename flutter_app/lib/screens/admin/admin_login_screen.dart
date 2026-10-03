import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../home/home_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _idController =
      TextEditingController(text: AppConstants.demoAdminId);
  final TextEditingController _pinController =
      TextEditingController(text: AppConstants.demoAdminPin);

  String _selectedRole = 'Fraud Analyst'; // Roles: Customer, Fraud Analyst, Admin
  bool _obscurePin = true;

  @override
  void dispose() {
    _idController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final id = _idController.text.trim();
    final pin = _pinController.text.trim();

    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an Analyst / Admin ID'),
          backgroundColor: UpayColors.riskHigh,
        ),
      );
      return;
    }

    if (pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Passcode / PIN'),
          backgroundColor: UpayColors.riskHigh,
        ),
      );
      return;
    }

    if (_selectedRole == 'Customer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: UpayColors.accentYellow,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: UpayColors.accentYellow.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'upay',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: UpayColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Trust & Risk Intelligence',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Security Operations & Fraud Investigation Portal',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
                  ),
                  const SizedBox(height: 24),

                  // Demo Credentials Info Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: UpayColors.accentYellow.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: UpayColors.accentYellow.withOpacity(0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.vpn_key_outlined, color: UpayColors.accentYellow, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Demo Credentials (Pre-filled):',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: UpayColors.accentYellow,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '• Analyst / Admin ID:  ADMIN001\n• Security Passcode / PIN:  1234\n• Role:  Fraud Analyst / Admin',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Credentials Form Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2541),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ANALYST ID / USERNAME',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _idController,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'e.g. ADMIN001',
                            hintStyle: GoogleFonts.inter(color: Colors.white38),
                            prefixIcon: const Icon(Icons.badge_outlined, color: UpayColors.accentYellow),
                            fillColor: Colors.black26,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          'SECURITY PASSCODE / PIN',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _pinController,
                          obscureText: _obscurePin,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'e.g. 1234',
                            hintStyle: GoogleFonts.inter(color: Colors.white38),
                            prefixIcon: const Icon(Icons.lock_outline, color: UpayColors.accentYellow),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePin ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white54,
                              ),
                              onPressed: () => setState(() => _obscurePin = !_obscurePin),
                            ),
                            fillColor: Colors.black26,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'SELECT ACCESS ROLE:',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ...['Fraud Analyst', 'Admin', 'Customer'].map((role) {
                          final isSelected = _selectedRole == role;
                          final icon = role == 'Customer'
                              ? Icons.person_outline
                              : (role == 'Fraud Analyst'
                                  ? Icons.shield_outlined
                                  : Icons.admin_panel_settings_outlined);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? UpayColors.accentYellow.withOpacity(0.15) : Colors.white10,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? UpayColors.accentYellow : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              leading: Icon(icon, color: isSelected ? UpayColors.accentYellow : Colors.white60, size: 20),
                              title: Text(
                                role,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: UpayColors.accentYellow, size: 18)
                                  : null,
                              onTap: () => setState(() => _selectedRole = role),
                            ),
                          );
                        }),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: UpayColors.accentYellow,
                              foregroundColor: UpayColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Login as $_selectedRole',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
