// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TemplateEntryAdapter extends TypeAdapter<TemplateEntry> {
  @override
  final int typeId = 8;

  @override
  TemplateEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TemplateEntry(
      fields[0] as Product,
      fields[1] as Characteristic?,
      fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TemplateEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.product)
      ..writeByte(1)
      ..write(obj.characteristic)
      ..writeByte(2)
      ..write(obj.count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
