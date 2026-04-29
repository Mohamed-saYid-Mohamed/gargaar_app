import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/navigation/navigator_key.dart';
import '../features/incidents/presentation/report_tracking_screen.dart';
import '../features/incidents/models/report_status.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/chat/presentation/incident_chat_screen.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("🔥 BACKGROUND MESSAGE RECEIVED: ${message.messageId}");
  // If the message contains only data (no notification object), the system won't show it.
  // We manually show it here to ensure visibility in background/terminated states.
  if (message.notification == null) {
     PushNotificationService.showNotificationDirectly(message);
  }
}

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static String? _currentUserId;

  /// 🚀 Initialize Push Notifications
  static Future<void> initialize() async {
    // 1. Request Permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint("🔥 NOTIFICATION PERMISSION: ${settings.authorizationStatus}");

    // 2. Setup Background Handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 3. Foreground Messages
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint("🔥 FOREGROUND MESSAGE RECEIVED: ${message.messageId}");
      _showLocalNotification(message);
    });

    // 4. Handle Notification Tap (App in background)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint("🔥 MESSAGE OPENED APP FROM BACKGROUND: ${message.messageId}");
      _handleNavigation(message);
    });

    // 5. Handle Notification Tap (App terminated)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint("🔥 MESSAGE OPENED APP FROM TERMINATED: ${initialMessage.messageId}");
      _handleNavigation(initialMessage);
    }

    // 6. Initialize Local Notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint("🔥 LOCAL NOTIFICATION TAPPED: ${details.payload}");
        _handleNavigationFromLocal(details.payload);
      },
    );

    // 7. Handle Token Refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint("🔥 FCM TOKEN REFRESHED: $newToken");
      if (_currentUserId != null) {
        await _saveTokenToFirestore(_currentUserId!, newToken);
      }
    });
  }

  /// 🔐 Set User ID to enable automatic token updates on refresh
  static void setUserId(String? userId) {
    _currentUserId = userId;
    if (userId != null) {
      // Perform initial sync when user ID is set
      saveTokenToFirestore(userId);
    }
  }

  /// 💾 Save Device Token to Firestore with Migration Logic
  static Future<void> saveTokenToFirestore(String userId) async {
    try {
      final token = await _messaging.getToken();
      
      if (token == null) {
        debugPrint("❌ [FCM] Error: Token is null.");
        return;
      }

      await _saveTokenToFirestore(userId, token);
    } catch (e) {
      debugPrint("❌ [FCM] Error getting token: $e");
    }
  }

  /// Internal helper to save token and migrate legacy field
  static Future<void> _saveTokenToFirestore(String userId, String token) async {
    try {
      debugPrint("🔥 [FCM] Syncing token for user $userId...");

      final userRef = _firestore.collection("users").doc(userId);
      final userDoc = await userRef.get();

      List<String> tokens = [];
      
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        
        // 1. Get existing array tokens
        if (data['fcmTokens'] is List) {
          tokens = List<String>.from(data['fcmTokens']);
        }

        // 2. Migrate legacy fcmToken (string) if it exists
        final legacyToken = data['fcmToken'];
        if (legacyToken != null && legacyToken is String && !tokens.contains(legacyToken)) {
          tokens.add(legacyToken);
          debugPrint("📦 [FCM] Migrating legacy token into array...");
        }
      }

      // 3. Add new token if not present
      if (!tokens.contains(token)) {
        tokens.add(token);
      }

      // 4. Update Firestore with clean array format
      await userRef.set({
        "fcmTokens": tokens,
        "fcmToken": token, // Keep legacy for backend compatibility during transition
        "lastTokenUpdate": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint("✅ [FCM] Token synced successfully. Total tokens: ${tokens.length}");
    } catch (e) {
      debugPrint("❌ [FCM] Error saving token to Firestore: $e");
    }
  }

  /// 🔔 Show Local Notification UI
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    await showNotificationDirectly(message);
  }

  /// 🔔 Public method to show notification (used by background handler)
  static Future<void> showNotificationDirectly(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Support both 'notification' object and 'data' payload for title/body
    final title = message.notification?.title ?? 
                  message.data['title'] ?? 
                  'Gargaar Alert';
                  
    final body = message.notification?.body ?? 
                 message.data['body'] ?? 
                 message.data['message'] ?? 
                 'Tap to view details';

    // The payload should be JSON for easy parsing on tap
    final payloadString = message.data.isNotEmpty ? jsonEncode(message.data) : null;

    await _localNotifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payloadString,
    );
  }

  /// 🧭 Navigation Logic from FCM RemoteMessage
  static void _handleNavigation(RemoteMessage message) {
    _performNavigation(message.data);
  }

  /// 🧭 Navigation Logic from LocalNotification payload
  static void _handleNavigationFromLocal(String? payload) {
    if (payload == null) {
      _navigateToNotifications();
      return;
    }
    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      _performNavigation(data);
    } catch (e) {
      debugPrint("❌ Error parsing local notification payload: $e");
      _navigateToNotifications();
    }
  }

  /// Centralized navigation logic
  static void _performNavigation(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    final targetId = data['targetId']?.toString();

    debugPrint("🧭 Navigating based on type: $type, targetId: $targetId");

    if (type == 'incident' || type == 'report') {
      _navigateToReport(targetId);
    } else if (type == 'chat') {
      _navigateToChat(targetId);
    } else {
      _navigateToNotifications();
    }
  }

  static void _navigateToReport([String? targetId]) {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const ReportTrackingScreen(
            status: ReportStatus.pending, // Ideally you'd fetch the real status using targetId
          ),
        ),
      );
    }
  }

  static void _navigateToChat(String? incidentId) {
    if (navigatorKey.currentState != null && incidentId != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => IncidentChatScreen(incidentId: incidentId),
        ),
      );
    }
  }

  static void _navigateToNotifications() {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        ),
      );
    }
  }
}