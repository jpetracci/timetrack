import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_models.dart';
import 'reporting_state.dart';

class ReportingController extends Notifier<ReportingState> {
  @override
  ReportingState build() {
    return ReportingState.initial();
  }

  /// Normalize a DateTime to midnight (00:00:00) of same day in local time
  DateTime _normalizeDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  /// Normalize date range to midnight boundaries
  DateRange _normalizeRange(DateRange range) {
    return DateRange(
      start: _normalizeDay(range.start),
      end: _normalizeDay(range.end),
    );
  }

  void setView(ReportView view) {
    state = state.copyWith(view: view);
  }

  void setRange(DateRange range) {
    state = state.copyWith(range: _normalizeRange(range));
  }

  void setToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    state = state.copyWith(
      range: DateRange(start: today, end: today),
    );
  }

  void setThisWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    
    state = state.copyWith(
      range: DateRange(start: monday, end: sunday),
    );
  }
}

final reportingControllerProvider =
    NotifierProvider<ReportingController, ReportingState>(
  ReportingController.new,
);