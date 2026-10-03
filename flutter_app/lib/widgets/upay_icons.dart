import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Authentic Upay Circular Logo Avatar matching pic1.jpeg & pic2.jpeg
class UpayLogoAvatar extends StatelessWidget {
  final double size;
  const UpayLogoAvatar({super.key, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: size * 0.16,
                  height: size * 0.16,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFC800), // Upay Yellow
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: size * 0.08),
                Container(
                  width: size * 0.16,
                  height: size * 0.16,
                  decoration: const BoxDecoration(
                    color: Color(0xFF005CB9), // Upay Blue
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            SizedBox(height: size * 0.02),
            Container(
              width: size * 0.40,
              height: size * 0.12,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF005CB9),
                    width: 2.2,
                  ),
                ),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            SizedBox(height: size * 0.02),
            Text(
              'উপায়',
              style: GoogleFonts.hindSiliguri(
                fontSize: size * 0.22,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF005CB9),
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// BANGLA QR Center Floating Button Icon matching pic1.jpeg
class BanglaQrIcon extends StatelessWidget {
  final double size;
  const BanglaQrIcon({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'BANGLA',
          style: GoogleFonts.inter(
            fontSize: size * 0.20,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFE53935), // Red
            letterSpacing: 0.5,
            height: 1.0,
          ),
        ),
        SizedBox(height: size * 0.04),
        Container(
          width: size * 0.56,
          height: size * 0.56,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF43A047), width: 1.8), // Green border
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.qr_code_2_rounded,
                  color: Color(0xFF00897B),
                  size: 20,
                ),
                Positioned(
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    color: Colors.white,
                    child: Text(
                      'QR',
                      style: GoogleFonts.inter(
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFE53935),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Service Icon with rounded container and stylized imagery matching Upay clone images
class UpayServiceIcon extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;
  final double width;

  const UpayServiceIcon({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.width = 72,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 38,
              width: 38,
              child: Center(child: icon),
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
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
