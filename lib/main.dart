import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/projects_state.dart';
import 'state/timer_controller.dart';
import 'ui/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ProviderContainer container = ProviderContainer();

  await container.read(projectsControllerProvider.notifier).loadProjects();
  await container.read(timerControllerProvider.notifier).hydrate();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TimeTrackApp(),
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
