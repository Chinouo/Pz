import 'illust.dart';
import 'user.dart';

class UserPreview {
  User? user;
  List<Illust>? illusts;
  List<dynamic>? novels;
  bool? isMuted;

  UserPreview({this.user, this.illusts, this.novels, this.isMuted});

  factory UserPreview.fromJson(Map<String, dynamic> json) => UserPreview(
        user: json['user'] == null
            ? null
            : User.fromJson(json['user'] as Map<String, dynamic>),
        illusts: (json['illusts'] as List<dynamic>?)
            ?.map((e) => Illust.fromJson(e as Map<String, dynamic>))
            .toList(),
        novels: json['novels'] as List<dynamic>?,
        isMuted: json['is_muted'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'user': user?.toJson(),
        'illusts': illusts?.map((e) => e.toJson()).toList(),
        'novels': novels,
        'is_muted': isMuted,
      };
}
