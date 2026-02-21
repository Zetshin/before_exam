class ViolationType {
  final int typeId;
  final String typeName;
  final String severity;

  ViolationType({
    required this.typeId,
    required this.typeName,
    required this.severity,
  });

  factory ViolationType.fromJson(Map<String, dynamic> json) {
    return ViolationType(
      typeId: json['type_id'],
      typeName: json['type_name'],
      severity: json['severity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type_id': typeId,
      'type_name': typeName,
      'severity': severity,
    };
  }
}
