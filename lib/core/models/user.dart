import 'medical_info.dart';
import 'saved_location.dart';

class User {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String nationalId;

  final bool isEmailVerified;
  final bool isPhoneVerified;

  final String? profileImagePath;

  final MedicalInfo medicalInfo;
  final List<SavedLocation> savedLocations;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.nationalId,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.profileImagePath,
    required this.medicalInfo,
    required this.savedLocations,
  });

  factory User.empty() {
    return User(
      id: '',
      name: '',
      phone: '',
      email: null,
      nationalId: '',
      isEmailVerified: false,
      isPhoneVerified: false,
      profileImagePath: null,
      medicalInfo: MedicalInfo.empty(),
      savedLocations: const [],
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? nationalId,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? profileImagePath,
    MedicalInfo? medicalInfo,
    List<SavedLocation>? savedLocations,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      nationalId: nationalId ?? this.nationalId,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      savedLocations: savedLocations ?? this.savedLocations,
    );
  }
}
