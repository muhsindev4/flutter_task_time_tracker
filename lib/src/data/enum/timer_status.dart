import 'package:hive/hive.dart';

part 'timer_status.g.dart';

@HiveType(typeId: 1)
enum TimerStatus {
  @HiveField(0)
  notStarted,
  @HiveField(1)
  started,

  @HiveField(2)
  paused,

  @HiveField(3)
  resumed,

  @HiveField(4)
  stopped,
}
