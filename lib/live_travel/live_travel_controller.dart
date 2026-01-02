import 'package:flutter/material.dart';
import 'package:travelr/live_travel/live_travel_model.dart';
import 'package:travelr/live_travel/live_travel_service.dart';

class LiveTravelController extends ChangeNotifier {
  final LiveTravelService _service = LiveTravelService();

  LiveTravelSession? get session => _service.sessionNotifier.value;

  LiveTravelController() {
    _service.sessionNotifier.addListener(notifyListeners);
  }

  void start({
    required String roomId,
    required String userId,
    required LiveTravelSession initialSession,
  }) {
    _service.startSession(
      roomId: roomId,
      userId: userId,
      initialSession: initialSession,
    );
  }

  void stop() {
    _service.stopSession();
  }

  @override
  void dispose() {
    _service.sessionNotifier.removeListener(notifyListeners);
    super.dispose();
  }
}
