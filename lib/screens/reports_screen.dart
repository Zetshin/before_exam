import 'package:flutter/material.dart';
import '../models/incident_report.dart';
import '../services/api_service.dart';
import 'report_form_screen.dart';
import 'report_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<List<IncidentReport>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = ApiService.getReports();
  }

  void _refresh() {
    setState(() {
      _reportsFuture = ApiService.getReports();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายงานเหตุการณ์'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportFormScreen()),
          );
          if (result == true) _refresh();
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<IncidentReport>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final reports = snapshot.data!;
          if (reports.isEmpty) {
            return const Center(child: Text('ไม่มีรายงาน'));
          }
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _severityColor(report.severity).withOpacity(0.1),
                    child: Icon(Icons.report, color: _severityColor(report.severity)),
                  ),
                  title: Text(report.typeName ?? 'ไม่ทราบประเภท', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('สถานี: ${report.stationName ?? '-'}'),
                      Text('ผู้แจ้ง: ${report.reporterName}'),
                      Text('เวลา: ${report.timestamp}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  isThreeLine: true,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ReportDetailScreen(reportId: report.reportId!)),
                    );
                    if (result == true) _refresh();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
