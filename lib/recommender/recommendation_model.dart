// This is sample code of how it should be, but actual code will completely depend on the way the recommendations are given by the API.
// Keep this as it is for now. Will instruct later.

import 'package:flutter/material.dart';

class Recommendation {
  final String name;
  final String gender;
  final int age;
  final double overlapDist;
  final double overlapPercent;
  final String meetPoint;
  final String splitPoint;
  final List<RouteSegment> segments;

  Recommendation({
    required this.name,
    required this.gender,
    required this.age,
    required this.overlapDist,
    required this.overlapPercent,
    required this.meetPoint,
    required this.splitPoint,
    required this.segments,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      name: json['name'],
      gender: json['gender'],
      age: json['age'],
      overlapDist: json["overlap_dist"],
      overlapPercent: json["overlap_percent"],
      meetPoint: json['meet_point'],
      splitPoint: json['split_point'],
      segments: (json['segments'] as List)
          .map((e) => RouteSegment.fromJson(e))
          .toList(),
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
