import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/incident_record.dart';
import '../data/records_repository_provider.dart';

final recordsProvider = FutureProvider<List<IncidentRecord>>((ref) async {
  final repo = ref.watch(recordsRepositoryProvider);
  return repo.fetchUserRecords('current-user');
});

class RecordsNotifier extends StateNotifier<List<IncidentRecord>> {
  RecordsNotifier() : super([]);

  void addRecord(IncidentRecord record) {
    state = [record, ...state];
  }

  void clear() {
    state = [];
  }
}
