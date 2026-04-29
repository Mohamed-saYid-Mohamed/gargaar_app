import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/call_provider.dart';
import '../models/call_record.dart';

class CallHistoryScreen extends ConsumerWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callsAsync = ref.watch(callHistoryProvider);

    return callsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (calls) {
        if (calls.isEmpty) {
          return const Center(
            child: Text(
              'No calls yet',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: calls.length,
          itemBuilder: (context, index) {
            final CallRecord call = calls[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      _serviceColor(call.service).withOpacity(0.15),
                  child: Icon(
                    _serviceIcon(call.service),
                    color: _serviceColor(call.service),
                  ),
                ),
                title: Text(
                  call.service.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                subtitle: Text(
                  _formatDateTime(call.time),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  call.status.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        call.status == 'completed' ? Colors.green : Colors.red,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ───────── HELPERS ─────────

  IconData _serviceIcon(String service) {
    switch (service.toLowerCase()) {
      case 'police':
        return Icons.local_police;
      case 'fire':
        return Icons.local_fire_department;
      case 'ambulance':
        return Icons.local_hospital;
      default:
        return Icons.phone;
    }
  }

  Color _serviceColor(String service) {
    switch (service.toLowerCase()) {
      case 'police':
        return Colors.blue;
      case 'fire':
        return Colors.red;
      case 'ambulance':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year} '
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}
