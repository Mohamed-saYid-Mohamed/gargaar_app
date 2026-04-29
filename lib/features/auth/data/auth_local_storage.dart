import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/user.dart';
import '../../../core/models/medical_info.dart';

class AuthLocalStorage {
  static const _sessionKey = 'auth_session';
  static const _usersKey = 'registered_users';

  /// ───────── REGISTER USER ─────────

  static Future<void> saveRegisteredUser({
    required String id,
    required String name,
    required String phone,
    required String? email,
    required String nationalId,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final existing = prefs.getString(_usersKey);
    List users = existing != null ? jsonDecode(existing) : [];

    users.add({
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'nationalId': nationalId,
      'password': password,
    });

    await prefs.setString(_usersKey, jsonEncode(users));
  }

  /// ───────── LOGIN USER ─────────

  static Future<User?> findUser(String identifier, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(_usersKey);
    if (data == null) return null;

    final users = jsonDecode(data) as List;

    for (final u in users) {
      if ((u['email'] == identifier || u['phone'] == identifier) &&
          u['password'] == password) {
        return User(
          id: u['id'],
          name: u['name'],
          phone: u['phone'],
          email: u['email'],
          nationalId: u['nationalId'],
          isEmailVerified: false,
          isPhoneVerified: true,
          profileImagePath: null,
          medicalInfo: MedicalInfo.empty(),
          savedLocations: const [],
        );
      }
    }

    return null;
  }

  /// ───────── SAVE SESSION ─────────

  static Future<void> saveSession(User user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
        _sessionKey,
        jsonEncode({
          'id': user.id,
          'name': user.name,
          'phone': user.phone,
          'email': user.email,
          'nationalId': user.nationalId,
        }));
  }

  static Future<User?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_sessionKey);
    if (data == null) return null;

    final u = jsonDecode(data);

    return User(
      id: u['id'],
      name: u['name'],
      phone: u['phone'],
      email: u['email'],
      nationalId: u['nationalId'],
      isEmailVerified: false,
      isPhoneVerified: true,
      profileImagePath: null,
      medicalInfo: MedicalInfo.empty(),
      savedLocations: const [],
    );
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
