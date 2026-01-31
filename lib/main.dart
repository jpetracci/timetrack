import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/projects_state.dart';
import 'state/timer_controller.dart';
import 'ui/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: TimeTrackApp(),
    ),
  );
}

class TimeTrackApp extends ConsumerStatefulWidget {
  const TimeTrackApp({super.key});

  @override
  ConsumerState<TimeTrackApp> createState() => _TimeTrackAppState();
}

class _TimeTrackAppState extends ConsumerState<TimeTrackApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future(() async {
        await ref.read(projectsControllerProvider.notifier).loadProjects();
        await ref.read(timerControllerProvider.notifier).hydrate();
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final TimerController controller =
        ref.read(timerControllerProvider.notifier);
    switch (state) {
      case AppLifecycleState.resumed:
        controller.handleAppResumed();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        controller.handleAppPaused();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TimeTrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
