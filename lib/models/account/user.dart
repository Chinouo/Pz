import 'package:all_in_one/constant/constant.dart';
import 'package:hive/hive.dart';
import 'profile_image_urls.dart';

part 'user.g.dart';

@HiveType(typeId: HiveTypeIds.userInfo)
class User {
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

  @HiveField(0)
  ProfileImageUrls? profileImageUrls;

  @HiveField(1)
  String? id;

  @HiveField(2)
  String? name;

  @HiveField(3)
  String? account;

  @HiveField(4)
  String? mailAddress;

  @HiveField(5)
  bool? isPremium;

  @HiveField(6)
  int? xRestrict;

  @HiveField(7)
  bool? isMailAuthorized;

  @HiveField(8)
  bool? requirePolicyAgreement;
}
