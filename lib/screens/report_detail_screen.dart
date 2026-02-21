import 'package:flutter/material.dart';
import '../models/incident_report.dart';
import '../services/api_service.dart';
import 'report_form_screen.dart';

class ReportDetailScreen extends StatefulWidget {
  final int reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late Future<IncidentReport> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = ApiService.getReport(widget.reportId);
  }

  void _refresh() {
    setState(() {
      _reportFuture = ApiService.getReport(widget.reportId);
    });
  }

  Color _severityColor(String? severity) {
    switch (severity) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _deleteReport() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบรายงานนี้หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteReport(widget.reportId);
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดรายงาน'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteReport),
        ],
      ),
      body: FutureBuilder<IncidentReport>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final report = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header card
                Card(
                  color: _severityColor(report.severity).withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.report, size: 48, color: _severityColor(report.severity)),
                        const SizedBox(height: 8),
                        Text(
                          report.typeName ?? 'ไม่ทราบประเภท',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _severityColor(report.severity)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _severityColor(report.severity).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'ระดับ: ${report.severity ?? '-'}',
                            style: TextStyle(color: _severityColor(report.severity), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Detail info
                _buildInfoRow(Icons.numbers, 'Report ID', '${report.reportId}'),
                _buildInfoRow(Icons.location_on, 'หน่วยเลือกตั้ง', report.stationName ?? '-'),
                _buildInfoRow(Icons.map, 'เขต/จังหวัด', '${report.zone ?? '-'} • ${report.province ?? '-'}'),
                _buildInfoRow(Icons.person, 'ผู้แจ้ง', report.reporterName),
                _buildInfoRow(Icons.description, 'รายละเอียด', report.description ?? '-'),
                _buildInfoRow(Icons.access_time, 'เวลาแจ้ง', report.timestamp),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // AI Section
                const Text('ผลวิเคราะห์ AI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.smart_toy, size: 40, color: Colors.blue),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.analytics, 'AI Result', report.aiResult ?? 'ยังไม่มีผล'),
                        _buildInfoRow(
                          Icons.speed,
                          'AI Confidence',
                          report.aiConfidence != null ? '${(report.aiConfidence! * 100).toStringAsFixed(1)}%' : 'N/A',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Edit button
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ReportFormScreen(report: report)),
                    );
                    if (result == true) _refresh();
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('แก้ไขรายงาน'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
