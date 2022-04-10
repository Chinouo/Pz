// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_boxes.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SearchConfigAdapter extends TypeAdapter<SearchConfig> {
  @override
  final int typeId = 3;

  @override
  SearchConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SearchConfig(
      stared: fields[0] as int?,
      sort: fields[1] as String,
      target: fields[2] as String,
      startDate: fields[3] as DateTime,
      endDate: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SearchConfig obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.stared)
      ..writeByte(1)
      ..write(obj.sort)
      ..writeByte(2)
      ..write(obj.target)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
