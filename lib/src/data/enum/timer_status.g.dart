// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimerStatusAdapter extends TypeAdapter<TimerStatus> {
  @override
  final int typeId = 1;

  @override
  TimerStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TimerStatus.notStarted;
      case 1:
        return TimerStatus.started;
      case 2:
        return TimerStatus.paused;
      case 3:
        return TimerStatus.resumed;
      case 4:
        return TimerStatus.stopped;
      default:
        return TimerStatus.notStarted;
    }
  }

  @override
  void write(BinaryWriter writer, TimerStatus obj) {
    switch (obj) {
      case TimerStatus.notStarted:
        writer.writeByte(0);
        break;
      case TimerStatus.started:
        writer.writeByte(1);
        break;
      case TimerStatus.paused:
        writer.writeByte(2);
        break;
      case TimerStatus.resumed:
        writer.writeByte(3);
        break;
      case TimerStatus.stopped:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
