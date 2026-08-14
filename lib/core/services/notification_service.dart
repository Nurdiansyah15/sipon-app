import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import '../../shared/router/app_router.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (error, stackTrace) {
    debugPrint('Firebase background init failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  await NotificationService.instance.handleBackgroundMessage(message);
}

class NotificationPayload {
  const NotificationPayload({
    required this.title,
    required this.body,
    required this.data,
  });

  final String? title;
  final String? body;
  final Map<String, String> data;

  static NotificationPayload fromRemoteMessage(RemoteMessage message) {
    final payloadData = <String, String>{};
    for (final entry in message.data.entries) {
      payloadData[entry.key] = entry.value.toString();
    }

    return NotificationPayload(
      title: message.notification?.title ?? payloadData['title'],
      body: message.notification?.body ?? payloadData['body'],
      data: payloadData,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'data': data,
  };
}

class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();

  static NotificationService get instance => _instance;

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final Set<String> _processedMessages = <String>{};
  final List<Map<String, dynamic>> _pendingNotifications = <Map<String, dynamic>>[];

  AppRouter? _router;
  bool _initialized = false;

  void attachRouter(AppRouter router) {
    _router = router;
    if (_pendingNotifications.isNotEmpty) {
      for (final pending in _pendingNotifications) {
        unawaited(handleNotificationTap(pending));
      }
      _pendingNotifications.clear();
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Firebase initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _initialized = true;
      return;
    }

    try {
      await _configureLocalNotifications();
      await requestPermission();

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((message) {
        unawaited(handleForegroundMessage(message));
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        unawaited(handleNotificationTap(NotificationPayload.fromRemoteMessage(message).data));
      });

      _messaging.onTokenRefresh.listen((token) {
        debugPrint('FCM token refreshed: $token');
      });

      await handleInitialMessage();
      final token = await getToken();
      debugPrint('FCM token: $token');
    } catch (error, stackTrace) {
      debugPrint('FCM setup failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    _initialized = true;
  }

  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      sound: true,
      criticalAlert: false,
      provisional: false,
    );

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      'FCM permission status: ${settings.authorizationStatus.name}',
    );
  }

  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('FCM token fetched: $token');
      return token;
    } catch (error, stackTrace) {
      debugPrint('Unable to fetch FCM token: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> handleForegroundMessage(RemoteMessage message) async {
    final payload = NotificationPayload.fromRemoteMessage(message);
    debugPrint('Foreground FCM payload: ${payload.toJson()}');

    if (message.messageId != null && !_processedMessages.add(message.messageId!)) {
      return;
    }

    final title = payload.title;
    final body = payload.body;

    if (title != null || body != null) {
      await _showLocalNotification(payload);
    }
  }

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    final payload = NotificationPayload.fromRemoteMessage(message);
    debugPrint('Background FCM payload: ${payload.toJson()}');
  }

  Future<void> handleNotificationTap(Map<String, dynamic> data) async {
    final route = _resolveRoute(data);
    if (route == null) {
      debugPrint('No valid notification route found for data: $data');
      return;
    }

    final router = _router;
    if (router == null) {
      _pendingNotifications.add(data);
      return;
    }

    router.router.go(route);
  }

  Future<void> handleInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message == null) return;

    final payload = NotificationPayload.fromRemoteMessage(message);
    debugPrint('Initial FCM payload: ${payload.toJson()}');
    await handleNotificationTap(payload.data);
  }

  String? _resolveRoute(Map<String, dynamic> data) {
    final routeFromData = data['route'] ?? data['path'] ?? data['screen'];
    if (routeFromData is String && routeFromData.isNotEmpty) {
      final candidate = routeFromData.trim();
      if (candidate.startsWith('/')) {
        return candidate;
      }
      switch (candidate.toLowerCase()) {
        case 'dashboard':
          return '/dashboard';
        case 'login':
          return '/login';
        case 'register':
          return '/register';
      }
    }

    final type = (data['type'] ?? '').toString().toLowerCase();
    switch (type) {
      case 'dashboard':
        return '/dashboard';
      case 'login':
        return '/login';
      case 'register':
        return '/register';
    }

    return null;
  }

  Future<void> _configureLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    final settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == null || response.payload!.isEmpty) {
          return;
        }

        try {
          final payloadMap = jsonDecode(response.payload!);
          if (payloadMap is Map<String, dynamic>) {
            unawaited(handleNotificationTap(payloadMap));
          }
        } catch (_) {
          debugPrint('Unable to decode local notification payload');
        }
      },
    );

    const androidChannel = AndroidNotificationChannel(
      'sipon_default_channel',
      'Sipon Notifications',
      description: 'General app notifications',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _showLocalNotification(NotificationPayload payload) async {
    final title = payload.title ?? 'Sipon';
    final body = payload.body ?? '';

    final androidDetails = AndroidNotificationDetails(
      'sipon_default_channel',
      'Sipon Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: body,
    );

    const iosDetails = DarwinNotificationDetails();

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final payloadJson = jsonEncode(payload.toJson());

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformDetails,
      payload: payloadJson,
    );
  }
}
