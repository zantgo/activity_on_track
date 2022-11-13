// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ActivityData.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityDataAdapter extends TypeAdapter<ActivityData> {
  @override
  final int typeId = 0;

  @override
  ActivityData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityData(
      fields[0] as String,
    )
      ..days = (fields[1] as List).cast<DateTime>()
      ..count = fields[2] as int
      ..description = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, ActivityData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.days)
      ..writeByte(2)
      ..write(obj.count)
      ..writeByte(3)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
