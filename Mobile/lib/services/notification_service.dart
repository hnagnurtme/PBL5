import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

import 'api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> init() async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ FCM Permission granted');
    }

    // Get FCM token
    String? token = await _fcm.getToken();
    if (token != null) {
      print('📱 FCM Token: $token');
      // Send to backend
      await ApiService().updateFcmToken(token);
    }

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listen for background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Handle notification when app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundMessage(message);
      }
    });
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📬 Received foreground message: ${message.notification?.title}');
    
    final data = message.data;
    
    if (data['type'] == 'danger_alert') {
      // Trigger alert
      await _triggerDangerAlert(message);
    } else {
      // Show normal notification
      await _showLocalNotification(message);
    }
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('📬 Received background message: ${message.notification?.title}');
    // Handle tap on notification
  }

  Future<void> _triggerDangerAlert(RemoteMessage message) async {
    // Rung mạnh
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(
        duration: 3000,
        pattern: [500, 1000, 500, 1000, 500, 1000],
      );
    }

    // Phát âm thanh
    await _audioPlayer.play(AssetSource('sounds/alert_sound.mp3'));
    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    // Stop after 15 seconds
    Future.delayed(const Duration(seconds: 15), () {
      _audioPlayer.stop();
    });

    // Show high priority notification
    await _showLocalNotification(message, highPriority: true);
  }

  Future<void> _showLocalNotification(
    RemoteMessage message, {
    bool highPriority = false,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'roadsentinel_channel',
      'RoadSentinel Alerts',
      channelDescription: 'Driver safety alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Cảnh báo',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    print('📲 Notification tapped: ${response.payload}');
    // Navigate to specific screen
  }
}
