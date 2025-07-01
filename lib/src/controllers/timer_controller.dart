import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:flutter_task_time_tracker/flutter_task_time_tracker.dart';
import '../handlers/notification_handler.dart';
import '../utils/const.dart';

class TimerController with WidgetsBindingObserver {
  static final TimerController _instance = TimerController._internal();
  final NotificationHandler _notificationHandler = NotificationHandler();
  DateTime? _lastLogTime;
  bool _showNotification = true;

  bool get notificationStatus => _showNotification;

  factory TimerController({
    void Function(TimerData timerData)? onStarted,
    void Function(TimerData timerData)? onPaused,
    void Function(TimerData timerData)? onResumed,
    void Function(TimerData timerData)? onStopped,
  }) {
    _instance._onStarted ??= onStarted;
    _instance._onPaused ??= onPaused;
    _instance._onResumed ??= onResumed;
    _instance._onStopped ??= onStopped;
    WidgetsBinding.instance.addObserver(_instance);
    return _instance;
  }

  TimerController._internal();

  void Function(TimerData timerData)? _onStarted;
  void Function(TimerData timerData)? _onPaused;
  void Function(TimerData timerData)? _onResumed;
  void Function(TimerData timerData)? _onStopped;

  Timer? _timer;
  TimerData? _timerData;
  int _secondsElapsed = 0;

  StreamController<TimerData?>? _timerStreamController;

  Stream<TimerData?>? get timerStream => _timerStreamController?.stream;

  TimerData? get timerData => _timerData;

  DateTime? _appPausedAt;
  DateTime? _appResumedAt;
  bool _enableLazypause = true;

  Future<void> initTimer({
    required String taskName,
    required String taskId,
    DateTime? startedAt,
    DateTime? pausedAt,
    DateTime? stoppedAt,
    DateTime? resumedAt,
    int totalTimeInSeconds = 0,
    TimerStatus timerStatus = TimerStatus.stopped,
    Map<String, dynamic>? metaData,
  }) async {
    _timerData = TimerData(
      startedAt: startedAt,
      pausedAt: pausedAt,
      resumedAt: resumedAt,
      taskName: taskName,
      stoppedAt: stoppedAt,
      taskId: taskId,
      totalTimeInSeconds: totalTimeInSeconds,
      timerStatus: timerStatus,
      metaData: metaData,
    );
    _initStreamController();
    _secondsElapsed = totalTimeInSeconds;
    await _save();
    _emit();
    log("🕒 Timer initialized for task: $taskName [$taskId]");
  }

  bool enableNotification() {
    _showNotification = true;
    return _showNotification;
  }

  bool disableNotification() {
    _showNotification = false;
    return _showNotification;
  }

  void _initStreamController() {
    if (_timerStreamController == null || _timerStreamController!.isClosed) {
      _timerStreamController = StreamController<TimerData?>.broadcast();
    }
  }

  void startTimer() {
    if (_timerData == null) return;

    _timerData = _timerData!.copyWith(
      startedAt: DateTime.now(),
      timerStatus: TimerStatus.started,
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _secondsElapsed++;
      _timerData = _timerData!.copyWith(totalTimeInSeconds: _secondsElapsed);
      _emit();
      _save();
    });
    if (_showNotification) {
      _notificationHandler.showNotification(timerData!);
    }

    _onStarted?.call(timerData!);
    _emit();
    _save();
    log("▶️ Timer started: ${_timerData!.taskName}");
  }

  void pauseTimer() {
    if (_timer == null || _timerData == null) return;

    _timer?.cancel();
    _timerData = _timerData!.copyWith(
      pausedAt: DateTime.now(),
      timerStatus: TimerStatus.paused,
    );
    if (_showNotification) {
      _notificationHandler.showNotification(timerData!);
    }

    _onPaused?.call(timerData!);
    _emit();
    _save();
    log("⏸️ Timer paused: ${_timerData!.taskName}");
  }

  void resumeTimer({bool forceResume = false}) {
    if (_timerData == null ||
        (_timerData!.timerStatus != TimerStatus.paused && !forceResume)) {
      return;
    }

    _timerData = _timerData!.copyWith(
      resumedAt: DateTime.now(),
      timerStatus: TimerStatus.resumed,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _secondsElapsed++;
      _timerData = _timerData!.copyWith(totalTimeInSeconds: _secondsElapsed);
      _emit();
      _save();
    });
    if (_showNotification) {
      _notificationHandler.showNotification(timerData!);
    }

    _onResumed?.call(timerData!);
    _emit();
    _save();
    log("⏯️ Timer resumed: ${_timerData!.taskName}");
  }

  void stopTimer() {
    _timer?.cancel();
    if (_timerData != null) {
      _timerData = _timerData!.copyWith(
        timerStatus: TimerStatus.stopped,
        stoppedAt: DateTime.now(),
      );
    }
    if (_showNotification) {
      _notificationHandler.showNotification(timerData!);
    }

    _onStopped?.call(timerData!);
    _emit();
    _save();
    log("⏹️ Timer stopped: ${_timerData!.taskName}");
  }

  void resetTimer() {
    _timer?.cancel();
    if (_timerData != null) {
      _timerData = _timerData!.copyWith(
        totalTimeInSeconds: 0,
        timerStatus: TimerStatus.stopped,
        startedAt: DateTime.now(),
        stoppedAt: null,
        resumedAt: null,
        pausedAt: null,
      );
    }
    _secondsElapsed = 0;
    _emit();
    _save();
    log("🔁 Timer reset: ${_timerData?.taskName}");
  }

  Future<void> _save() async {
    _timerData = _timerData!.copyWith(lastUpdateAt: DateTime.now());
    final box = Hive.box<TimerData>(Const.boxName);
    await box.put(Const.currentKey, _timerData!);

    // show the log every 10 seconds
    final now = DateTime.now();
    if (_lastLogTime == null ||
        now.difference(_lastLogTime!) >= const Duration(seconds: 10)) {
      log("💾 Timer data saved for task: ${_timerData?.taskName}");
      _lastLogTime = now;
    }
  }

  Future<void> loadLastTimer({
    bool addSecondsWhenTerminatedState = false,
    bool autoStart = false,
  }) async {
    final box = Hive.box<TimerData>(Const.boxName);
    _timerData = box.get(Const.currentKey);

    if (_timerData == null) return;

    _secondsElapsed = _timerData!.totalTimeInSeconds;

    _initStreamController();

    if (addSecondsWhenTerminatedState &&
        timerData?.lastUpdateAt != null &&
        (_timerData!.timerStatus == TimerStatus.started ||
            _timerData!.timerStatus == TimerStatus.resumed)) {
      final DateTime lastActiveTime = _timerData!.lastUpdateAt!;
      final int missedSeconds =
          DateTime.now().difference(lastActiveTime).inSeconds;

      _secondsElapsed += missedSeconds;
      _timerData = _timerData!.copyWith(totalTimeInSeconds: _secondsElapsed);
      await _save();
      log("⏱️ Added $missedSeconds seconds due to terminated state recovery.");
    }

    if (autoStart && _timerData!.timerStatus == TimerStatus.resumed ||
        _timerData!.timerStatus == TimerStatus.started) {
      resumeTimer(forceResume: true);
    }

    _emit();
    log("📦 Last timer loaded for task: ${_timerData?.taskName}");
  }

  void disableLazyPause() {
    _enableLazypause = false;
  }

  void enableLazyPause() {
    _enableLazypause = true;
  }

  Future<void> _loadMinimisedTime() async {
    if (_timerData?.timerStatus == TimerStatus.started ||
        _timerData?.timerStatus == TimerStatus.resumed ||
        _enableLazypause) {
      int sec = _appResumedAt!.difference(_appPausedAt!).inSeconds;
      _secondsElapsed += sec;
      _appPausedAt = null;
      _appResumedAt = null;
      _lazyResume();
    }
  }

  _lazyPause() {
    if (_timer == null || _timerData == null || !_enableLazypause) return;
    //
    _timer?.cancel();
    _timerData = _timerData!.copyWith(
      pausedAt: DateTime.now(),
      timerStatus: TimerStatus.paused,
    );
    _save();
    log("⏸️ Timer lazy paused: ${_timerData!.taskName}");
  }

  _lazyResume() {
    if (_timerData == null || (_timerData!.timerStatus != TimerStatus.paused)) {
      return;
    }

    _timerData = _timerData!.copyWith(
      resumedAt: DateTime.now(),
      timerStatus: TimerStatus.resumed,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _secondsElapsed++;
      _timerData = _timerData!.copyWith(totalTimeInSeconds: _secondsElapsed);
      _emit();
      _save();
    });
    _onResumed?.call(timerData!);
    _emit();
    _save();
    log("⏯️ Timer lazy resumed: ${_timerData!.taskName}");
  }

  Future<List<TimerData>> getAllTimers() async {
    final box = Hive.box<TimerData>(Const.boxName);
    return box.values.toList();
  }

  TimerData? getCurrentTimer() {
    final box = Hive.box<TimerData>(Const.boxName);
    return box.get(Const.currentKey);
  }

  Future<void> deleteCurrentTimer() async {
    final box = Hive.box<TimerData>(Const.boxName);
    await box.delete(Const.currentKey);
    _timer?.cancel();
    _timerData = null;
    _secondsElapsed = 0;
    _emit();
    log("🗑️ Timer deleted.");
  }

  String getFormattedTime() {
    final duration = Duration(seconds: _secondsElapsed);
    return duration.toString().split('.').first.padLeft(8, "0");
  }

  void _emit() {
    if (_timerStreamController != null && !_timerStreamController!.isClosed) {
      _timerStreamController!.add(_timerData);
    } else {
      log("⚠️ Attempted to emit after stream was closed.");
    }
  }

  Future<void> dispose() async {
    await deleteCurrentTimer();
    _timer?.cancel();
    if (_timerStreamController != null && !_timerStreamController!.isClosed) {
      _timerStreamController!.close();
    }
    log("🧹 TimerController disposed.");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (_appResumedAt != null && _appPausedAt != null && timerData != null) {
      _loadMinimisedTime();
    }
    switch (state) {
      case AppLifecycleState.resumed:
        if (_appPausedAt != null) {
          _appResumedAt ??= DateTime.now();
        }
        return;
      case AppLifecycleState.inactive:
        return;
      case AppLifecycleState.paused:
        if (_appPausedAt == null && timerData != null) {
          _lazyPause();
          _appPausedAt = DateTime.now();
        }

        return;
      case AppLifecycleState.detached:
        _appPausedAt = null;
        _appResumedAt = null;
        return;
      case AppLifecycleState.hidden:
        return;
    }
  }
}
