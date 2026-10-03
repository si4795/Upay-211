import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _simulateNewDevice = false;
  bool _simulateNewLocation = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: UpayColors.bgLight,
      appBar: AppBar(
        title: Text(
          'প্রোফাইল ও সিমুলেশন সেটিংস',
          style: GoogleFonts.hindSiliguri(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: const BoxDecoration(
                      color: UpayColors.accentYellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: UpayColors.primaryBlue,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'উপায় ইউজার',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: UpayColors.textDark,
                    ),
                  ),
                  Text(
                    user?.phone ?? '01700000000',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: UpayColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'অ্যাকাউন্ট তথ্য',
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Divider(),
                    _infoRow('ইউজার আইডি', user?.id ?? 'USER001'),
                    _infoRow(
                      'অ্যাকাউন্টের বয়স',
                      '${user?.accountAgeDays ?? 320} দিন',
                    ),
                    _infoRow(
                      'নিবন্ধিত ইমেইল',
                      user?.email ?? 'user@upay.com.bd',
                    ),
                    _infoRow(
                      'বর্তমান ডিভাইস',
                      user?.currentDeviceId ?? 'DEVICE001',
                    ),
                    _infoRow(
                      'বর্তমান লোকেশন',
                      user?.currentLocation ?? 'Dhaka, Bangladesh',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Hackathon Simulation Testing Switch Card
            Card(
              color: UpayColors.primaryBlue.withOpacity(0.04),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: UpayColors.primaryBlue.withOpacity(0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.tune,
                          color: UpayColors.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'হ্যাকথন টেস্ট কন্ট্রোল (Judge Simulation Controls)',
                          style: GoogleFonts.hindSiliguri(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: UpayColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'সিমুলেট করুন কীভাবে নতুন ডিভাইস বা অস্বাভাবিক লোকেশন ঝুঁকি ইঞ্জিনকে ট্রিগার করে:',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 12,
                        color: UpayColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'নতুন অচেনা ডিভাইস সিমুলেশন (DEVICE009)',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        _simulateNewDevice
                            ? 'সক্রিয় (Unrecognized Device)'
                            : 'বন্ধ (Trusted Device)',
                        style: GoogleFonts.hindSiliguri(fontSize: 11),
                      ),
                      value: _simulateNewDevice,
                      onChanged: (val) {
                        setState(() => _simulateNewDevice = val);
                        auth.updateDeviceLocation(
                          deviceId: val ? 'DEVICE009' : 'DEVICE001',
                          location: _simulateNewLocation
                              ? 'Chattogram'
                              : 'Dhaka',
                        );
                      },
                    ),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'অস্বাভাবিক লোকেশন জাম্প সিমুলেশন (Chattogram)',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        _simulateNewLocation
                            ? 'চট্টগ্রাম (Unusual Geo-hop)'
                            : 'ঢাকা (Home Location)',
                        style: GoogleFonts.hindSiliguri(fontSize: 11),
                      ),
                      value: _simulateNewLocation,
                      onChanged: (val) {
                        setState(() => _simulateNewLocation = val);
                        auth.updateDeviceLocation(
                          deviceId: _simulateNewDevice
                              ? 'DEVICE009'
                              : 'DEVICE001',
                          location: val ? 'Chattogram' : 'Dhaka',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: UpayColors.riskHigh),
                label: Text(
                  'লগআউট করুন',
                  style: GoogleFonts.hindSiliguri(
                    color: UpayColors.riskHigh,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: UpayColors.riskHigh),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.hindSiliguri(
              color: UpayColors.textMuted,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
