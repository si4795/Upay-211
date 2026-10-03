import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../models/admin_intelligence.dart';
import '../../services/admin_service.dart';

class ScamNlpScreen extends StatefulWidget {
  const ScamNlpScreen({super.key});

  @override
  State<ScamNlpScreen> createState() => _ScamNlpScreenState();
}

class _ScamNlpScreenState extends State<ScamNlpScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _textController = TextEditingController();

  BanglaScamResult? _result;
  bool _isAnalyzing = false;

  final List<String> _presetScams = [
    'upay থেকে বলছি আপনার PIN দিন',
    'আপনার account বন্ধ হয়ে যাবে, OTP দিন',
    'আপনি পুরস্কার পেয়েছেন, verification fee পাঠান',
    'জরুরি নোটিশ: আপনার PIN confirm করুন',
    'ভাইয়া কেমন আছেন? আজকের মিটিং কয়টায়?',
  ];

  void _analyzeText(String text) async {
    if (text.trim().isEmpty) return;
    setState(() => _isAnalyzing = true);
    final res = await _adminService.analyzeScamText(text.trim());
    if (mounted) {
      setState(() {
        _result = res;
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BANGLA SCAM-TEXT INTELLIGENCE (NLP PROTOTYPE)',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.1),
          ),
          const SizedBox(height: 6),
          Text(
            'Detect phishing, credential solicitation, and impersonation attempts targeting MFS customers.',
            style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.white60),
          ),
          const SizedBox(height: 16),

          // Input Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2541),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _textController,
                  maxLines: 3,
                  style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'এখানে বাংলা এসএমএস বা টেক্সট লিখুন...',
                    hintStyle: GoogleFonts.hindSiliguri(color: Colors.white38),
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : () => _analyzeText(_textController.text),
                    icon: _isAnalyzing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.manage_search_rounded),
                    label: Text('Analyze Text with AI', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UpayColors.accentYellow,
                      foregroundColor: UpayColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Quick Presets
          Text(
            'DEMO PRESETS (Click to Test):',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 8),

          ..._presetScams.map((preset) {
            return Card(
              color: const Color(0xFF1C2541),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                dense: true,
                title: Text(preset, style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 13)),
                trailing: const Icon(Icons.arrow_forward, color: UpayColors.accentYellow, size: 16),
                onTap: () {
                  _textController.text = preset;
                  _analyzeText(preset);
                },
              ),
            );
          }),

          const SizedBox(height: 20),

          // Result display
          if (_result != null) _buildResultCard(_result!),
        ],
      ),
    );
  }

  Widget _buildResultCard(BanglaScamResult res) {
    final isScam = res.isScam;
    final color = isScam ? UpayColors.riskHigh : UpayColors.riskLow;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(isScam ? Icons.warning_rounded : Icons.verified_rounded, color: color, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    isScam ? 'POTENTIAL SCAM DETECTED' : 'NORMAL MESSAGE',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: color),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${(res.confidence * 100).toInt()}% Confidence',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Classification Category: ${res.category}',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          if (res.detectedKeywords.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: res.detectedKeywords.map((kw) {
                return Chip(
                  label: Text(kw, style: GoogleFonts.inter(fontSize: 11, color: Colors.white)),
                  backgroundColor: Colors.white12,
                  padding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

