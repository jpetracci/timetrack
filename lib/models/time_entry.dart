class TimeEntry {
  const TimeEntry({
    required this.id,
    required this.projectId,
    required this.start,
    this.end,
  });

  final String id;
  final String projectId;
  final DateTime start;
  final DateTime? end;

  bool get isRunning => end == null;

  Duration get duration {
    final DateTime effectiveEnd = end ?? DateTime.now();
    return effectiveEnd.difference(start);
  }

  double get durationHours {
    return duration.inMilliseconds / Duration.millisecondsPerHour;
  }

  TimeEntry copyWith({
    String? id,
    String? projectId,
    DateTime? start,
    DateTime? end,
  }) {
    return TimeEntry(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'start': start.toIso8601String(),
      'end': end?.toIso8601String(),
    };
  }

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      start: DateTime.parse(json['start'] as String),
      end: json['end'] == null
          ? null
          : DateTime.parse(json['end'] as String),
    );
  }
}
