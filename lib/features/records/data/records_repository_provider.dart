import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'records_repository.dart';

final recordsRepositoryProvider = Provider<RecordsRepository>((ref) {
  return RecordsRepository();
});
