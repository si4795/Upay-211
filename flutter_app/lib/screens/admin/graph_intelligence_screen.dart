import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../services/admin_service.dart';

class GraphIntelligenceScreen extends StatefulWidget {
  const GraphIntelligenceScreen({super.key});

  @override
  State<GraphIntelligenceScreen> createState() => _GraphIntelligenceScreenState();
}

class _GraphIntelligenceScreenState extends State<GraphIntelligenceScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _graphData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGraph();
  }

  void _loadGraph() async {
    setState(() => _isLoading = true);
    final data = await _adminService.fetchGraphIntelligence();
    if (mounted) {
      setState(() {
        _graphData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: UpayColors.accentYellow));
    }

    final highConn = _graphData?['high_connectivity_accounts'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: UpayColors.riskHigh.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: UpayColors.riskHigh.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: UpayColors.riskHigh, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Potential Money-Mule Pattern Detected',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cluster: A → [B, C, D, E] → X (Requires Investigation)',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Visual Node Topology Flow
          Text(
            'NETWORK TOPOLOGY VISUALIZATION (NetworkX)',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.1),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2541),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                // Source
                _buildGraphNode('USER_MULE_A (Smurfing Source)', Colors.orangeAccent, 'Disperser (Out-Degree: 4)'),
                const Icon(Icons.arrow_downward_rounded, color: Colors.white38),
                const SizedBox(height: 4),

                // Intermediate Mules Row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildSubNode('Mule B', '৳25k'),
                    _buildSubNode('Mule C', '৳25k'),
                    _buildSubNode('Mule D', '৳25k'),
                    _buildSubNode('Mule E', '৳25k'),
                  ],
                ),
                const SizedBox(height: 4),
                const Icon(Icons.arrow_downward_rounded, color: Colors.white38),

                // Target
                _buildGraphNode('USER_SYNDICATE_X (Aggregator Node)', UpayColors.riskHigh, 'Fan-In Destination (In-Degree: 4)'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // High Connectivity Table
          Text(
            'HIGH-CONNECTIVITY & CENTRALITY NODES',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.1),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C2541),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: highConn.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
              itemBuilder: (context, idx) {
                final item = highConn[idx];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.white10,
                    child: Icon(Icons.account_tree_rounded, color: UpayColors.accentYellow, size: 20),
                  ),
                  title: Text(item['node'].toString(), style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Degree: ${item['degree']}',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGraphNode(String title, Color color, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: color)),
        ],
      ),
    );
  }

  Widget _buildSubNode(String name, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(name, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(amount, style: GoogleFonts.inter(fontSize: 10, color: UpayColors.accentYellow)),
        ],
      ),
    );
  }
}
