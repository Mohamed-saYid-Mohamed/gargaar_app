class MedicalInfo {
  final String bloodGroup;
  final String allergies;
  final String chronicDiseases;

  const MedicalInfo({
    required this.bloodGroup,
    required this.allergies,
    required this.chronicDiseases,
  });

  factory MedicalInfo.empty() {
    return const MedicalInfo(
      bloodGroup: '',
      allergies: '',
      chronicDiseases: '',
    );
  }

  MedicalInfo copyWith({
    String? bloodGroup,
    String? allergies,
    String? chronicDiseases,
  }) {
    return MedicalInfo(
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
    );
  }
}
