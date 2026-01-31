import 'dart:math' as math;

String formatDecimalHours(Duration duration, int precision) {
  final int safePrecision = precision.clamp(1, 4).toInt();
  final double hours = duration.inSeconds / 3600;
  final double factor = math.pow(10, safePrecision).toDouble();
  final double rounded = (hours * factor).round() / factor;
  return '${rounded.toStringAsFixed(safePrecision)}h';
}
