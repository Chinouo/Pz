import 'user.dart';

class User {
  String? accessToken;
  int? expiresIn;
  String? tokenType;
  String? scope;
  String? refreshToken;
  User? user;

  User({
    this.accessToken,
    this.expiresIn,
    this.tokenType,
    this.scope,
    this.refreshToken,
    this.user,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        accessToken: json['access_token'] as String?,
        expiresIn: json['expires_in'] as int?,
        tokenType: json['token_type'] as String?,
        scope: json['scope'] as String?,
        refreshToken: json['refresh_token'] as String?,
        user: json['user'] == null
            ? null
            : User.fromJson(json['user'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'expires_in': expiresIn,
        'token_type': tokenType,
        'scope': scope,
        'refresh_token': refreshToken,
        'user': user?.toJson(),
      };
}
