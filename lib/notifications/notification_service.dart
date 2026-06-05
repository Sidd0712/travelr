import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

typedef NotificationHandler = void Function(RemoteMessage message);

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  NotificationHandler? onForegroundMessage;
  NotificationHandler? onNotificationTap;
  bool _listenersRegistered = false;

  static const String _baseUrl = 'https://travelr-ml.onrender.com';

  /// Call ONCE after login (e.g. in splash screen)
  Future<void> init({
    NotificationHandler? onForeground,
    NotificationHandler? onTap,
  }) async {
    onForegroundMessage = onForeground;
    onNotificationTap = onTap;

    try {
      await _requestPermission();
    } catch (e) {
      debugPrint("FCM permission request failed: $e");
    }

    // Initial token
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await sendFcmToken(token);
      }
    } catch (e) {
      debugPrint("FCM token fetch failed (will retry on refresh): $e");
    }

    if (!_listenersRegistered) {
      try {
        // Token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          log("Somehow got the token lol");
          sendFcmToken(newToken);
        });

        // Foreground messages
        FirebaseMessaging.onMessage.listen((message) {
          log('FCM foreground: ${message.data}');
          onForegroundMessage?.call(message);
        });

        // Background opened
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
          log('FCM opened from background: ${message.data}');
          onNotificationTap?.call(message);
        });

        _listenersRegistered = true;
      } catch (e) {
        debugPrint("FCM listener registration failed: $e");
      }
    }

    // Terminated opened
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        log('FCM opened from terminated: ${initialMessage.data}');
        onNotificationTap?.call(initialMessage);
      }
    } catch (e) {
      debugPrint("FCM initial message fetch failed: $e");
    }
  }

  //  Backend Integration
  Future<void> sendFcmToken(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final idToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse('$_baseUrl/users/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to register FCM token: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending FCM token: $e');
    }
  }

  Future<void> unregisterFcmToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final idToken = await user.getIdToken();
      final token = await _messaging.getToken();
      if (token == null) return;

      await http.delete(
        Uri.parse('$_baseUrl/users/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'token': token}),
      );

      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('Error unregistering FCM token: $e');
    }
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
