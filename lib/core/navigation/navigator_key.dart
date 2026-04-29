import 'package:flutter/material.dart';

/// Global navigator key used to navigate from outside the widget tree
/// (e.g., when a push notification is tapped in background/terminated state).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
