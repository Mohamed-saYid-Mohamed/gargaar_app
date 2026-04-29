// Imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../features/incidents/models/incident_location.dart';
import '../core/services/call_log_service.dart';
import '../features/incidents/models/incident_type.dart';

// ─────────────────────────────────────────────
// Report ID holder
// ─────────────────────────────────────────────
final reportIdProvider = StateProvider<String?>((ref) => null);

// ─────────────────────────────────────────────
// Incident types (ENUM = SOURCE OF TRUTH)
// ─────────────────────────────────────────────
final incidentTypesProvider = Provider<List<IncidentType>>((ref) {
  return IncidentType.values;
});
// ─────────────────────────────────────────────
// Submit Incident (REAL FIRESTORE IMPLEMENTATION)
// ─────────────────────────────────────────────
final submitIncidentProvider =
    StateNotifierProvider<SubmitIncidentNotifier, AsyncValue<void>>(
  (ref) => SubmitIncidentNotifier(ref),
);

class SubmitIncidentNotifier extends StateNotifier<AsyncValue<void>> {
  SubmitIncidentNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> submitIncident({
    required IncidentType type,
    required String description,
    required IncidentLocation location,
    required bool isAnonymous,
    required String priority,
    File? imageFile,
    File? videoFile,
    File? audioFile,
  }) async {
    state = const AsyncValue.loading();

    try {
      // 1️⃣ GET CURRENT USER DATA
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (!userDoc.exists) throw Exception("User profile not found");
      final userData = userDoc.data()!;

      // 2️⃣ UPLOAD MEDIA TO STORAGE
      List<String> mediaUrls = [];
      String? voiceUrl;

      // Upload Image
      if (imageFile != null) {
        final url = await _uploadFile(
          imageFile,
          "incidents/media/${DateTime.now().millisecondsSinceEpoch}.jpg",
        );
        if (url != null) {
          mediaUrls.add(url);
          print("MEDIA UPLOADED: $url");
        }
      }

      // Upload Video
      if (videoFile != null) {
        final url = await _uploadFile(
          videoFile,
          "incidents/media/${DateTime.now().millisecondsSinceEpoch}.mp4",
        );
        if (url != null) {
          mediaUrls.add(url);
          print("MEDIA UPLOADED: $url");
        }
      }

      // Upload Audio
      if (audioFile != null) {
        voiceUrl = await _uploadFile(
          audioFile,
          "incidents/voice/${DateTime.now().millisecondsSinceEpoch}.aac",
        );
        if (voiceUrl != null) {
          print("VOICE UPLOADED: $voiceUrl");
        }
      }

      // 3️⃣ VALIDATION RULE
      if (description.trim().isEmpty && voiceUrl == null) {
        throw Exception("Please provide either a text description or a voice message.");
      }

      // 4️⃣ BUILD COMPLETE DATA
      final String displayId = "INC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
      
      final data = {
        "displayId": displayId,
        "type": type.name,
        "priority": priority,
        "status": "submitted",

        "reporterId": user.uid,
        "reporterName": userData["name"] ?? "Unknown",
        "reporterPhone": userData["phone"] ?? "Unknown",

        "location": {
          "latitude": location.latitude,
          "longitude": location.longitude,
        },

        "city": userData["city"] ?? "Not specified",
        "district": userData["district"] ?? "Not specified",

        "description": description,
        "mediaUrls": mediaUrls,
        "voiceUrl": voiceUrl,

        "createdAt": FieldValue.serverTimestamp(),
        "isAnonymous": isAnonymous,
      };

      print("FINAL DATA: $data");
      print("📤 Sending incident $displayId to Firestore");
      await FirebaseFirestore.instance.collection("incidents").add(data);

      print("✅ Incident saved successfully");

      // Set display ID for UI reference
      ref.read(reportIdProvider.notifier).state = displayId;

      state = const AsyncValue.data(null);
    } catch (e) {
      print("❌ Error: $e");
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<String?> _uploadFile(File file, String path) async {
    print("FILE PATH: ${file.path}");
    final exists = await file.exists();
    print("FILE EXISTS: $exists");

    if (!exists) {
      print("❌ Upload failed: File does not exist");
      return null;
    }

    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print("Upload error ($path): $e");
      return null;
    }
  }
}

// ─────────────────────────────────────────────
// Localization (TEMP)
// ─────────────────────────────────────────────
class AppStrings {
  final String appName = 'GARGAAR';
  final String slogan = 'Emergency reporting made simple';
  final String reportNow = 'Report Now';
  final String emergencyResponders = 'Emergency Responders';
  final String emergencyContacts = 'Emergency Contacts';

  final String policeHotline = 'Police';
  final String ambulanceHotline = 'Ambulance';
  final String fireHotline = 'Fire';

  final String priorityDispatch = 'Priority Dispatch';
}

final localizationProvider = Provider<AppStrings>((ref) {
  return AppStrings();
});

// ─────────────────────────────────────────────
// Auth (TEMP)
// ─────────────────────────────────────────────
final authUserIdProvider = Provider<String>((ref) {
  return 'anonymous-user';
});

// ─────────────────────────────────────────────
// Services
// ─────────────────────────────────────────────
final callLogServiceProvider = Provider<CallLogService>((ref) {
  return CallLogService();
});
