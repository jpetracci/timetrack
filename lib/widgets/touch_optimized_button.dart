import 'package:flutter/material.dart';
import '../utils/platform_detector.dart';

/// A touch-optimized button that enforces minimum tap targets
class TouchOptimizedButton extends StatelessWidget {
  const TouchOptimizedButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.style,
    this.isPrimary = true,
  });

  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final ButtonStyle? style;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final double minSize = PlatformDetector.minimumTouchTarget;
    final bool isDisabled = onPressed == null;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: minSize,
        minWidth: minSize,
      ),
      child: isPrimary
          ? FilledButton.icon(
              onPressed: onPressed,
              icon: icon,
              label: Text(label),
              style: style,
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: icon,
              label: Text(label),
              style: style,
            ),
    );
  }
}

/// A touch-optimized icon button with proper tap target sizing
class TouchOptimizedIconButton extends StatelessWidget {
  const TouchOptimizedIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.size = 24.0,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final double minSize = PlatformDetector.minimumTouchTarget;
    final bool isDisabled = onPressed == null;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: minSize,
        minWidth: minSize,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        tooltip: tooltip,
        iconSize: size,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

/// A touch-optimized card with proper tap targets
class TouchOptimizedCard extends StatelessWidget {
  const TouchOptimizedCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.margin,
    this.padding,
    this.borderRadius,
    this.elevation = 2.0,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final double minSize = PlatformDetector.minimumTouchTarget;
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
      child: Material(
        color: Colors.transparent,
        elevation: elevation,
        borderRadius: borderRadius ?? BorderRadius.circular(12.0),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: borderRadius ?? BorderRadius.circular(12.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: onTap != null ? minSize : 0,
              minWidth: onTap != null ? minSize : 0,
            ),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(16.0),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}