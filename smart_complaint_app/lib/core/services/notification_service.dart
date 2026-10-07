import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static Map<String, dynamic>? pendingPayload;
  static void Function(Map<String, dynamic>)? onPayloadTapped;

  static void _handlePayload(Map<String, dynamic> payload) {
    debugPrint('Notification tapped with payload: $payload');
    if (onPayloadTapped != null) {
      onPayloadTapped!(payload);
    } else {
      pendingPayload = payload;
    }
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final ApiService _apiService;

  NotificationService(this._apiService);

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin);

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          try {
            final data = jsonDecode(response.payload!) as Map<String, dynamic>;
            _handlePayload(data);
          } catch (e) {
            debugPrint('Error decoding local notification payload: $e');
            _handlePayload({'type': 'unknown'});
          }
        }
      }
    );

    await requestPermission();

    // Terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handlePayload(initialMessage.data);
    }

    // Background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handlePayload(message.data);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) {
      registerDeviceToken(token);
    });

    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await registerDeviceToken(token);
    }
  }

  Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'smart_complaint_channel',
      'Smart Complaint Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotificationsPlugin.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  Future<void> registerDeviceToken(String token) async {
    try {
      await _apiService.post('/notifications/register-device', {
        'fcmToken': token,
        'platform': defaultTargetPlatform.name,
      });
    } catch (e) {
      debugPrint('Failed to register device token: $e');
    }
  }
}
