import 'package:flutter/material.dart';
import 'stations_screen.dart';
import 'violation_types_screen.dart';
import 'reports_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ระบบรายงานการทุจริตเลือกตั้ง'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.how_to_vote, size: 80, color: Colors.indigo),
            const SizedBox(height: 10),
            const Text(
              'Election Violation\nMonitoring System',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 30),
            _buildMenuCard(
              context,
              icon: Icons.location_on,
              title: 'หน่วยเลือกตั้ง',
              subtitle: 'ดูข้อมูลหน่วยเลือกตั้ง',
              color: Colors.blue,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StationsScreen())),
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              context,
              icon: Icons.warning_amber,
              title: 'ประเภทการทุจริต',
              subtitle: 'ดูประเภทการทุจริตทั้งหมด',
              color: Colors.orange,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViolationTypesScreen())),
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              context,
              icon: Icons.report,
              title: 'รายงานเหตุการณ์',
              subtitle: 'ดูและสร้างรายงานการทุจริต',
              color: Colors.red,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
