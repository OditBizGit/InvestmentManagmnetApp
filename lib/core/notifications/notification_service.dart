import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:maribel_wellness_centre_application/user/home/notification_screen.dart';
import 'package:maribel_wellness_centre_application/user/home/repository/notifications_repository.dart';

/// Top-level navigator key used for notification tap navigation.
final GlobalKey<NavigatorState> notificationNavigatorKey =
    GlobalKey<NavigatorState>();

class NotificationService {
  NotificationService({
    required NotificationsRepository notificationsRepository,
    required LocalStorage localStorage,
  })  : _notificationsRepository = notificationsRepository,
        _localStorage = localStorage;

  final NotificationsRepository _notificationsRepository;
  final LocalStorage _localStorage;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'maribel_high_importance',
    'Maribel Notifications',
    description: 'Push notifications for Maribel Wellness Centre',
    importance: Importance.high,
  );

  bool _initialized = false;
  RemoteMessage? _pendingInitialMessage;

  Future<void> initialize() async {
    if (_initialized) return;

    await _initLocalNotifications();
    await _requestPermission();

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Defer until after splash navigation so pushReplacement cannot drop the route.
    _pendingInitialMessage = await _messaging.getInitialMessage();

    _messaging.onTokenRefresh.listen((token) {
      _registerToken(token);
    });

    if (_isInvestorSession()) {
      await registerDeviceToken();
    }

    _initialized = true;
  }

  /// Opens the notification screen if the app was launched from a tap.
  /// Call after splash has navigated to the authenticated user home shell.
  void handlePendingInitialMessage() {
    // No-op on admin builds where [initialize] was never called.
    if (!_initialized || !_isInvestorSession()) {
      _pendingInitialMessage = null;
      return;
    }

    final message = _pendingInitialMessage;
    _pendingInitialMessage = null;
    if (message == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNotificationTap(message);
    });
  }

  /// Fetches the current FCM token and registers it with the backend.
  Future<void> registerDeviceToken() async {
    if (!_isInvestorSession()) return;

    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('FCM token unavailable');
        return;
      }
      await _registerToken(token);
    } catch (e) {
      debugPrint('Failed to register FCM device token: $e');
    }
  }

  bool _isInvestorSession() {
    if (!_localStorage.hasValidSession()) return false;
    final role = _localStorage.getUserRole()?.toLowerCase();
    return role == 'investor';
  }

  Future<void> _registerToken(String token) async {
    if (!_isInvestorSession()) return;
    if (kIsWeb) return;

    final platform = Platform.isIOS
        ? 'ios'
        : Platform.isAndroid
            ? 'android'
            : null;
    if (platform == null) return;

    try {
      await _notificationsRepository.registerDevice(
        deviceToken: token,
        platform: platform,
      );
      if (kDebugMode) {
        debugPrint('FCM device registered ($platform)');
      }
    } catch (e) {
      debugPrint('registerDevice failed: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (_) {
        _openNotificationScreen();
      },
    );

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (kDebugMode) {
      debugPrint(
        'Notification permission: ${settings.authorizationStatus}',
      );
    }

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['message']?.toString();

    if (title == null && body == null) return;

    await _localNotifications.show(
      id: notification?.hashCode ?? message.hashCode,
      title: title ?? 'Maribel',
      body: body ?? '',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.toString(),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint(
        'Notification tapped type=${message.data['type']} '
        'relatedId=${message.data['relatedId'] ?? message.data['referenceId']}',
      );
    }
    _openNotificationScreen();
  }

  void _openNotificationScreen() {
    final navigator = notificationNavigatorKey.currentState;
    if (navigator == null) return;

    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => const NotificationScreen(),
      ),
    );
  }
}
