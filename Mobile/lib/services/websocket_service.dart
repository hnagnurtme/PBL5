import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/alert.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  Function(Alert)? onAlertReceived;

  void connect(String driverId, String token) {
    final wsUrl = dotenv.env['WS_URL'] ?? 'ws://localhost:8000/ws';
    
    _channel = WebSocketChannel.connect(
      Uri.parse('$wsUrl/driver/$driverId/?token=$token'),
    );

    _channel!.stream.listen(
      (message) {
        _handleMessage(message);
      },
      onError: (error) {
        print('❌ WebSocket Error: $error');
      },
      onDone: () {
        print('⚠️ WebSocket Disconnected');
        _reconnect(driverId, token);
      },
    );

    print('✅ WebSocket Connected');
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      
      if (data['type'] == 'danger_alert') {
        final alert = Alert.fromJson(data['message']);
        _triggerAlert(alert);
        
        if (onAlertReceived != null) {
          onAlertReceived!(alert);
        }
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  Future<void> _triggerAlert(Alert alert) async {
    print('🚨 DANGER ALERT: ${alert.message}');
    
    // Rung mạnh với pattern
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(
        duration: 2000,
        pattern: [500, 1000, 500, 1000, 500, 1000],
        intensities: [128, 255, 128, 255, 128, 255],
      );
    }
    
    // Phát âm thanh cảnh báo
    await _audioPlayer.play(AssetSource('sounds/alert_sound.mp3'));
    
    // Lặp lại âm thanh 3 lần
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    
    // Dừng sau 10 giây
    Future.delayed(const Duration(seconds: 10), () {
      _audioPlayer.stop();
    });
  }

  void _reconnect(String driverId, String token) {
    Future.delayed(const Duration(seconds: 5), () {
      print('🔄 Reconnecting WebSocket...');
      connect(driverId, token);
    });
  }

  void disconnect() {
    _channel?.sink.close();
    _audioPlayer.dispose();
  }
}
