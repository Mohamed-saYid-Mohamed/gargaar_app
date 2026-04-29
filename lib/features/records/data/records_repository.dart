import '../models/incident_record.dart';

class RecordsRepository {
  //  SINGLE SOURCE OF TRUTH (in-memory)
  final List<IncidentRecord> _records = [];

  // READ
  Future<List<IncidentRecord>> fetchUserRecords(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_records);
  }

  // WRITE (called from Report submit)
  Future<void> addRecord(IncidentRecord record) async {
    _records.insert(0, record); // newest first
  }
}
