// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_image_urls.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileImageUrlsAdapter extends TypeAdapter<ProfileImageUrls> {
  @override
  final int typeId = 2;

  @override
  ProfileImageUrls read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfileImageUrls(
      px16x16: fields[0] as String?,
      px50x50: fields[1] as String?,
      px170x170: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProfileImageUrls obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.px16x16)
      ..writeByte(1)
      ..write(obj.px50x50)
      ..writeByte(2)
      ..write(obj.px170x170);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileImageUrlsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
