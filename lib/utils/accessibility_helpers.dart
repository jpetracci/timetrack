import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessible button wrapper that provides consistent semantics
/// 
/// This widget ensures all buttons have proper semantic labels,
/// hints, and button properties for screen readers.
class AccessibleButton extends StatelessWidget {
  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.hint,
    this.child,
    this.icon,
    this.style,
  });

  final VoidCallback? onPressed;
  final String label;
  final String? hint;
  final Widget? child;
  final Widget? icon;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      hint: hint,
      enabled: onPressed != null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            if (child != null) child! else Text(label),
          ],
        ),
      ),
    );
  }
}

/// Accessible list tile wrapper with proper semantic labels
/// 
/// Provides consistent accessibility for list items with titles,
/// subtitles, and actions.
class AccessibleListTile extends StatelessWidget {
  const AccessibleListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.semanticHint,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? semanticHint;

  @override
  Widget build(BuildContext context) {
    // Build the semantic description for screen readers
    String semanticDescription = semanticLabel ?? title;
    if (subtitle != null) {
      semanticDescription += ', $subtitle';
    }
    if (semanticHint != null) {
      semanticDescription += '. $semanticHint';
    }

    return Semantics(
      button: onTap != null,
      label: semanticDescription,
      hint: semanticHint ?? (onTap != null ? 'Tap to view details' : null),
      child: ListTile(
        leading: leading,
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

/// Accessible icon button with proper semantics
class AccessibleIconButton extends StatelessWidget {
  const AccessibleIconButton({
    super.key,
    required this.onPressed,
    required this.semanticLabel,
    required this.icon,
    this.tooltip,
    this.size = 24.0,
  });

  final VoidCallback? onPressed;
  final String semanticLabel;
  final Widget icon;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      hint: tooltip,
      enabled: onPressed != null,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        tooltip: tooltip,
        iconSize: size,
      ),
    );
  }
}

/// Accessibility utilities for common patterns
class AccessibilityHelpers {
  /// Creates semantic labels for time entries
  static String timeEntryLabel(String projectName, String duration, bool isRunning) {
    if (isRunning) {
      return 'Time entry: $projectName, currently running, $duration';
    } else {
      return 'Time entry: $projectName, $duration';
    }
  }

  /// Creates semantic hints for time entry actions
  static String timeEntryActionHint(String action, String projectName) {
    switch (action.toLowerCase()) {
      case 'edit':
        return 'Edit duration for $projectName';
      case 'delete':
        return 'Delete time entry for $projectName';
      case 'stop':
        return 'Stop timer for $projectName';
      case 'start':
        return 'Start timer for $projectName';
      default:
        return '$action for $projectName';
    }
  }

  /// Creates semantic labels for project information
  static String projectInfoLabel(String projectName, List<String> tags, bool isArchived) {
    String label = 'Project: $projectName';
    if (tags.isNotEmpty) {
      label += ', tags: ${tags.join(', ')}';
    }
    if (isArchived) {
      label += ', status: archived';
    } else {
      label += ', status: active';
    }
    return label;
  }

  /// Creates semantic labels for reports
  static String reportLabel(String reportType, String dateRange, int totalProjects) {
    return '$reportType report for $dateRange, showing $totalProjects projects';
  }

  /// Creates accessible hint for navigation
  static String navigationHint(String destination) {
    return 'Navigate to $destination';
  }

  /// Wraps a widget with appropriate focus management
  static Widget withFocusManagement({
    required Widget child,
    bool autofocus = false,
    FocusNode? focusNode,
    ValueChanged<bool>? onFocusChange,
  }) {
    return Focus(
      autofocus: autofocus,
      focusNode: focusNode,
      onFocusChange: onFocusChange,
      child: child,
    );
  }

  /// Creates semantic properties for form fields
  static SemanticsProperties formFieldSemantics({
    required String label,
    String? hint,
    required bool isRequired,
    required bool isEditable,
  }) {
    return SemanticsProperties(
      label: label,
      hint: hint,
      enabled: isEditable,
      textField: true,
      readOnly: !isEditable,
    );
  }

  /// Creates announcements for screen reader users
  static void announceToScreenReader(BuildContext context, String message) {
    // This would typically use the Semantics service for announcements
    // For now, we'll create a simple implementation
    // The correct API may vary by Flutter version
    debugPrint('Screen reader announcement: $message');
    // Note: Full implementation would use platform-specific APIs
  }

  /// Checks if accessibility features are enabled
  static bool isAccessibilityEnabled(BuildContext context) {
    // Check for common accessibility settings
    final mediaQueryData = MediaQuery.of(context);
    return mediaQueryData.accessibleNavigation || 
           mediaQueryData.disableAnimations ||
           mediaQueryData.invertColors ||
           mediaQueryData.highContrast;
  }

  /// Adjusts UI based on accessibility settings
  static BoxConstraints adjustForAccessibility(BoxConstraints constraints) {
    // Reduce complexity for accessibility mode if needed
    return constraints;
  }
}

/// Custom semantic widget for complex data displays
class AccessibleDataCard extends StatelessWidget {
  const AccessibleDataCard({
    super.key,
    required this.title,
    required this.data,
    this.onTap,
    this.actions = const [],
  });

  final String title;
  final Map<String, String> data;
  final VoidCallback? onTap;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    // Build semantic description for screen readers
    String semanticDescription = title;
    data.forEach((key, value) {
      semanticDescription += ', $key: $value';
    });

    return Semantics(
      button: onTap != null,
      label: semanticDescription,
      hint: onTap != null ? 'Tap to view details' : null,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (actions.isNotEmpty) ...actions,
                  ],
                ),
                const SizedBox(height: 8),
                ...data.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          '${entry.key}:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}