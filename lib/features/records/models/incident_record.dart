class IncidentRecord {
  final String id;
  final String type;
  final String description;
  final DateTime reportedAt;
  final String? imagePath;
  final double latitude;
  final double longitude;
  final String? audioPath;
  final String status;

  IncidentRecord({
    required this.id,
    required this.type,
    required this.description,
    required this.reportedAt,
    this.imagePath,
    required this.latitude,
    required this.longitude,
    this.audioPath,
    required this.status,
  });
}
