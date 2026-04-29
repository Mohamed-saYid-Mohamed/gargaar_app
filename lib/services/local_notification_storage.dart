import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationStorage {
  static const _key = 'deleted_notification_ids';

  /// Returns the list of notification IDs deleted locally.
  static Future<List<String>> getDeletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  /// Marks a notification ID as locally deleted.
  static Future<void> markDeleted(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    if (!existing.contains(id)) {
      existing.add(id);
      await prefs.setStringList(_key, existing);
    }
  }

  /// Clears all locally-deleted IDs (use for "restore all" scenarios).
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
