import 'package:flutter/foundation.dart';

@immutable
class WeeklyTrainingProps {
  const WeeklyTrainingProps({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.dayLabel,
    this.duration,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imagePath;
  final String? dayLabel;
  final String? duration;
  final bool isCompleted;

  static const Object _unset = Object();

  WeeklyTrainingProps copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imagePath,
    Object? dayLabel = _unset,
    Object? duration = _unset,
    bool? isCompleted,
  }) => WeeklyTrainingProps(
    id: id ?? this.id,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    imagePath: imagePath ?? this.imagePath,
    dayLabel: identical(dayLabel, _unset) ? this.dayLabel : dayLabel as String?,
    duration: identical(duration, _unset) ? this.duration : duration as String?,
    isCompleted: isCompleted ?? this.isCompleted,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeeklyTrainingProps &&
        other.id == id &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.imagePath == imagePath &&
        other.dayLabel == dayLabel &&
        other.duration == duration &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    subtitle,
    imagePath,
    dayLabel,
    duration,
    isCompleted,
  );

  @override
  String toString() {
    return 'WeeklyTrainingProps('
        'id: $id, '
        'title: $title, '
        'subtitle: $subtitle, '
        'imagePath: $imagePath, '
        'dayLabel: $dayLabel, '
        'duration: $duration, '
        'isCompleted: $isCompleted'
        ')';
  }
}
