import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/notifications/models/notification_model.dart';
import 'local_notification_storage.dart';

class NotificationService {
  /// Returns a stream of notifications, filtered by locally-deleted IDs.
  /// Firestore data is NEVER modified — deletions are device-only.
  Stream<List<NotificationModel>> getNotifications() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final deletedIds = await LocalNotificationStorage.getDeletedIds();

      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .where((n) => !deletedIds.contains(n.id))
          .toList();
    });
  }
}
