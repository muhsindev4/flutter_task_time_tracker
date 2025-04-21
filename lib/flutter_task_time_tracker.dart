export 'package:flutter_task_time_tracker/src/data/enum/timer_status.dart';
export 'package:flutter_task_time_tracker/src/data/models/timer_data.dart';
export 'package:flutter_task_time_tracker/src/controllers/timer_controller.dart';
export 'package:flutter_task_time_tracker/src/widgets/task_picker.dart';
import 'package:flutter_task_time_tracker/src/controllers/timer_controller_with_lifecycle.dart';
import 'package:flutter_task_time_tracker/src/handlers/notification_handler.dart';
import 'package:flutter_task_time_tracker/src/utils/const.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'flutter_task_time_tracker.dart';

class FlutterTaskTimeTracker {
  static final FlutterTaskTimeTracker _instance =
      FlutterTaskTimeTracker._internal();

  factory FlutterTaskTimeTracker() => _instance;

  FlutterTaskTimeTracker._internal();

  void Function(TimerData timerData)? _onStarted;
  void Function(TimerData timerData)? _onPaused;
  void Function(TimerData timerData)? _onResumed;
  void Function(TimerData timerData)? _onStopped;
  bool addSecondsWhenTerminatedState = false;
  bool autoStart = false;

  late final TimerController _timerController;
  TimerController get timer => _timerController;
  final NotificationHandler _notificationHandler = NotificationHandler();

  /// Initialize Hive + Awesome Notifications
  Future<void> _initStorage() async {
    // Init Hive
    await Hive.initFlutter();

    Hive.registerAdapter(TimerDataAdapter());
    Hive.registerAdapter(TimerStatusAdapter());
    if (!Hive.isBoxOpen(Const.boxName)) {
      await Hive.openBox<TimerData>(Const.boxName);
    }

    _timerController = TimerController(
      onStarted: _onStarted,
      onPaused: _onPaused,
      onResumed: _onResumed,
      onStopped: _onStopped,
    );
  }

  Future<void> init({
    bool addSecondsWhenTerminatedState = true,
    bool autoStart = true,
  }) async {
    await _initStorage();

    await _notificationHandler.initNotification();

    await _timerController.loadLastTimer(
      addSecondsWhenTerminatedState: addSecondsWhenTerminatedState,
      autoStart: autoStart,
    );

    TimerControllerWithLifecycle().initObserver();
  }
}
