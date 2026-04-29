import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/saved_location.dart';
import '../../../core/models/medical_info.dart';
import '../../../core/models/user.dart';

import 'profile_state.dart';

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier()
      : super(
          ProfileState(
            user: User(
              id: 'user-001',
              name: 'Nabil',
              phone: '+2526XXXXXXX',
              nationalId: 'SOM-XXXX',
              email: null,
              isEmailVerified: false,
              isPhoneVerified: false,
              profileImagePath: null,
              medicalInfo: MedicalInfo.empty(),
              savedLocations: const [],
            ),
          ),
        );
  void setUser(User user) {
    state = state.copyWith(user: user);
  }
  // ✅ NEW FIELD INITIAL VALUE
  // profileImagePath: null,

  /* ───────── BASIC INFO ───────── */

  void updateEmail(String email) {
    state = state.copyWith(
      user: state.user.copyWith(email: email),
    );
  }

  void verifyEmail() {
    state = state.copyWith(
      user: state.user.copyWith(isEmailVerified: true),
    );
  }

  /* ───────── MEDICAL INFO ───────── */
  void updateMedicalInfo(MedicalInfo info) {
    state = state.copyWith(
      user: state.user.copyWith(medicalInfo: info),
    );
  }

  /* ───────── PROFILE IMAGE (USER MODEL) ───────── */

  void updateProfileImage(String path) {
    state = state.copyWith(
      user: state.user.copyWith(profileImagePath: path),
    );
  }

  /* ───────── LOCATIONS ───────── */

  void addLocation(SavedLocation location) {
    final updated = <SavedLocation>[
      ...state.user.savedLocations,
      location,
    ];

    state = state.copyWith(
      user: state.user.copyWith(savedLocations: updated),
    );
  }

  void removeLocation(String id) {
    final updated = state.user.savedLocations.where((l) => l.id != id).toList();
    state = state.copyWith(
      user: state.user.copyWith(savedLocations: updated),
    );
  }

  /* ───────── NEW: PROFILE IMAGE (STATE LEVEL) ───────── */

  /// Stores selected profile image path (e.g. from image picker)
//   Future<void> updateProfileImagePath(String path) async {
//     state = state.copyWith(profileImagePath: path);
//   }
}
