import 'package:flutter/material.dart';

enum JourneyMode {
  private,
  public,
}

class Recommendation {
  final String uid;
  final String name;
  final String gender;
  final int age;
  final double overlapDist;
  final double overlapPercent;
  final String meetPoint;
  final String splitPoint;
  final List<RouteSegment>? segments;
  // Friend-only
  final String? phoneNumber;
  final TimeOfDay? etaAtMeetPoint;
  bool get canShowETA => true;

  Recommendation({
    required this.uid,
    required this.name,
    required this.gender,
    required this.age,
    required this.overlapDist,
    required this.overlapPercent,
    required this.meetPoint,
    required this.splitPoint,
    this.segments,
    this.phoneNumber,
    this.etaAtMeetPoint,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      uid: json['user_id'],
      name: json['name'],
      gender: json['gender'] ?? "XXXX",
      age: json['age'] ?? 20,
      overlapDist: json["overlap_distance_km"],
      overlapPercent: json["overlap_ratio"],
      meetPoint: (json['meet_point'] as List).join(", "),
      splitPoint: (json['split_point'] as List).join(", "),
      segments: json.containsKey("segments") && json["segments"] != null
          ? (json['segments'] as List)
              .map((e) => RouteSegment.fromJson(e))
              .toList()
          : null,
    );
  }
}

class RouteSegment {
  final String mode;
  final String from;
  final String to;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  RouteSegment({
    required this.mode,
    required this.from,
    required this.to,
    required this.startTime,
    required this.endTime,
  });

  factory RouteSegment.fromJson(Map<String, dynamic> json) {
    return RouteSegment(
      mode: json['mode'],
      from: json['from'],
      to: json['to'],
      startTime: _parseTime(json['start_time']),
      endTime: _parseTime(json['end_time']),
    );
  }

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
