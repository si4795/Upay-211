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

  String _selectedRole = 'Fraud Analyst';
  bool _obscurePin = true;
  bool _isAuthenticating = false;
  String? _idError;
  String? _pinError;

  @override
  void dispose() {
    _idController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _fillPreset(String id, String pin, String role) {
    setState(() {
      _idController.text = id;
      _pinController.text = pin;
      _selectedRole = role;
      _idError = null;
      _pinError = null;
    });
  }

  Future<void> _handleLogin() async {
    final id = _idController.text.trim();
    final pin = _pinController.text.trim();

    bool hasError = false;
    setState(() {
      _idError = id.isEmpty ? 'Analyst Identifier is required' : null;
      _pinError = pin.isEmpty ? 'Security Passcode is required' : null;
      hasError = id.isEmpty || pin.isEmpty;
    });

    if (hasError) return;

    setState(() => _isAuthenticating = true);

    // Simulate enterprise authentication handshake
    await Future.delayed(const Duration(milliseconds: 550));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AdminDashboardScreen(),
        transitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UpayColors.adminBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Security Header
            _buildTopBar(context),

            // Scrollable Content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Center Security Brand
                        _buildBrandHeader(),
                        const SizedBox(height: 28),

                        // Enterprise Auth Card
                        _buildAuthCard(),
                        const SizedBox(height: 24),

                        // Compliance Footer
                        _buildComplianceFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: UpayColors.adminSurface,
        border: Border(bottom: BorderSide(color: UpayColors.adminBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
            icon: const Icon(Icons.arrow_back_rounded, size: 18, color: UpayColors.adminTextSecondary),
            label: Text(
              'Consumer App',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: UpayColors.adminTextSecondary,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: UpayColors.adminBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: UpayColors.adminBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: UpayColors.riskLow,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'SOC GATEWAY • ACTIVE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: UpayColors.adminTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: UpayColors.accentYellow,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: UpayColors.accentYellow.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 6),
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
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Trust & Risk Intelligence',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: UpayColors.adminTextPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Security Operations Center (SOC) Console',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: UpayColors.adminTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: UpayColors.adminCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UpayColors.adminBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role Selection Tabs
          Text(
            'OPERATOR ROLE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: UpayColors.adminTextMuted,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          _buildRoleSegmentedSelector(),
          const SizedBox(height: 20),

          // ID Field
          Text(
            'ANALYST IDENTIFIER',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: UpayColors.adminTextMuted,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _idController,
            style: GoogleFonts.inter(
              color: UpayColors.adminTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. ADMIN001',
              hintStyle: GoogleFonts.inter(color: UpayColors.adminTextMuted, fontSize: 13),
              prefixIcon: const Icon(Icons.badge_outlined, color: UpayColors.accentYellow, size: 20),
              fillColor: UpayColors.adminSurface,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              errorText: _idError,
              errorStyle: GoogleFonts.inter(fontSize: 11, color: UpayColors.riskHigh),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: UpayColors.adminBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: UpayColors.accentYellow, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: UpayColors.riskHigh),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: UpayColors.riskHigh, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // PIN Field
          Text(
            'SECURITY PASSCODE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: UpayColors.adminTextMuted,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _pinController,
            obscureText: _obscurePin,
            style: GoogleFonts.inter(
              color: UpayColors.adminTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Enter 4-digit passcode',
              hintStyle: GoogleFonts.inter(color: UpayColors.adminTextMuted, fontSize: 13),
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: UpayColors.accentYellow, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePin ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: UpayColors.adminTextMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePin = !_obscurePin),
              ),
              fillColor: UpayColors.adminSurface,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              errorText: _pinError,
              errorStyle: GoogleFonts.inter(fontSize: 11, color: UpayColors.riskHigh),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: UpayColors.adminBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: UpayColors.accentYellow, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: UpayColors.riskHigh),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: UpayColors.riskHigh, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Quick-Fill Preset Chips
          Text(
            'DEMO ACCESS PRESETS',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: UpayColors.adminTextMuted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildPresetChip(
                  label: 'Analyst (ADMIN001)',
                  icon: Icons.shield_outlined,
                  onTap: () => _fillPreset('ADMIN001', '1234', 'Fraud Analyst'),
                  isSelected: _idController.text == 'ADMIN001' && _selectedRole == 'Fraud Analyst',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPresetChip(
                  label: 'Admin (ADMIN002)',
                  icon: Icons.admin_panel_settings_outlined,
                  onTap: () => _fillPreset('ADMIN002', '1234', 'Risk Admin'),
                  isSelected: _idController.text == 'ADMIN002' && _selectedRole == 'Risk Admin',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isAuthenticating ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: UpayColors.accentYellow,
                foregroundColor: UpayColors.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isAuthenticating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(UpayColors.primaryBlue),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Verifying Credentials...',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: UpayColors.primaryBlue,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_user_rounded, size: 18, color: UpayColors.primaryBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Authenticate & Enter Console',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: UpayColors.primaryBlue,
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

  Widget _buildRoleSegmentedSelector() {
    final roles = [
      {'title': 'Fraud Analyst', 'icon': Icons.shield_outlined},
      {'title': 'Risk Admin', 'icon': Icons.admin_panel_settings_outlined},
      {'title': 'Compliance', 'icon': Icons.fact_check_outlined},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: UpayColors.adminSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: UpayColors.adminBorder),
      ),
      child: Row(
        children: roles.map((r) {
          final title = r['title'] as String;
          final icon = r['icon'] as IconData;
          final isSelected = _selectedRole == title;

          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedRole = title),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? UpayColors.adminCardHover : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? UpayColors.accentYellow.withOpacity(0.5) : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 15,
                      color: isSelected ? UpayColors.accentYellow : UpayColors.adminTextMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? UpayColors.adminTextPrimary : UpayColors.adminTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? UpayColors.accentYellow.withOpacity(0.12) : UpayColors.adminSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? UpayColors.accentYellow.withOpacity(0.6) : UpayColors.adminBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? UpayColors.accentYellow : UpayColors.adminTextMuted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? UpayColors.accentYellow : UpayColors.adminTextSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_clock_outlined, size: 14, color: UpayColors.adminTextMuted),
            const SizedBox(width: 6),
            Text(
              'Restricted Access • upay Financial Services Ltd. (SOC)',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: UpayColors.adminTextMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Monitored under Bangladesh Cyber Security & Banking Protocols',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: UpayColors.adminTextMuted.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
