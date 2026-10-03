import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../send_money/send_money_screen.dart';

class BanglaQrScreen extends StatelessWidget {
  const BanglaQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'বাংলা কিউআর (BANGLA QR)',
          style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_off_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.image_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Center(
            child: Text(
              'যেকোনো বাংলা কিউআর বা মার্চেন্ট কোড স্ক্যান করুন',
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
          const Spacer(),

          // QR Scanner Viewfinder Simulation
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: UpayColors.accentYellow, width: 3),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220,
                    height: 2,
                    color: Colors.redAccent.withOpacity(0.8),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner_rounded, size: 70, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(height: 10),
                      Text(
                        'BANGLA QR',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.5),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Simulated Quick Scan Button for Demo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SendMoneyScreen(
                        initialReceiverName: 'Meena Bazar (Merchant)',
                        initialReceiverPhone: '01819283746',
                        initialAmount: 650.0,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code, color: UpayColors.primaryDark),
                label: Text(
                  'নমুনা কিউআর স্ক্যান ডেমো (Simulate Scan)',
                  style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold, color: UpayColors.primaryDark),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UpayColors.accentYellow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

