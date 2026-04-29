import '../../../core/models/user.dart';

class ProfileState {
  final User user;
  final bool isLoading;

  const ProfileState({
    required this.user,
    this.isLoading = false,
  });

  ProfileState copyWith({
    User? user,
    bool? isLoading,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
