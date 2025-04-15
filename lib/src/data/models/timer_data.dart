import 'package:hive/hive.dart';

import '../../../flutter_task_time_tracker.dart';


part 'timer_data.g.dart';

@HiveType(typeId: 0)
class TimerData extends HiveObject {
  @HiveField(0)
  final int totalTimeInSeconds;

  @HiveField(1)
  final DateTime? startedAt;

  @HiveField(2)
  final DateTime? stoppedAt;

  @HiveField(3)
  final DateTime? pausedAt;

  @HiveField(4)
  final DateTime? resumedAt;

  @HiveField(5)
  final String taskName;

  @HiveField(6)
  final String taskId;

  @HiveField(7)
  final TimerStatus timerStatus;

  @HiveField(8)
  final DateTime? lastUpdateAt;

  TimerData({
    required this.totalTimeInSeconds,
     this.startedAt,
    this.stoppedAt,
    this.pausedAt,
    this.resumedAt,
    this.lastUpdateAt,
    required this.taskName,
    required this.taskId,
    required this.timerStatus,
  });

  TimerData copyWith({
    int? totalTimeInSeconds,
    DateTime? startedAt,
    DateTime? pausedAt,
    DateTime? resumedAt,
    DateTime? stoppedAt,
    DateTime? lastUpdateAt,
    String? taskName,
    String? taskId,
    TimerStatus? timerStatus,
  }) {
    return TimerData(
      totalTimeInSeconds: totalTimeInSeconds ?? this.totalTimeInSeconds,
      startedAt: startedAt ?? this.startedAt,
      stoppedAt: stoppedAt ?? this.stoppedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      resumedAt: resumedAt ?? this.resumedAt,
      lastUpdateAt: lastUpdateAt ?? this.lastUpdateAt,
      taskName: taskName ?? this.taskName,
      taskId: taskId ?? this.taskId,
      timerStatus: timerStatus ?? this.timerStatus,
    );
  }
}
//flutter pub run build_runner build