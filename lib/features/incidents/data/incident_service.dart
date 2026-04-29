import '../models/incident.dart';
import '../models/incident_type.dart';
import '../models/incident_location.dart';

class IncidentService {
  /// Mock incident list (used by Records & testing)
  List<Incident> getMockIncidents() {
    return [
      Incident(
        id: '1',
        type: IncidentType.fire,
        status: IncidentStatus.Submitted,
        description: 'Fire reported near market',
        reportedAt: DateTime.now().subtract(const Duration(minutes: 20)),
        latitude: 2.0469,
        longitude: 45.3182,
        audioUrl: null,
      ),
      Incident(
        id: '2',
        type: IncidentType.accident,
        status: IncidentStatus.Resolved,
        description: 'Car accident on main road',
        reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
        latitude: 2.0500,
        longitude: 45.3200,
        imageUrl: null,
      ),
    ];
  }

  /// Submit incident (used by Report flow)
  Future<Incident> submitIncident({
    required IncidentType type,
    required String description,
    required String priority,
    required IncidentLocation location,
    required bool isAnonymous,
    String? audioPath,
    String? imagePath,
    String? videoPath,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    return Incident(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      status: IncidentStatus.Submitted,
      description: description,
      reportedAt: DateTime.now(),
      latitude: location.latitude,
      longitude: location.longitude,
      audioUrl: audioPath,
      imageUrl: imagePath,
      videoUrl: videoPath,
    );
  }
}
