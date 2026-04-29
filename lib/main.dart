import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'services/push_notification_service.dart';
import 'core/navigation/navigator_key.dart';

import 'core/theme/theme_provider.dart';
import 'features/auth/state/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/navigation/bottom_nav_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? startupError;
  StackTrace? startupStack;
  var firebaseReady = false;
  var webFirebaseMissing = false;

  try {
    // 1. Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;

    if (!kIsWeb) {
      // 2. Setup Background Message Handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 3. Initialize push notifications in the background to avoid blocking first frame
      unawaited(PushNotificationService.initialize());
    }
  } catch (e, st) {
    final isMissingWebFirebaseConfig = kIsWeb &&
        e is UnsupportedError &&
        e.toString().contains('have not been configured for web');

    if (isMissingWebFirebaseConfig) {
      webFirebaseMissing = true;
      debugPrint('Firebase web config missing. Running in web-limited mode.');
    } else {
      startupError = e;
      startupStack = st;
      debugPrint('Startup initialization failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  runApp(
    ProviderScope(
      child: GargaarApp(
        startupError: startupError,
        startupStack: startupStack,
        firebaseReady: firebaseReady,
        webFirebaseMissing: webFirebaseMissing,
      ),
    ),
  );
}

class GargaarApp extends ConsumerWidget {
  const GargaarApp({
    super.key,
    this.startupError,
    this.startupStack,
    required this.firebaseReady,
    required this.webFirebaseMissing,
  });

  final Object? startupError;
  final StackTrace? startupStack;
  final bool firebaseReady;
  final bool webFirebaseMissing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (startupError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'App startup failed',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(startupError.toString()),
                  if (startupStack != null) ...[
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(startupStack.toString()),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (webFirebaseMissing || !firebaseReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Web setup required',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Firebase web is not configured yet for this app.\n\n'
                    'To enable login, Firestore, and notifications on web, run:\n'
                    '1) firebase login\n'
                    '2) flutterfire configure\n\n'
                    'Then restart the app on Chrome.',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final themeMode = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);

    Widget home;

    if (authState.isLoading) {
      home = const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (authState.isAuthenticated) {
      home = const BottomNavShell();
    } else {
      home = LoginScreen(); // ❗ removed const (important)
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      themeMode: themeMode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: home,
    );
  }
}
