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
      debugPrint("WebSocket connected: $wsUrl");
    } catch (e) {
      debugPrint("WebSocket connection failed: $e");
    }
  }

  Stream<dynamic> get stream {
    if (_channel == null) {
      debugPrint("WebSocket stream accessed before connect()");
      return const Stream.empty();
    }
    return _channel!.stream;
  }

  void send(Map<String, dynamic> data) {
    if (_channel == null) return;

    final encoded = jsonEncode(data);
    _channel!.sink.add(encoded);
  }

  void disconnect() {
    if (_channel != null) {
      debugPrint("WebSocket disconnected");
      _channel!.sink.close();
      _channel = null;
    }
  }
}
