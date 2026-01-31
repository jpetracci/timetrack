import 'package:flutter/foundation.dart';
import '../models/report_models.dart';

enum ReportView {
  daily,
  weekly;

  String get displayName {
    switch (this) {
      case ReportView.daily:
        return 'Daily';
      case ReportView.weekly:
        return 'Weekly';
    }
  }
}

@immutable
class ReportingState {
  const ReportingState({
    required this.view,
    required this.range,
  });

  final ReportView view;
  final DateRange range;

  factory ReportingState.initial() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Default to current week (Monday start)
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    
    return ReportingState(
      view: ReportView.daily,
      range: DateRange(start: monday, end: sunday),
    );
  }

  ReportingState copyWith({
    ReportView? view,
    DateRange? range,
  }) {
    return ReportingState(
      view: view ?? this.view,
      range: range ?? this.range,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportingState &&
        other.view == view &&
        other.range == range;
  }

  @override
  int get hashCode => Object.hash(view, range);

  @override
  String toString() {
    return 'ReportingState(view: $view, range: $range)';
  }
}