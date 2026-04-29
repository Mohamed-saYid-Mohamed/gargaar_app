import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/call_repository.dart';
import '../models/call_record.dart';

/// Repository provider
final callRepositoryProvider = Provider<CallRepository>((ref) {
  return CallRepository();
});

/// Call history provider
final callHistoryProvider =
    StateNotifierProvider<CallHistoryNotifier, AsyncValue<List<CallRecord>>>(
        (ref) {
  final repo = ref.read(callRepositoryProvider);
  return CallHistoryNotifier(repo);
});

class CallHistoryNotifier extends StateNotifier<AsyncValue<List<CallRecord>>> {
  final CallRepository _repository;

  CallHistoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    final calls = await _repository.fetchCallHistory();
    state = AsyncValue.data(calls);
  }

  Future<void> addCall(CallRecord record) async {
    await _repository.addCall(record);
    await _load();
  }
}
