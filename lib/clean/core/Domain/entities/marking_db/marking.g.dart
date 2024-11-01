// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marking.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarkingAdapter extends TypeAdapter<Marking> {
  @override
  final int typeId = 5;

  @override
  Marking read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Marking(
      id: fields[0] as String?,
      product: fields[1] as Product,
      user: fields[2] as User,
      category: fields[3] as Category,
      startDate: fields[4] as DateTime,
      endDate: fields[5] as DateTime,
      count: fields[6] as int,
      status: fields[7] as MarkingStatus?,
    );
  }

  @override
  void write(BinaryWriter writer, Marking obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.product)
      ..writeByte(2)
      ..write(obj.user)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(6)
      ..write(obj.count)
      ..writeByte(7)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MarkingStatusAdapter extends TypeAdapter<MarkingStatus> {
  @override
  final int typeId = 6;

  @override
  MarkingStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MarkingStatus.none;
      case 1:
        return MarkingStatus.normal;
      case 2:
        return MarkingStatus.warning;
      case 3:
        return MarkingStatus.expired;
      default:
        return MarkingStatus.none;
    }
  }

  @override
  void write(BinaryWriter writer, MarkingStatus obj) {
    switch (obj) {
      case MarkingStatus.none:
        writer.writeByte(0);
        break;
      case MarkingStatus.normal:
        writer.writeByte(1);
        break;
      case MarkingStatus.warning:
        writer.writeByte(2);
        break;
      case MarkingStatus.expired:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkingStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
