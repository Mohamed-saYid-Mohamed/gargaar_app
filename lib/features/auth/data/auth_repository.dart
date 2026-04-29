import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../../core/models/user.dart';
import '../../../core/models/medical_info.dart';

class AuthRepository {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  auth.User? get currentUser => _firebaseAuth.currentUser;

  /// ───────── LOGIN ─────────

  Future<auth.User?> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on auth.FirebaseAuthException catch (e) {
      print("LOGIN ERROR: ${e.code}");
      rethrow;
    } catch (e) {
      print("LOGIN ERROR: $e");
      rethrow;
    }
  }

  /// ───────── RESEND VERIFICATION EMAIL ─────────

  Future<void> resendVerificationEmail() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// ───────── SYNC VERIFICATION TO FIRESTORE ─────────

  Future<void> updateVerificationStatus(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'isVerified': true,
    });
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<DocumentSnapshot> getUserDoc(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  /// ───────── REGISTER ─────────

  Future<User?> register({
    required String name,
    required String phone,
    required String nationalId,
    required String email,
    required String password,
    required String city,
    required String district,
  }) async {
    try {
      // 1. Create User in Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // 2. Generate Display ID (e.g., USR-123)
      final displayId = "USR-${Random().nextInt(999).toString().padLeft(3, '0')}";

      // 3. Save User Data to Firestore using UID as Document ID
      final userData = {
        'displayId': displayId,
        'name': name,
        'email': email,
        'phone': phone,
        'city': city,
        'district': district,
        'nationalId': nationalId,
        'role': "user", // Hardcoded security rule
        'status': 'active',
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(uid).set(userData);

      // 4. Send Email Verification
      await userCredential.user!.sendEmailVerification();

      // Return user model
      return User(
        id: uid,
        name: name,
        phone: phone,
        email: email,
        nationalId: nationalId,
        isEmailVerified: false,
        isPhoneVerified: false,
        profileImagePath: null,
        medicalInfo: MedicalInfo.empty(),
        savedLocations: const [],
      );
    } catch (e) {
      print("SIGNUP ERROR: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
