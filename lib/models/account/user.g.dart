// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 1;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      profileImageUrls: fields[0] as ProfileImageUrls?,
      id: fields[1] as String?,
      name: fields[2] as String?,
      account: fields[3] as String?,
      mailAddress: fields[4] as String?,
      isPremium: fields[5] as bool?,
      xRestrict: fields[6] as int?,
      isMailAuthorized: fields[7] as bool?,
      requirePolicyAgreement: fields[8] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.profileImageUrls)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.account)
      ..writeByte(4)
      ..write(obj.mailAddress)
      ..writeByte(5)
      ..write(obj.isPremium)
      ..writeByte(6)
      ..write(obj.xRestrict)
      ..writeByte(7)
      ..write(obj.isMailAuthorized)
      ..writeByte(8)
      ..write(obj.requirePolicyAgreement);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
