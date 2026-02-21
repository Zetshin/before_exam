import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api.dart';
import '../models/station.dart';
import '../models/violation_type.dart';
import '../models/incident_report.dart';

class ApiService {
  static const String _baseUrl = ApiConstants.baseUrl;

  // ==================== Stations ====================

  static Future<List<Station>> getStations() async {
    final response = await http.get(Uri.parse('$_baseUrl/stations'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Station.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load stations');
    }
  }

  static Future<Station> getStation(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/stations/$id'));
    if (response.statusCode == 200) {
      return Station.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load station');
    }
  }

  // ==================== Violation Types ====================

  static Future<List<ViolationType>> getViolationTypes() async {
    final response = await http.get(Uri.parse('$_baseUrl/violation-types'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ViolationType.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load violation types');
    }
  }

  // ==================== Reports ====================

  static Future<List<IncidentReport>> getReports() async {
    final response = await http.get(Uri.parse('$_baseUrl/reports'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => IncidentReport.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reports');
    }
  }

  static Future<IncidentReport> getReport(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/reports/$id'));
    if (response.statusCode == 200) {
      return IncidentReport.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load report');
    }
  }

  static Future<IncidentReport> createReport(IncidentReport report) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/reports'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(report.toJson()),
    );
    if (response.statusCode == 201) {
      return IncidentReport.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create report');
    }
  }

  static Future<IncidentReport> updateReport(int id, IncidentReport report) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/reports/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(report.toJson()),
    );
    if (response.statusCode == 200) {
      return IncidentReport.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update report: ${response.body}');
    }
  }

  static Future<void> deleteReport(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/reports/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete report');
    }
  }
}
