import 'package:all_in_one/constant/hive_boxes.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'user.dart';

class Account {
  String? accessToken;
  int? expiresIn;
  String? tokenType;
  String? scope;
  String? refreshToken;
  User? user;

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
}
