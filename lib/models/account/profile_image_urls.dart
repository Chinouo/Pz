import 'package:all_in_one/constant/constant.dart';
import 'package:hive/hive.dart';

part 'profile_image_urls.g.dart';

@HiveType(typeId: HiveTypeIds.userProfileImg)
class ProfileImageUrls {
  ProfileImageUrls({this.px16x16, this.px50x50, this.px170x170});

  factory ProfileImageUrls.fromJson(Map<String, Object?> json) {
    return ProfileImageUrls(
      px16x16: json['px_16x16'] as String?,
      px50x50: json['px_50x50'] as String?,
      px170x170: json['px_170x170'] as String?,
    );
  }

  Map<String, Object?> toJson() => {
        'px_16x16': px16x16,
        'px_50x50': px50x50,
        'px_170x170': px170x170,
      };

  @HiveField(0)
  String? px16x16;

  @HiveField(1)
  String? px50x50;

  @HiveField(2)
  String? px170x170;
}
