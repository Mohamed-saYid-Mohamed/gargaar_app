class IncidentEvidence {
  final String filePath;
  final DateTime capturedAt;

  IncidentEvidence({
    required this.filePath,
    required this.capturedAt,
  });

  factory IncidentEvidence.fromJson(Map<String, dynamic> json) {
    return IncidentEvidence(
      filePath: json['filePath'],
      capturedAt: DateTime.parse(json['capturedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'capturedAt': capturedAt.toIso8601String(),
    };
  }
}
