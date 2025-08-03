import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:flutter_task_time_tracker/flutter_task_time_tracker.dart';
import 'package:workmanager/workmanager.dart';
import '../handlers/notification_handler.dart';
import '../utils/const.dart';

class TimerController with WidgetsBindingObserver {
  static final TimerController _instance = TimerController._internal();
  final NotificationHandler _notificationHandler = NotificationHandler();
  DateTime? _lastLogTime;


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

  bool _isLazyPause = false;

  void Function(TimerData data)? _onInitListener;

  void onInitListener(void Function(TimerData data)? callback) {
    _onInitListener = callback;
  }

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
    print("🕒 Timer initialized for task: $taskName [$taskId]");

    // 👇 Trigger onInitListener if set
    if (_onInitListener != null) {
      _onInitListener!(_timerData!);
    }
    print("🕒 Timer initialized for task: $taskName [$taskId]");
  }


  void _initStreamController() {
    if (_timerStreamController == null || _timerStreamController!.isClosed) {
      _timerStreamController = StreamController<TimerData?>.broadcast();
    }
  }

  void startTimer({bool showNotification=true}) {
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
    if (showNotification) {
      _notificationHandler.showNotification(timerData!);
    }

    _onStarted?.call(timerData!);
    _emit();
    _save();
    print("▶️ Timer started: ${_timerData!.taskName}");
  }

  void pauseTimer({bool showNotification=true}) {
    if (_timerData == null) return;

    _timer?.cancel();
    _timerData = _timerData!.copyWith(
      pausedAt: DateTime.now(),
      timerStatus: TimerStatus.paused,
    );
    if (showNotification) {
      _notificationHandler.showNotification(timerData!);
    }

    _onPaused?.call(timerData!);
    _emit();
    _save();
    print("⏸️ Timer paused: ${_timerData!.taskName}");
  }

  void resumeTimer({bool forceResume = false,bool showNotification=true}) {
    print("TAG:TimerController:_timerData!.timerStatus != TimerStatus.paused==${_timerData!.timerStatus != TimerStatus.paused}");
    print("TAG:TimerController:!forceResume==${!forceResume}");
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
      print("Timer resumed:  --${_secondsElapsed}");
      _timerData = _timerData!.copyWith(totalTimeInSeconds: _secondsElapsed);
      _emit();
      _save();
    });
    if (showNotification) {
      _notificationHandler.showNotification(timerData!);
    }

    _onResumed?.call(timerData!);
    _emit();
    _save();
    print("⏯️ Timer resumed: ${_timerData!.taskName}");
  }

  void stopTimer({bool showNotification=true}) {
    _timer?.cancel();
    if (_timerData != null) {
      _timerData = _timerData!.copyWith(
        timerStatus: TimerStatus.stopped,
        stoppedAt: DateTime.now(),
      );
    }
    if (showNotification) {
      _notificationHandler.showNotification(timerData!);
    }

    _onStopped?.call(timerData!);
    _emit();
    _save();
    print("⏹️ Timer stopped: ${_timerData!.taskName}");
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
    print("🔁 Timer reset: ${_timerData?.taskName}");
  }

  Future<void> _save() async {
    _timerData = _timerData!.copyWith(lastUpdateAt: DateTime.now());
    final box = Hive.box<TimerData>(Const.boxName);
    await box.put(Const.currentKey, _timerData!);

    // show the log every 10 seconds
    final now = DateTime.now();
    if (_lastLogTime == null ||
        now.difference(_lastLogTime!) >= const Duration(seconds: 10)) {
      print("💾 Timer data saved for task: ${_timerData?.taskName}");
      _lastLogTime = now;
    }
  }

  Future<void> loadLastTimer({
    bool addSecondsWhenTerminatedState = false,
    bool autoStart = false,
  }) async {
    final box = Hive.box<TimerData>(Const.boxName);
    _timerData = box.get(Const.currentKey);

    print("TAG:TimerController:${_timerData==null}");
    if (_timerData == null) return;
    print("wasTerminatedDuringTimer==${_timerData?.wasTerminatedDuringTimer}");
    _secondsElapsed = _timerData!.totalTimeInSeconds;

    _initStreamController();

    if (addSecondsWhenTerminatedState &&
        timerData?.lastUpdateAt != null &&
        // (_timerData!.timerStatus == TimerStatus.started ||
        //     _timerData!.timerStatus == TimerStatus.resumed)
        _timerData?.wasTerminatedDuringTimer==true
    ) {
      final DateTime lastActiveTime = _timerData!.lastUpdateAt!;
      final int missedSeconds = DateTime.now().difference(lastActiveTime).inSeconds;

      _secondsElapsed += missedSeconds;
      _timerData = _timerData!.copyWith(totalTimeInSeconds: _secondsElapsed);
      await _save();
      print("⏱️ Added $missedSeconds seconds due to terminated state recovery.");
    }
    print("TAG:TimerController:totalTimeInSeconds==${_timerData?.totalTimeInSeconds}");
    print("TAG:TimerController:autoStart==${autoStart}");
    print("TAG:TimerController:TimerStatus==${_timerData!.timerStatus == TimerStatus.resumed}");



    if (autoStart &&_timerData?.wasTerminatedDuringTimer==true) {
      print("📦 resumeTimer: ${_timerData?.taskName}");
      resumeTimer(forceResume: true);
    }
    _timerData=_timerData?.copyWith(wasTerminatedDuringTimer: false);
    _save();
    _emit();
    print("📦 Last timer loaded for task: ${_timerData?.taskName}");
  }


  Future<void> _loadMinimisedTime() async {
    if (_timerData?.timerStatus == TimerStatus.started ||
        _timerData?.timerStatus == TimerStatus.resumed || _isLazyPause) {
      int sec = _appResumedAt!.difference(_appPausedAt!).inSeconds;
      _secondsElapsed += sec;
      _appPausedAt = null;
      _appResumedAt = null;
      _isLazyPause = false;
      print("⏸️ _loadMinimisedTime: ${sec}");
      _lazyResume();
    }
  }

  _lazyPause() {
    if (_timerData == null ) return;
    //
    _timer?.cancel();
    _timerData = _timerData!.copyWith(
      pausedAt: DateTime.now(),
      timerStatus: TimerStatus.paused,
    );
    _save();
    _isLazyPause = true;
    print("⏸️ Timer lazy paused: ${_timerData!.taskName}");
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
    print("⏯️ Timer lazy resumed: ${_timerData!.taskName}");
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
    print("🗑️ Timer deleted.");
  }

  String getFormattedTime() {
    final duration = Duration(seconds: _secondsElapsed);
    return duration.toString().split('.').first.padLeft(8, "0");
  }

  void _emit() {
    if (_timerStreamController != null && !_timerStreamController!.isClosed) {
      _timerStreamController!.add(_timerData);
    } else {
      print("⚠️ Attempted to emit after stream was closed.");
    }
  }

  Future<void> dispose() async {
    await deleteCurrentTimer();
    _timer?.cancel();
    if (_timerStreamController != null && !_timerStreamController!.isClosed) {
      _timerStreamController!.close();
    }
    print("🧹 TimerController disposed.");
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
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
        print("inactive");
        Future.delayed(Duration(seconds: 1));
        print("inactive:STOREDATA");
        return;
      case AppLifecycleState.paused:
        if (_appPausedAt == null && timerData != null&&timerData?.timerStatus==TimerStatus.started||timerData?.timerStatus==TimerStatus.resumed) {
          _lazyPause();
          _appPausedAt = DateTime.now();
        }

        return;
      case AppLifecycleState.detached:
        _appPausedAt = null;
        _appResumedAt = null;
        print("AppDeatched${_isLazyPause}");
        if(_isLazyPause){
          _scheduleWorkForTermination();

        }

        await Future.delayed(Duration(seconds: 1));
        print("AppDeatched:STOREDATA");
        return;
      case AppLifecycleState.hidden:
        print("AppHidden");
        Future.delayed(Duration(seconds: 1));
        print("AppHidden:STOREDATA");
        return;
    }
  }



  Future<void> _scheduleWorkForTermination() async {
    await Workmanager().registerOneOffTask(
      'save_timer_termination_task',
      'saveTimerState',
      inputData: {
        'taskId': _timerData?.taskId ?? '',
        'wasTerminatedDuringTimer': true,
      },
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
      ),
    );
  }

}


