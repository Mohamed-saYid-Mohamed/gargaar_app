import '../models/call_record.dart';

class CallRepository {
  //  Single source of truth (in-memory for now)
  final List<CallRecord> _calls = [];

  // READ
  Future<List<CallRecord>> fetchCallHistory() async {
    return List.unmodifiable(_calls);
  }

  // WRITE (called when user makes a call)
  Future<void> addCall(CallRecord record) async {
    _calls.insert(0, record); // newest first
  }
}
