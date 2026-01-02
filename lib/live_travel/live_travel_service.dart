import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travelr/live_travel/location_service.dart';
import 'package:travelr/live_travel/websocket_service.dart';
import 'package:travelr/live_travel/live_travel_model.dart';

class LiveTravelService {
  // Singleton
  static final LiveTravelService _instance = LiveTravelService._();
  factory LiveTravelService() => _instance;
  LiveTravelService._();

  final WebSocketService _ws = WebSocketService();
  LiveTravelSession? _session;
  Position? _selfLocation;
  StreamSubscription<Position>? _locationSub;
  StreamSubscription? _wsSub;
  Timer? _heartbeatTimer;
  bool _connected = false;
  int _retryAttempt = 0;
  String? _roomId, _userId;
  final ValueNotifier<LiveTravelSession?> sessionNotifier = ValueNotifier(null);

  // Ping Pong Logic
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();

    _heartbeatTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _ws.send({"type": "ping", "ts": DateTime.now().toIso8601String()});
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  // Starting Point
  void startSession({
    required String roomId,
    required String userId,
    required LiveTravelSession initialSession,
  }) async {
    if (_connected) return;

    _connected = true;
    _session = initialSession;
    sessionNotifier.value = _session;
    _roomId = roomId;
    _userId = userId;

    _connectSocket(roomId, userId);
    _startLocationUpdates();
  }

  // Stopping Logic
  void stopSession() {
    _stopHeartbeat();
    _connected = false;
    _locationSub?.cancel();
    _wsSub?.cancel();
    _ws.disconnect();
    sessionNotifier.value = null;
  }

  // Socket Logic
  void _connectSocket(String roomId, String userId) {
    _ws.connect(roomId, userId);
    _startHeartbeat();

    _wsSub = _ws.stream.listen(
      _onSocketMessage,
      onDone: _onSocketClosed,
      onError: (_) => _onSocketClosed(),
    );
  }

  void _onSocketClosed() {
    _stopHeartbeat();

    if (!_connected) return;

    final delaySeconds = (1 << _retryAttempt).clamp(1, 30);

    Future.delayed(Duration(seconds: delaySeconds), () {
      if (_connected) {
        _retryAttempt++;
        _connectSocket(_roomId!, _userId!);
      }
    });
  }

  void _onSocketConnected() {
    _retryAttempt = 0; // reset on success
  }

  void _onSocketMessage(dynamic msg) {
    final parsed = jsonDecode(msg as String);
    final type = parsed["type"];

    if (type == "connected") {
      _onSocketConnected();
      return;
    }

    if (type == "pong") {
      return;
    }

    final locationUpdate = parsed["locationUpdate"];
    if (locationUpdate == null || _session == null) return;

    _applyParticipantLocation(
      userId: locationUpdate["userId"],
      lat: locationUpdate["lat"],
      lon: locationUpdate["lon"],
      updatedAt: parsed["updatedAt"],
    );
  }

  // Location Update Sender
  void _startLocationUpdates() async {
    _selfLocation = await LocationService.getCurrentLocation();

    _locationSub =
        LocationService.getLocationStream(distanceFilter: 1).listen((pos) {
      _selfLocation = pos;

      _ws.send({
        "lat": pos.latitude,
        "lng": pos.longitude,
      });
    });
  }

  // Session Updater
  void _applyParticipantLocation({
    required String userId,
    required double lat,
    required double lon,
    required String updatedAt,
  }) {
    if (_session == null) return;
    print("Some shit was updated");

    final updatedParticipants = _session!.participants.map((p) {
      if (p.userId != userId) return p;
      return p.copyWith(
        currentLocation:
            "Lat ${lat.toStringAsFixed(4)}, Lon ${lon.toStringAsFixed(4)}",
      );
    }).toList();

    _session = _session!.copyWith(
      participants: updatedParticipants,
      updatedAt: DateTime.parse(updatedAt),
    );

    sessionNotifier.value = _session;
    print("Update Successful");
  }
}
