import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request notification permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Notification permission: ${settings.authorizationStatus}');

    // Get FCM token
    final token = await _messaging.getToken();

    print('====================================');
    print('FCM TOKEN:');
    print(token);
    print('====================================');

    // Listen for token changes
    _messaging.onTokenRefresh.listen((newToken) {
      print('FCM TOKEN REFRESHED: $newToken');

      // Later we will send this new token to .NET
    });

    // Foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('====================================');
      print('FOREGROUND NOTIFICATION');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
      print('====================================');
    });

    // Notification tapped when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('NOTIFICATION CLICKED');
      print('Data: ${message.data}');

      _handleNotificationTap(message);
    });

    // Notification tapped when app was completely closed
    final initialMessage =
    await _messaging.getInitialMessage();

    if (initialMessage != null) {
      print('APP OPENED FROM NOTIFICATION');
      print('Data: ${initialMessage.data}');

      _handleNotificationTap(initialMessage);
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type'];
    final referenceId = message.data['referenceId'];

    print('Notification type: $type');
    print('Reference ID: $referenceId');

    // Navigation will be implemented later.
  }
}