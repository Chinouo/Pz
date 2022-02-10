import 'profile_image_urls.dart';

class User {
  final int? id;
  final String? name;
  final String? account;
  final ProfileImageUrls? profileImageUrls;
  final bool? isFollowed;

  const User({
    this.id,
    this.name,
    this.account,
    this.profileImageUrls,
    this.isFollowed,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int?,
        name: json['name'] as String?,
        account: json['account'] as String?,
        profileImageUrls: json['profile_image_urls'] == null
            ? null
            : ProfileImageUrls.fromJson(
                json['profile_image_urls'] as Map<String, dynamic>),
        isFollowed: json['is_followed'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'account': account,
        'profile_image_urls': profileImageUrls?.toJson(),
        'is_followed': isFollowed,
      };
}
