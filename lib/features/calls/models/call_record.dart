class CallRecord {
  final String id;
  final String service; // Police, Fire, Ambulance
  final String number; // 112, 999, etc.
  final DateTime time;
  final String status; // completed, missed

  CallRecord({
    required this.id,
    required this.service,
    required this.number,
    required this.time,
    required this.status,
  });
}
