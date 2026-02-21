import 'package:flutter/material.dart';
import '../models/station.dart';
import '../services/api_service.dart';

class StationsScreen extends StatefulWidget {
  const StationsScreen({super.key});

  @override
  State<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  late Future<List<Station>> _stationsFuture;

  @override
  void initState() {
    super.initState();
    _stationsFuture = ApiService.getStations();
  }

  void _refresh() {
    setState(() {
      _stationsFuture = ApiService.getStations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('หน่วยเลือกตั้ง'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: FutureBuilder<List<Station>>(
        future: _stationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final stations = snapshot.data!;
          if (stations.isEmpty) {
            return const Center(child: Text('ไม่มีข้อมูลหน่วยเลือกตั้ง'));
          }
          return ListView.builder(
            itemCount: stations.length,
            itemBuilder: (context, index) {
              final station = stations[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Text('${station.stationId}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ),
                  title: Text(station.stationName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${station.zone} • ${station.province}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
