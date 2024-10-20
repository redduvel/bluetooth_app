// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'characteristic.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CharacteristicAdapter extends TypeAdapter<Characteristic> {
  @override
  final int typeId = 3;

  @override
  Characteristic read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Characteristic(
      name: fields[0] as String,
      value: fields[2] as int,
      unit: fields[3] as MeasurementUnit,
    );
  }

  @override
  void write(BinaryWriter writer, Characteristic obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.shortName)
      ..writeByte(2)
      ..write(obj.value)
      ..writeByte(3)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacteristicAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MeasurementUnitAdapter extends TypeAdapter<MeasurementUnit> {
  @override
  final int typeId = 3;

  @override
  MeasurementUnit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MeasurementUnit.hours;
      case 1:
        return MeasurementUnit.minutes;
      case 2:
        return MeasurementUnit.days;
      default:
        return MeasurementUnit.hours;
    }
  }

  @override
  void write(BinaryWriter writer, MeasurementUnit obj) {
    switch (obj) {
      case MeasurementUnit.hours:
        writer.writeByte(0);
        break;
      case MeasurementUnit.minutes:
        writer.writeByte(1);
        break;
      case MeasurementUnit.days:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeasurementUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
