import '../models/incident.dart';
import '../models/incident_type.dart';
import '../models/incident_location.dart';

abstract class IncidentRepository {
  /// Submit a new incident report
  Future<Incident> submitIncident({
    required IncidentType type,
    required String description,
    required String priority,
    required IncidentLocation location,
    required bool isAnonymous,
    String? audioPath,
    String? imagePath,
    String? videoPath,
  });

  /// Fetch available incident types
  Future<List<IncidentType>> fetchIncidentTypes();

  /// Fetch all incidents (records/history)
  Future<List<Incident>> fetchIncidents();

  /// Fetch a single incident by ID
  Future<Incident?> fetchIncidentById(String id);
}
