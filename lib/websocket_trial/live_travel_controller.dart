import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travelr/websocket_trial/location_service.dart';
import 'package:travelr/websocket_trial/websocket_service.dart';

class LiveTravelController {
  final WebSocketService _ws = WebSocketService();

  final ValueNotifier<Position?> selfLocation = ValueNotifier(null);
  final ValueNotifier<String?> otherUserLocation = ValueNotifier(null);

  StreamSubscription<Position>? _locationSub;

  void start(String roomId, String userId) async {
    _ws.connect(roomId, userId);

    _ws.stream.listen((msg) {
      final data = msg is String ? msg : msg.toString();
      final parsed = jsonDecode(data);

      if (parsed["status"] == "CONNECTED" && parsed["user_id"] != userId) {
        otherUserLocation.value =
            "${parsed["payload"]["lat"]}, ${parsed["payload"]["lng"]}";
      }
    });

    final pos = await LocationService.getCurrentLocation();
    selfLocation.value = pos;

    _locationSub =
        LocationService.getLocationStream(distanceFilter: 20).listen((pos) {
      selfLocation.value = pos;

      _ws.send({
        "lat": pos.latitude,
        "lng": pos.longitude,
      });
    });
  }

  void stop() {
    _locationSub?.cancel();
    _ws.disconnect();
  }
}
