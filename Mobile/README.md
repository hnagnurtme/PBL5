# Mobile - Flutter Driver App

## 📁 Cấu Trúc Thư Mục

```
Mobile/
├── lib/
│   ├── main.dart                # Entry point
│   │
│   ├── screens/                 # UI Screens
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── safety_score_card.dart
│   │   │       └── trip_info_card.dart
│   │   │
│   │   ├── attendance/
│   │   │   ├── check_in_screen.dart
│   │   │   ├── check_out_screen.dart
│   │   │   └── attendance_history.dart
│   │   │
│   │   ├── violations/
│   │   │   ├── violation_list_screen.dart
│   │   │   ├── violation_detail_screen.dart
│   │   │   └── appeal_form_screen.dart
│   │   │
│   │   ├── payroll/
│   │   │   ├── salary_screen.dart
│   │   │   └── salary_detail_screen.dart
│   │   │
│   │   └── profile/
│   │       ├── profile_screen.dart
│   │       └── settings_screen.dart
│   │
│   ├── widgets/                 # Reusable widgets
│   │   ├── custom_button.dart
│   │   ├── custom_card.dart
│   │   ├── alert_dialog.dart
│   │   └── loading_indicator.dart
│   │
│   ├── services/                # Services layer
│   │   ├── api_service.dart    # HTTP API calls
│   │   ├── auth_service.dart
│   │   ├── violation_service.dart
│   │   ├── payroll_service.dart
│   │   ├── websocket_service.dart  # WebSocket connection
│   │   ├── notification_service.dart  # FCM handler
│   │   ├── location_service.dart   # GPS tracking
│   │   └── vibration_service.dart  # Rung cảnh báo
│   │
│   ├── models/                  # Data models
│   │   ├── user.dart
│   │   ├── driver.dart
│   │   ├── violation.dart
│   │   ├── attendance.dart
│   │   ├── salary.dart
│   │   └── alert.dart
│   │
│   ├── providers/               # State management (Provider/Riverpod)
│   │   ├── auth_provider.dart
│   │   ├── driver_provider.dart
│   │   ├── violation_provider.dart
│   │   └── alert_provider.dart
│   │
│   ├── utils/                   # Utilities
│   │   ├── constants.dart
│   │   ├── validators.dart
│   │   ├── date_formatter.dart
│   │   └── theme.dart
│   │
│   └── config/                  # Configuration
│       ├── app_config.dart
│       └── routes.dart
│
├── assets/                      # Static assets
│   ├── images/
│   │   └── logo.png
│   └── sounds/
│       └── alert_sound.mp3     # Âm thanh cảnh báo
│
├── android/                     # Android config
│   └── app/
│       └── google-services.json # FCM config
│
├── ios/                         # iOS config
│   └── Runner/
│       └── GoogleService-Info.plist
│
├── pubspec.yaml                 # Flutter dependencies
├── .env                         # Environment variables
└── README.md
```

## 🎯 Tính Năng Chính

### 1. 🚨 Alert System (Nhận Cảnh Báo)
- **FCM Push Notification:** Nhận thông báo từ Backend khi có vi phạm
- **Rung mạnh:** Sử dụng Vibration plugin
- **Phát âm thanh cảnh báo:** Audio player (audioplayers package)
- **Alert Dialog:** Hiển thị popup đỏ toàn màn hình

### 2. 🕐 Chấm Công (Attendance)
- **Check-in/Check-out:** GPS verification
- **Face Recognition (Optional):** Camera tích hợp
- **Lịch sử chấm công:** Xem ca làm việc

### 3. 💰 Lương & Vi Phạm
- **Bảng lương real-time:** Hiển thị thu nhập tạm tính
- **Lịch sử vi phạm:** Xem ảnh bằng chứng
- **Gửi khiếu nại:** Form appeal nếu bị phạt sai

### 4. 📍 GPS Tracking (Background)
- Gửi vị trí lên Server mỗi 30 giây (khi đang làm việc)

## 🛠️ Tech Stack & Packages

```yaml
dependencies:
  flutter_riverpod: ^2.4.0        # State management
  dio: ^5.3.3                      # HTTP client
  web_socket_channel: ^2.4.0      # WebSocket
  firebase_messaging: ^14.6.9     # FCM push notification
  geolocator: ^10.1.0             # GPS tracking
  vibration: ^1.8.3               # Rung cảnh báo
  audioplayers: ^5.2.0            # Phát âm thanh
  permission_handler: ^11.0.1     # Request permissions
  flutter_local_notifications: ^16.1.0  # Local notifications
  cached_network_image: ^3.3.0    # Cache images
  intl: ^0.18.1                   # Date formatting
  flutter_dotenv: ^5.1.0          # Environment variables
```

## 🚀 Setup & Run

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Configure Firebase
- Thêm `google-services.json` vào `android/app/`
- Thêm `GoogleService-Info.plist` vào `ios/Runner/`

### 3. Run app
```bash
# Android
flutter run

# iOS
flutter run --release
```

## 📡 WebSocket Integration

```dart
// lib/services/websocket_service.dart
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  late WebSocketChannel _channel;
  
  void connect(String driverId) {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://api.roadsentinel.com/ws/driver/$driverId/'),
    );
    
    _channel.stream.listen((message) {
      // Parse JSON message
      final alert = Alert.fromJson(jsonDecode(message));
      
      if (alert.type == 'DANGER') {
        _triggerAlert(alert);
      }
    });
  }
  
  void _triggerAlert(Alert alert) {
    // Rung mạnh
    Vibration.vibrate(duration: 2000, pattern: [500, 1000, 500, 1000]);
    
    // Phát âm thanh
    final player = AudioPlayer();
    player.play(AssetSource('sounds/alert_sound.mp3'));
    
    // Hiển thị Alert Dialog
    // ...
  }
}
```

## 🔔 Firebase Cloud Messaging (FCM)

### Android Setup (`android/app/build.gradle`)
```gradle
dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.2.1'
}
```

### Flutter Code
```dart
// lib/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  Future<void> init() async {
    // Request permission
    await _fcm.requestPermission();
    
    // Get FCM token
    String? token = await _fcm.getToken();
    print('FCM Token: $token');
    
    // Send token to backend
    await ApiService().updateFcmToken(token);
    
    // Listen for messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Nhận được cảnh báo: ${message.notification?.title}');
      _triggerAlert(message.data);
    });
  }
}
```

## 📱 Permissions Required

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Cần truy cập vị trí để chấm công và tracking</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Cần truy cập vị trí để tracking khi chạy xe</string>
```

## 🎨 UI/UX Features
- **Material Design 3:** Modern UI
- **Dark Mode:** Hỗ trợ chế độ tối
- **Splash Screen:** Logo công ty
- **Bottom Navigation Bar:** Điều hướng chính
- **Pull to Refresh:** Cập nhật dữ liệu

## 🔐 Security
- Lưu JWT token trong Secure Storage
- HTTPS only
- Certificate pinning (production)