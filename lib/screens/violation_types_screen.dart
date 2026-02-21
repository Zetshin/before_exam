import 'package:flutter/material.dart';
import '../models/violation_type.dart';
import '../services/api_service.dart';

class ViolationTypesScreen extends StatefulWidget {
  const ViolationTypesScreen({super.key});

  @override
  State<ViolationTypesScreen> createState() => _ViolationTypesScreenState();
}

class _ViolationTypesScreenState extends State<ViolationTypesScreen> {
  late Future<List<ViolationType>> _typesFuture;

  @override
  void initState() {
    super.initState();
    _typesFuture = ApiService.getViolationTypes();
  }

  void _refresh() {
    setState(() {
      _typesFuture = ApiService.getViolationTypes();
    });
  }

  Color _severityColor(String severity) {
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
        title: const Text('ประเภทการทุจริต'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: FutureBuilder<List<ViolationType>>(
        future: _typesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final types = snapshot.data!;
          if (types.isEmpty) {
            return const Center(child: Text('ไม่มีข้อมูลประเภทการทุจริต'));
          }
          return ListView.builder(
            itemCount: types.length,
            itemBuilder: (context, index) {
              final type = types[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _severityColor(type.severity).withOpacity(0.1),
                    child: Text('${type.typeId}', style: TextStyle(fontWeight: FontWeight.bold, color: _severityColor(type.severity))),
                  ),
                  title: Text(type.typeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _severityColor(type.severity).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type.severity,
                      style: TextStyle(color: _severityColor(type.severity), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
