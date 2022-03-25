import 'user.dart';

class Comment {
  int? id;
  String? comment;
  DateTime? date;
  User? user;
  bool? hasReplies;
  dynamic stamp;

  Comment({
    this.id,
    this.comment,
    this.date,
    this.user,
    this.hasReplies,
    this.stamp,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] as int?,
        comment: json['comment'] as String?,
        date: json['date'] == null
            ? null
            : DateTime.parse(json['date'] as String),
        user: json['user'] == null
            ? null
            : User.fromJson(json['user'] as Map<String, dynamic>),
        hasReplies: json['has_replies'] as bool?,
        stamp: json['stamp'] as dynamic,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'comment': comment,
        'date': date?.toIso8601String(),
        'user': user?.toJson(),
        'has_replies': hasReplies,
        'stamp': stamp,
      };
}
