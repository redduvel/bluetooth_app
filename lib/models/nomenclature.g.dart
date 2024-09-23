// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nomenclature.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NomenclatureAdapter extends TypeAdapter<Nomenclature> {
  @override
  final int typeId = 1;

  @override
  Nomenclature read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Nomenclature(
      id: fields[0] as String?,
      order: fields[1] as int,
      name: fields[2] as String,
      isHide: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Nomenclature obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.order)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.isHide);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NomenclatureAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
