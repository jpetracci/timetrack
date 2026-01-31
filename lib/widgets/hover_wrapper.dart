import 'package:flutter/material.dart';
import '../utils/platform_detector.dart';

/// A wrapper that provides hover states for pointer devices
class HoverWrapper extends StatefulWidget {
  const HoverWrapper({
    super.key,
    required this.child,
    this.builder,
    this.cursor = SystemMouseCursors.click,
    this.hoverColor,
    this.hoverScale = 1.0,
    this.duration = const Duration(milliseconds: 200),
    this.enabled = true,
  });

  final Widget child;
  final Widget Function(BuildContext context, bool isHovered, Widget child)? builder;
  final MouseCursor cursor;
  final Color? hoverColor;
  final double hoverScale;
  final Duration duration;
  final bool enabled;

  @override
  State<HoverWrapper> createState() => _HoverWrapperState();
}

class _HoverWrapperState extends State<HoverWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.hoverScale,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(HoverWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!PlatformDetector.isPointerDevice) {
      // Don't run hover animations on touch devices
      if (_animationController.isAnimating) {
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleHoverEnter(_) {
    if (!widget.enabled || !PlatformDetector.isPointerDevice) return;
    
    setState(() {
      _isHovered = true;
    });
    _animationController.forward();
  }

  void _handleHoverExit(_) {
    if (!widget.enabled || !PlatformDetector.isPointerDevice) return;
    
    setState(() {
      _isHovered = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Only apply hover effects on pointer devices
    if (!PlatformDetector.isPointerDevice) {
      return widget.child;
    }

    Widget hoverChild = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: widget.child,
    );

    // Apply custom builder if provided
    if (widget.builder != null) {
      hoverChild = widget.builder!(context, _isHovered, hoverChild);
    } else if (widget.hoverColor != null) {
      // Apply hover background color
      hoverChild = AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: _isHovered ? widget.hoverColor : Colors.transparent,
        ),
        child: hoverChild,
      );
    }

    return MouseRegion(
      cursor: widget.cursor,
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: hoverChild,
    );
  }
}

/// A convenient wrapper for buttons with hover effects
class HoverButton extends StatelessWidget {
  const HoverButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.hoverColor,
    this.hoverScale = 1.05,
    this.duration = const Duration(milliseconds: 200),
    this.cursor = SystemMouseCursors.click,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color? hoverColor;
  final double hoverScale;
  final Duration duration;
  final MouseCursor cursor;

  @override
  Widget build(BuildContext context) {
    return HoverWrapper(
      cursor: cursor,
      hoverColor: hoverColor,
      hoverScale: hoverScale,
      duration: duration,
      builder: (context, isHovered, child) {
        return AnimatedOpacity(
          duration: duration,
          opacity: onPressed == null ? 0.5 : (isHovered ? 0.9 : 1.0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: onPressed,
        child: child,
      ),
    );
  }
}

/// Hover wrapper specifically for cards
class HoverCard extends StatelessWidget {
  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.hoverElevation = 8.0,
    this.hoverScale = 1.02,
    this.borderRadius,
    this.margin,
    this.duration = const Duration(milliseconds: 200),
  });

  final Widget child;
  final VoidCallback? onTap;
  final double hoverElevation;
  final double hoverScale;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return HoverWrapper(
      hoverScale: hoverScale,
      duration: duration,
      builder: (context, isHovered, child) {
        return AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          margin: margin,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(12.0),
            boxShadow: [
              if (isHovered)
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Material(
            elevation: isHovered ? hoverElevation : 2.0,
            borderRadius: borderRadius ?? BorderRadius.circular(12.0),
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius ?? BorderRadius.circular(12.0),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}