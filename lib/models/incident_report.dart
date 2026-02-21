class IncidentReport {
  final int? reportId;
  final int stationId;
  final int typeId;
  final String reporterName;
  final String? description;
  final String? evidencePhoto;
  final String timestamp;
  final String? aiResult;
  final double? aiConfidence;

  // JOIN fields
  final String? stationName;
  final String? zone;
  final String? province;
  final String? typeName;
  final String? severity;

  IncidentReport({
    this.reportId,
    required this.stationId,
    required this.typeId,
    required this.reporterName,
    this.description,
    this.evidencePhoto,
    required this.timestamp,
    this.aiResult,
    this.aiConfidence,
    this.stationName,
    this.zone,
    this.province,
    this.typeName,
    this.severity,
  });

  factory IncidentReport.fromJson(Map<String, dynamic> json) {
    return IncidentReport(
      reportId: json['report_id'],
      stationId: json['station_id'],
      typeId: json['type_id'],
      reporterName: json['reporter_name'],
      description: json['description'],
      evidencePhoto: json['evidence_photo'],
      timestamp: json['timestamp'],
      aiResult: json['ai_result'],
      aiConfidence: json['ai_confidence'] != null ? (json['ai_confidence'] as num).toDouble() : null,
      stationName: json['station_name'],
      zone: json['zone'],
      province: json['province'],
      typeName: json['type_name'],
      severity: json['severity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'station_id': stationId,
      'type_id': typeId,
      'reporter_name': reporterName,
      'description': description,
      'evidence_photo': evidencePhoto,
      'timestamp': timestamp,
      'ai_result': aiResult,
      'ai_confidence': aiConfidence ?? 0.0,
    };
  }
}
