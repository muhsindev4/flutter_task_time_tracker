import 'package:flutter/material.dart';

import '../../flutter_task_time_tracker.dart';

class TimerControllerWithLifecycle extends WidgetsBindingObserver {
  final FlutterTaskTimeTracker _taskTimeTracker = FlutterTaskTimeTracker();
  static final TimerControllerWithLifecycle _instance =
      TimerControllerWithLifecycle._internal();

  factory TimerControllerWithLifecycle() => _instance;

  TimerControllerWithLifecycle._internal();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App has come back from being minimized, trigger loadLastTimer
      // _taskTimeTracker.timer.loadLastTimer(
      //   addSecondsWhenTerminatedState: true,
      //   autoStart: true,
      // );
    }
  }

  /// Attach the observer to the app lifecycle
  void initObserver() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Detach the observer when not needed
  void disposeObserver() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
