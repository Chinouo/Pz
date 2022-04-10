import 'package:all_in_one/constant/constant.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'user.dart';

part 'account.g.dart';

@HiveType(typeId: HiveTypeIds.userAccount)
class Account {
  Account({
    this.accessToken,
    this.expiresIn,
    this.tokenType,
    this.scope,
    this.refreshToken,
    this.user,
  });

  factory Account.fromJson(Map<String, Object?> json) => Account(
        accessToken: json['access_token'] as String?,
        expiresIn: json['expires_in'] as int?,
        tokenType: json['token_type'] as String?,
        scope: json['scope'] as String?,
        refreshToken: json['refresh_token'] as String?,
        user: json['user'] == null
            ? null
            : User.fromJson(json['user']! as Map<String, Object?>),
      );

  Map<String, Object?> toJson() => {
        'access_token': accessToken,
        'expires_in': expiresIn,
        'token_type': tokenType,
        'scope': scope,
        'refresh_token': refreshToken,
        'user': user?.toJson(),
      };

  @HiveField(0)
  String? accessToken;

  @HiveField(1)
  int? expiresIn;

  @HiveField(2)
  String? tokenType;

  @HiveField(3)
  String? scope;

  @HiveField(4)
  String? refreshToken;

  @HiveField(5)
  User? user;
}
