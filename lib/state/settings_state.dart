class SettingsState {
  static const int minPrecision = 1;
  static const int maxPrecision = 4;

  const SettingsState({
    required this.precision,
  });

  final int precision;

  factory SettingsState.initial() {
    return const SettingsState(precision: 2);
  }

  static int clampPrecision(int value) {
    return value.clamp(minPrecision, maxPrecision).toInt();
  }

  SettingsState copyWith({
    int? precision,
  }) {
    return SettingsState(
      precision: clampPrecision(precision ?? this.precision),
    );
  }
}
