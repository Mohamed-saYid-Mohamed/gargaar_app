import '../../../core/models/user.dart';

class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  bool get isAuthenticated => user != null;

  const AuthState.unauthenticated()
      : isLoading = false,
        user = null,
        error = null;

  const AuthState.loading()
      : isLoading = true,
        user = null,
        error = null;

  const AuthState.authenticated(User user)
      : isLoading = false,
        user = user,
        error = null;

  const AuthState.error(String message)
      : isLoading = false,
        user = null,
        error = message;
}
