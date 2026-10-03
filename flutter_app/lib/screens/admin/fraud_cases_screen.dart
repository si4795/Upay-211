import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/admin_intelligence.dart';
import '../../services/admin_service.dart';

class FraudCasesScreen extends StatefulWidget {
  const FraudCasesScreen({super.key});

  @override
  State<FraudCasesScreen> createState() => _FraudCasesScreenState();
}

class _FraudCasesScreenState extends State<FraudCasesScreen> {
  final AdminService _adminService = AdminService();
  List<AdminFraudCase> _cases = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  void _loadCases() async {
    setState(() => _isLoading = true);
    final data = await _adminService.fetchFraudCases();
    if (mounted) {
      setState(() {
        _cases = data;
        _isLoading = false;
      });
    }
  }

  List<AdminFraudCase> get _filteredCases {
    if (_selectedFilter == 'All') return _cases;
    return _cases.where((c) => c.status.toLowerCase() == _selectedFilter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'Fraud Case Management',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: UpayColors.accentYellow))
          : Column(
              children: [
                // Filter chips
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: const Color(0xFF1E293B),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Open', 'Under Review', 'Confirmed Suspicious', 'Resolved', 'False Positive'].map((status) {
                        final isSelected = _selectedFilter == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(status, style: GoogleFonts.inter(fontSize: 12, color: isSelected ? Colors.black : Colors.white70)),
                            selected: isSelected,
                            selectedColor: UpayColors.accentYellow,
                            backgroundColor: Colors.white10,
                            onSelected: (_) => setState(() => _selectedFilter = status),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredCases.length,
                    itemBuilder: (context, index) {
                      final c = _filteredCases[index];
                      return _buildCaseCard(c);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCaseCard(AdminFraudCase c) {
    final statusColor = switch (c.status.toLowerCase()) {
      'confirmed suspicious' => UpayColors.riskHigh,
      'under review' => UpayColors.riskMedium,
      'resolved' => UpayColors.riskLow,
      'false positive' => Colors.blueAccent,
      _ => Colors.orangeAccent,
    };

    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  c.caseId,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    c.status,
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'User: ${c.userId} • Txn: ${c.transactionId} • ${Formatters.currency(c.amount)}',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              c.reason,
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFFFB800)),
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Assigned: ${c.assignedAnalyst}',
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white54),
                ),
                TextButton(
                  onPressed: () => _updateCaseDialog(c),
                  child: Text('Update Case →', style: GoogleFonts.inter(fontSize: 12, color: UpayColors.accentYellow)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateCaseDialog(AdminFraudCase c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Update ${c.caseId}', style: GoogleFonts.inter(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Change case status:', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 10),
            ...['Open', 'Under Review', 'Confirmed Suspicious', 'Resolved', 'False Positive'].map((st) {
              return ListTile(
                title: Text(st, style: GoogleFonts.inter(color: Colors.white)),
                onTap: () {
                  setState(() => c.status = st);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

