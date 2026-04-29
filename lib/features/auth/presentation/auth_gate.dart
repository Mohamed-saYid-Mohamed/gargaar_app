import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/state/auth_provider.dart';
import '../../navigation/bottom_nav_shell.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    print("AUTH GATE: isAuth = ${authState.isAuthenticated}");

    // 🔄 Loading
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ✅ Authenticated
    if (authState.user != null) {
      return const BottomNavShell();
    }

    // ❌ Not authenticated
    return const LoginScreen();
  }
}
