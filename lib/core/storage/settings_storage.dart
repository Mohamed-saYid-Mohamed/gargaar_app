import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  static const _themeKey = 'theme';
  static const _languageKey = 'language';
  static const _notificationsKey = 'notifications';

  /* ───────── THEME ───────── */

  static Future<void> saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  static Future<String?> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  /* ───────── LANGUAGE ───────── */

  static Future<void> saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, lang);
  }

  static Future<String?> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  /* ───────── NOTIFICATIONS ───────── */

  static Future<void> saveNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  static Future<bool> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }
}
