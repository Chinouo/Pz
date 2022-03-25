import 'profile_image_urls.dart';

class User {
  int? id;
  String? name;
  String? account;
  ProfileImageUrls? profileImageUrls;

  User({this.id, this.name, this.account, this.profileImageUrls});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int?,
        name: json['name'] as String?,
        account: json['account'] as String?,
        profileImageUrls: json['profile_image_urls'] == null
            ? null
            : ProfileImageUrls.fromJson(
                json['profile_image_urls'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'account': account,
        'profile_image_urls': profileImageUrls?.toJson(),
      };
}
