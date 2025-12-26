import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;

  void connect(String roomId, String userId) {
    final wsUrl = "wss://travelr-ml.onrender.com/ws/live/$roomId/$userId";

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
      );
    } catch (e) {
      debugPrint("WebSocket failed on Android: $e");
    }
  }

  Stream<dynamic> get stream => _channel!.stream;

  void send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
