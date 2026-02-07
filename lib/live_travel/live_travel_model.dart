import 'package:flutter/material.dart';
import 'package:travelr/database/profile_service.dart';

// Enums
enum TravelStatus {
  enRoute,
  arrived,
}

// Route stop (timeline node)

class RouteStop {
  final String placeName;
  final TimeOfDay eta;
  final String? mode;

  const RouteStop({
    required this.placeName,
    required this.eta,
    this.mode,
  });

  static RouteStop mock({
    required String place,
    required int hour,
    required int minute,
    required int index,
    bool meet = false,
    String? mode,
  }) {
    return RouteStop(
      placeName: place,
      eta: TimeOfDay(hour: hour, minute: minute),
      mode: mode,
    );
  }
}

// Participant (ETA row)

class TravelParticipant {
  final String userId;
  final String name;
  final String? avatarUrl;
  final String currentLocation;
  final TimeOfDay etaAtMeetPoint;
  final double progressPercent; //progress bar
  final TravelStatus status;
  final String? polyline;
  // Remaining route for THIS user only
  final List<RouteStop> remainingRoute;
  final TimeOfDay? updatedAt;

  const TravelParticipant({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.currentLocation,
    required this.etaAtMeetPoint,
    required this.progressPercent,
    required this.status,
    this.polyline,
    required this.remainingRoute,
    this.updatedAt,
  });

  // Remaining duration to meet point (derived from TimeOfDay)
  Duration get remainingDuration {
    final now = TimeOfDay.now();
    final etaMinutes = etaAtMeetPoint.hour * 60 + etaAtMeetPoint.minute;
    final nowMinutes = now.hour * 60 + now.minute;
    final diff = etaMinutes - nowMinutes;
    return Duration(minutes: diff < 0 ? 0 : diff);
  }

  String get etaLabel {
    final mins = remainingDuration.inMinutes;
    if (status == TravelStatus.arrived) return 'Arrived';
    return mins <= 1 ? 'ETA: 1 min' : 'ETA: $mins mins';
  }

  bool get hasArrived => status == TravelStatus.arrived;

  TravelParticipant copyWith(
      {String? currentLocation,
      TimeOfDay? etaAtMeetPoint,
      double? progressPercent,
      TravelStatus? status,
      List<RouteStop>? remainingRoute,
      String? polyline}) {
    return TravelParticipant(
      userId: userId,
      name: name,
      avatarUrl: avatarUrl,
      currentLocation: currentLocation ?? this.currentLocation,
      etaAtMeetPoint: etaAtMeetPoint ?? this.etaAtMeetPoint,
      progressPercent: progressPercent ?? this.progressPercent,
      status: status ?? this.status,
      polyline: polyline,
      remainingRoute: remainingRoute ?? this.remainingRoute,
      updatedAt: updatedAt,
    );
  }

  static TravelParticipant mock({
    required String id,
    required String name,
    required String location,
    required TimeOfDay etaAtMeetPoint,
    required double progress,
    List<RouteStop>? route,
  }) {
    final now = TimeOfDay.now();
    final etaMinutes = etaAtMeetPoint.hour * 60 + etaAtMeetPoint.minute;
    final nowMinutes = now.hour * 60 + now.minute;

    return TravelParticipant(
      userId: id,
      name: name,
      currentLocation: location,
      etaAtMeetPoint: etaAtMeetPoint,
      progressPercent: progress,
      status: etaMinutes <= nowMinutes
          ? TravelStatus.arrived
          : TravelStatus.enRoute,
      remainingRoute: route ?? const [],
    );
  }
}

//Live travel session (card)

class LiveTravelSession {
  final String sessionId;
  final String groupName;
  final String meetPoint;
  final List<TravelParticipant> participants;

  // Users currently travelling with the local user
  final List<String> currentlyTravellingWith;

  final DateTime updatedAt;

  const LiveTravelSession({
    required this.sessionId,
    required this.groupName,
    required this.meetPoint,
    required this.participants,
    required this.currentlyTravellingWith,
    required this.updatedAt,
  });

  TravelParticipant? participantFor(String userId) {
    try {
      return participants.firstWhere((p) => p.userId == userId);
    } catch (_) {
      return null;
    }
  }

  static LiveTravelSession mock() {
    return LiveTravelSession(
      sessionId: '1',
      groupName: 'Central Buddies',
      meetPoint: 'Ghatkopar Station',
      updatedAt: DateTime.now(),
      currentlyTravellingWith: ['u2'],
      participants: [
        TravelParticipant.mock(
          id: 'u1',
          name: 'Yash Ghogale',
          location: 'Vikhroli Station',
          etaAtMeetPoint: const TimeOfDay(hour: 7, minute: 20),
          progress: 0.85,
        ),
        TravelParticipant.mock(
          id: 'u2',
          name: 'Rhea Sanghvi',
          location: 'Mulund Station',
          etaAtMeetPoint: const TimeOfDay(hour: 18, minute: 18),
          progress: 0.65,
        ),
        TravelParticipant(
          userId: 'O434RH17tsQVd6l3yqalo6oFaJp2',
          name: 'Siddhant Patel',
          currentLocation: 'Mulund Station',
          etaAtMeetPoint: const TimeOfDay(hour: 7, minute: 15),
          progressPercent: 1.0,
          status: TravelStatus.arrived,
          remainingRoute: [
            RouteStop.mock(
              place: 'Silver Bell Society',
              hour: 7,
              minute: 0,
              index: 0,
            ),
            RouteStop.mock(
              place: 'Mulund Station',
              hour: 7,
              minute: 15,
              index: 1,
            ),
            RouteStop.mock(
              place: 'Ghatkopar Station',
              hour: 7,
              minute: 25,
              index: 2,
              meet: true,
            ),
            RouteStop.mock(
              place: 'Andheri Station',
              hour: 19,
              minute: 45,
              index: 3,
            ),
            RouteStop.mock(
              place: 'DJSCE',
              hour: 23,
              minute: 55,
              index: 4,
            ),
          ],
        ),
      ],
    );
  }

  static LiveTravelSession test(String sessionId, String groupName) {
    return LiveTravelSession(
      sessionId: sessionId,
      groupName: groupName,
      meetPoint: 'Godrej Gate 4',
      updatedAt: DateTime.now(),
      currentlyTravellingWith: [],
      participants: [
        TravelParticipant.mock(
          id: 'EPIXbABPOVdivtv2FLf5v5RyOrY2',
          name: 'Zeel Bhadra',
          location: 'D22 Godrej Colony',
          etaAtMeetPoint: const TimeOfDay(hour: 0, minute: 0),
          progress: 0.00,
        ),
        TravelParticipant.mock(
          id: 'n1a0EoJ7iJPAP0RhMBDjE8LQh9C3',
          name: 'Siddhant Patel',
          location: 'Vikhroli Station',
          etaAtMeetPoint: const TimeOfDay(hour: 0, minute: 0),
          progress: 0.00,
        ),
      ],
    );
  }

  LiveTravelSession updateWithUID(
      {required String userId,
      required TimeOfDay newEtaAtMeetPoint,
      required double newProgressPercent,
      DateTime? updatedAt,
      required String polyline}) {
    final now = TimeOfDay.now();
    final etaMinutes = newEtaAtMeetPoint.hour * 60 + newEtaAtMeetPoint.minute;
    final nowMinutes = now.hour * 60 + now.minute;

    final newStatus =
        etaMinutes <= nowMinutes ? TravelStatus.arrived : TravelStatus.enRoute;

    final updatedParticipants = participants.map((p) {
      if (p.userId != userId) return p;

      return p.copyWith(
          etaAtMeetPoint: newEtaAtMeetPoint,
          status: newStatus,
          progressPercent: newProgressPercent,
          polyline: polyline);
    }).toList();

    return LiveTravelSession(
      sessionId: sessionId,
      groupName: groupName,
      meetPoint: meetPoint,
      participants: updatedParticipants,
      currentlyTravellingWith: currentlyTravellingWith,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  static Future<LiveTravelSession> fromTripApi(
      Map<String, dynamic> json) async {
    final members =
        (json['members'] as List? ?? []).map((e) => e.toString()).toList();

    final timelinePayload = json['timeline'];
    final List<dynamic> events = timelinePayload is Map
        ? (timelinePayload['timeline'] as List? ?? [])
        : (timelinePayload as List? ?? []);

    String meetPoint = 'Meet point';
    for (final e in events) {
      if (e is Map && e['event'] == 'MEET') {
        final loc = e['location'];
        if (loc is Map && loc['lat'] != null && loc['lng'] != null) {
          meetPoint = '${loc['lat']}, ${loc['lng']}';
          break;
        }
      }
    }

    final profileFutures = members.map((uid) {
      return ProfilesDatabase.getProfilePartialFromUID(uid);
    }).toList();

    final profileResults = await Future.wait(profileFutures);
    final nameByUid = <String, String>{};
    for (final result in profileResults) {
      nameByUid.addAll(result);
    }

    final participants = members.map((uid) {
      return TravelParticipant.mock(
        id: uid,
        name: nameByUid[uid] ?? "Unknown",
        location: 'Unknown',
        etaAtMeetPoint: const TimeOfDay(hour: 0, minute: 0),
        progress: 0.0,
      );
    }).toList();

    final updatedAt = DateTime.tryParse(
          (json['updatedAt'] ?? '').toString(),
        ) ??
        DateTime.now();

    return LiveTravelSession(
      sessionId: (json['roomID'] ?? json['roomId'] ?? '').toString(),
      groupName: (json['groupName'] ?? '').toString(),
      meetPoint: meetPoint,
      participants: participants,
      currentlyTravellingWith: const [],
      updatedAt: updatedAt,
    );
  }
}
