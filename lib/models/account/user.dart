import 'profile_image_urls.dart';

class User {
  ProfileImageUrls? profileImageUrls;
  String? id;
  String? name;
  String? account;
  String? mailAddress;
  bool? isPremium;
  int? xRestrict;
  bool? isMailAuthorized;
  bool? requirePolicyAgreement;

  User({
    this.profileImageUrls,
    this.id,
    this.name,
    this.account,
    this.mailAddress,
    this.isPremium,
    this.xRestrict,
    this.isMailAuthorized,
    this.requirePolicyAgreement,
  });

  factory User.fromJson(Map<String, Object?> json) => User(
        profileImageUrls: json['profile_image_urls'] == null
            ? null
            : ProfileImageUrls.fromJson(
                json['profile_image_urls']! as Map<String, Object?>),
        id: json['id'] as String?,
        name: json['name'] as String?,
        account: json['account'] as String?,
        mailAddress: json['mail_address'] as String?,
        isPremium: json['is_premium'] as bool?,
        xRestrict: json['x_restrict'] as int?,
        isMailAuthorized: json['is_mail_authorized'] as bool?,
        requirePolicyAgreement: json['require_policy_agreement'] as bool?,
      );

  Map<String, Object?> toJson() => {
        'profile_image_urls': profileImageUrls?.toJson(),
        'id': id,
        'name': name,
        'account': account,
        'mail_address': mailAddress,
        'is_premium': isPremium,
        'x_restrict': xRestrict,
        'is_mail_authorized': isMailAuthorized,
        'require_policy_agreement': requirePolicyAgreement,
      };
}
