String formatDecimalHours(Duration duration, int precision) {
  final int safePrecision = precision.clamp(0, 4).toInt();
  final double hours = duration.inSeconds / 3600;
  return hours.toStringAsFixed(safePrecision);
}
