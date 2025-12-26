import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;

  void connect(String roomId, String userId) {
    _channel = WebSocketChannel.connect(
      Uri.parse(
        "wss://www.travelr-ml.onrender/ws/live/$roomId/$userId",
      ),
    );
  }

  Stream<dynamic> get stream => _channel!.stream;

  void send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
