import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user.dart';
import '../../../core/models/medical_info.dart';

import '../data/auth_repository.dart';
import '../data/auth_local_storage.dart';
import 'auth_state.dart';
import '../../profile/state/profile_provider.dart';
import '../../../services/push_notification_service.dart';


final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref, AuthRepository());
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final AuthRepository _repository;

  AuthNotifier(this.ref, this._repository) : super(const AuthState.loading()) {
    restoreSession();
  }

  /* ───────── LOGIN ───────── */

  Future<LoginResult> login(String email, String password) async {
    state = const AuthState.loading();

    try {
      final fbUser = await _repository.login(email, password);

      if (fbUser != null) {
        // ✅ CHECK VERIFICATION
        if (!fbUser.emailVerified) {
          await _repository.signOut();
          state = const AuthState.unauthenticated();
          return const LoginResult(
            success: false,
            message: "Please verify your email before logging in",
            needsVerification: true,
          );
        }

        // ✅ SYNC VERIFICATION STATUS TO FIRESTORE
        await _repository.updateVerificationStatus(fbUser.uid);

        // ✅ FETCH USER DATA FROM FIRESTORE
        final userDoc = await _repository.getUserDoc(fbUser.uid);
        final userData = userDoc.data() as Map<String, dynamic>;

        final user = User(
          id: fbUser.uid,
          name: userData['name'] ?? '',
          phone: userData['phone'] ?? '',
          email: userData['email'] ?? '',
          nationalId: userData['nationalId'] ?? '',
          isEmailVerified: true,
          isPhoneVerified: true,
          profileImagePath: null,
          medicalInfo: MedicalInfo.empty(),
          savedLocations: const [],
        );

        // ✅ SAVE SESSION
        await AuthLocalStorage.saveSession(user);

        // ✅ UPDATE STATE
        state = AuthState.authenticated(user);

        // ✅ Sync profile data
        ref.read(profileProvider.notifier).setUser(user);

        // ✅ Set User ID for FCM (automatically saves token & handles refresh)
        PushNotificationService.setUserId(user.id);
        return const LoginResult(success: true);
      } else {
        state = const AuthState.unauthenticated();
        return const LoginResult(success: false, message: "Login failed");
      }
    } on Exception catch (e) {
      String msg = e.toString();
      if (msg.contains('user-not-found')) msg = "No account found with this email";
      if (msg.contains('wrong-password')) msg = "Incorrect password";
      if (msg.contains('network-request-failed')) msg = "Network error. Please check your connection";
      
      state = AuthState.error(msg);
      return LoginResult(success: false, message: msg);
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await _repository.resendVerificationEmail();
    } catch (e) {
      print("RESEND ERROR: $e");
    }
  }

  /* ───────── SIGNUP ───────── */

  Future<bool> signup({
    required String name,
    required String phone,
    required String nationalId,
    required String email,
    required String password,
    required String city,
    required String district,
  }) async {
    state = const AuthState.loading();

    try {
      final user = await _repository.register(
        name: name,
        phone: phone,
        nationalId: nationalId,
        email: email,
        password: password,
        city: city,
        district: district,
      );

      // ❗ Stay unauthenticated after signup
      state = const AuthState.unauthenticated();

      return user != null;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  /* ───────── RESTORE SESSION ───────── */

  Future<void> restoreSession() async {
    final fbUser = _repository.currentUser;

    if (fbUser != null && fbUser.emailVerified) {
      final user = await AuthLocalStorage.loadSession();
      if (user != null) {
        state = AuthState.authenticated(user);

        // ✅ Restore profile data
        ref.read(profileProvider.notifier).setUser(user);

        // ✅ Set User ID for FCM (automatically saves token & handles refresh)
        PushNotificationService.setUserId(user.id);
        return;
      }
    }
    
    state = const AuthState.unauthenticated();
  }

  /* ───────── LOGOUT ───────── */

  Future<void> logout() async {
    await AuthLocalStorage.clearSession();
    PushNotificationService.setUserId(null);
    state = const AuthState.unauthenticated();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }
}

class LoginResult {
  final bool success;
  final String? message;
  final bool needsVerification;

  const LoginResult({
    required this.success,
    this.message,
    this.needsVerification = false,
  });
}
