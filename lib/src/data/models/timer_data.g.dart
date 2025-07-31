// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimerDataAdapter extends TypeAdapter<TimerData> {
  @override
  final int typeId = 0;

  @override
  TimerData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimerData(
      totalTimeInSeconds: fields[0] as int,
      startedAt: fields[1] as DateTime?,
      stoppedAt: fields[2] as DateTime?,
      pausedAt: fields[3] as DateTime?,
      resumedAt: fields[4] as DateTime?,
      lastUpdateAt: fields[8] as DateTime?,
      metaData: (fields[10] as Map?)?.cast<String, dynamic>(),
      taskName: fields[5] as String,
      taskId: fields[6] as String,
      timerStatus: fields[7] as TimerStatus,
      wasTerminatedDuringTimer: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TimerData obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.totalTimeInSeconds)
      ..writeByte(1)
      ..write(obj.startedAt)
      ..writeByte(2)
      ..write(obj.stoppedAt)
      ..writeByte(3)
      ..write(obj.pausedAt)
      ..writeByte(4)
      ..write(obj.resumedAt)
      ..writeByte(5)
      ..write(obj.taskName)
      ..writeByte(6)
      ..write(obj.taskId)
      ..writeByte(7)
      ..write(obj.timerStatus)
      ..writeByte(8)
      ..write(obj.lastUpdateAt)
      ..writeByte(9)
      ..write(obj.wasTerminatedDuringTimer)
      ..writeByte(10)
      ..write(obj.metaData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
