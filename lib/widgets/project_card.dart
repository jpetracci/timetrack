import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../models/project.dart';
import '../state/settings_controller.dart';
import '../utils/decimal_time.dart';
import '../utils/platform_detector.dart';
import '../utils/accessibility_helpers.dart';
import '../widgets/touch_optimized_button.dart';
import '../widgets/hover_wrapper.dart';

class ProjectCard extends ConsumerWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.isActive,
    required this.isRunning,
    required this.elapsed,
    required this.onTap,
    required this.onDetailsTap,
  });

  final Project project;
  final bool isActive;
  final bool isRunning;
  final Duration elapsed;
  final VoidCallback onTap;
  final VoidCallback onDetailsTap;

  static final Map<String, FocusNode> _focusNodes = {};
  
  FocusNode _getFocusNode() {
    return _focusNodes.putIfAbsent(project.id, () => FocusNode(debugLabel: 'ProjectCard_${project.name}'));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int precision = ref.watch(
      settingsControllerProvider.select((state) => state.precision),
    );
    final ColorScheme colors = Theme.of(context).colorScheme;
    const Duration animationDuration = Duration(milliseconds: 200);
    final bool isEmphasized = isActive || isRunning;
    final Color background =
        isEmphasized ? colors.primaryContainer : colors.surface;
    final Color borderColor =
        isEmphasized ? colors.primary : colors.outlineVariant;
    final BorderRadius borderRadius = BorderRadius.circular(12);
    final List<BoxShadow> shadows = isEmphasized
        ? <BoxShadow>[
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ]
        : const <BoxShadow>[];

    // Create semantic label for screen readers
    final String semanticLabel = AccessibilityHelpers.projectInfoLabel(
      project.name,
      project.tags,
      project.isArchived,
    );
    final String semanticHint = isRunning 
        ? 'Tap to stop timer for ${project.name}'
        : 'Tap to start timer for ${project.name}';
    final String semanticDescription = '$semanticLabel. Elapsed time: ${formatDecimalHours(elapsed, precision)}. $semanticHint';

    // Platform-adaptive card content with semantic wrapper and focus management
    Widget cardContent = Focus(
      focusNode: _getFocusNode(),
      autofocus: false,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        // Handle Enter and Space keys for card activation
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter || 
              event.logicalKey == LogicalKeyboardKey.space) {
            onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        button: true,
        label: semanticDescription,
        hint: semanticHint,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (project.tags.isEmpty)
                      Text(
                        'No tags',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: project.tags
                            .map(
                              (String tag) => Chip(
                                label: Text(tag),
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    formatDecimalHours(elapsed, precision),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: animationDuration,
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: Text(
                      isRunning ? 'Running' : 'Stopped',
                      key: ValueKey<bool>(isRunning),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isRunning
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Platform-adaptive details button with semantic properties
                  PlatformDetector.isTouchDevice
                      ? Semantics(
                          button: true,
                          label: 'View details for ${project.name}',
                          hint: 'Tap to see project details and time history',
                          child: TouchOptimizedIconButton(
                            onPressed: onDetailsTap,
                            icon: const Icon(Icons.info_outline),
                            tooltip: 'Details',
                            size: 20,
                          ),
                        )
                      : Semantics(
                          button: true,
                          label: 'View details for ${project.name}',
                          hint: 'Tap to see project details and time history',
                          child: HoverWrapper(
                            cursor: SystemMouseCursors.click,
                            hoverScale: 1.1,
                            child: IconButton(
                              onPressed: onDetailsTap,
                              icon: const Icon(Icons.info_outline),
                              tooltip: 'Details',
                              iconSize: 20,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Platform-specific wrapper with focus management
    final FocusNode cardFocusNode = _getFocusNode();
    
    return Focus(
      focusNode: cardFocusNode,
      canRequestFocus: !PlatformDetector.isTouchDevice, // Only allow focus on non-touch devices
      onKeyEvent: (FocusNode node, KeyEvent event) {
        // Handle keyboard navigation for the entire card
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter || 
              event.logicalKey == LogicalKeyboardKey.space) {
            onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Builder(
        builder: (context) {
          final bool isFocused = Focus.of(context).hasFocus;
          final Border focusBorder = Border.all(
            color: colors.primary,
            width: 2.0,
          );
          
          if (PlatformDetector.isTouchDevice) {
            return TouchOptimizedCard(
              onTap: onTap,
              margin: const EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.zero, // Padding is handled in cardContent
              borderRadius: borderRadius,
              child: AnimatedContainer(
                duration: animationDuration,
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: borderRadius,
                  border: isFocused ? focusBorder : Border.all(color: borderColor),
                  boxShadow: shadows,
                ),
                child: cardContent,
              ),
            );
          } else {
            return HoverCard(
              onTap: onTap,
              margin: const EdgeInsets.only(bottom: 12),
              borderRadius: borderRadius,
              hoverElevation: 8.0,
              hoverScale: 1.02,
              child: AnimatedContainer(
                duration: animationDuration,
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: borderRadius,
                  border: isFocused ? focusBorder : Border.all(color: borderColor),
                  boxShadow: isFocused ? <BoxShadow>[
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: cardContent,
              ),
            );
          }
        },
      ),
    );
  }
}
