import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';

class NotificationsNotifier extends AsyncNotifier<List<NotificationModel>> {
  @override
  FutureOr<List<NotificationModel>> build() async {
    // 🔔 Simulation: Load notifications (Future Firestore integration point)
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      NotificationModel(
        id: '1',
        title: 'Weather Warning',
        message: 'Severe thunderstorms expected in your area. Please stay indoors.',
        type: NotificationType.warning,
        target: 'Mogadishu',
        createdAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'Emergency Alert: Fire',
        message: 'Large building fire reported in District 4. Emergency services are on site.',
        type: NotificationType.emergency,
        target: 'District 4',
        createdAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5))),
        isRead: false,
      ),
      NotificationModel(
        id: '3',
        title: 'Service Update',
        message: 'The Gargaar app will undergo maintenance on Sunday at 02:00 AM.',
        type: NotificationType.info,
        createdAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        isRead: true,
      ),
    ];
  }

  Future<void> markAsRead(String id) async {
    final currentState = state.value ?? [];
    state = AsyncData(
      currentState.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
    );
  }

  Future<void> markAllAsRead() async {
    final currentState = state.value ?? [];
    state = AsyncData(
      currentState.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }

  int get unreadCount => state.value?.where((n) => !n.isRead).length ?? 0;
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
  NotificationsNotifier.new,
);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).value ?? [];
  return notifications.where((n) => !n.isRead).length;
});
