import 'incident_type.dart';

enum IncidentStatus {
  Submitted,
  Responding,
  Resolved,
  Cancelled,
}

class Incident {
  final String id;
  final IncidentType type;
  final IncidentStatus status;
  final String description;
  final DateTime reportedAt;
  final double latitude;
  final double longitude;

  // Optional media
  final String? imageUrl;
  final String? videoUrl;
  final String? audioUrl;

  const Incident({
    required this.id,
    required this.type,
    required this.status,
    required this.description,
    required this.reportedAt,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.videoUrl,
    this.audioUrl,
  });
}
