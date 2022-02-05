import 'package:flutter/widgets.dart';

@immutable
class SpotlightArticle {
  final int? id;
  final String? title;
  final String? pureTitle;
  final String? thumbnail;
  final String? articleUrl;
  final DateTime? publishDate;
  final String? category;
  final String? subcategoryLabel;

  const SpotlightArticle({
    this.id,
    this.title,
    this.pureTitle,
    this.thumbnail,
    this.articleUrl,
    this.publishDate,
    this.category,
    this.subcategoryLabel,
  });

  factory SpotlightArticle.fromJson(Map<String, dynamic> json) {
    return SpotlightArticle(
      id: json['id'] as int?,
      title: json['title'] as String?,
      pureTitle: json['pure_title'] as String?,
      thumbnail: json['thumbnail'] as String?,
      articleUrl: json['article_url'] as String?,
      publishDate: json['publish_date'] == null
          ? null
          : DateTime.parse(json['publish_date'] as String),
      category: json['category'] as String?,
      subcategoryLabel: json['subcategory_label'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'pure_title': pureTitle,
        'thumbnail': thumbnail,
        'article_url': articleUrl,
        'publish_date': publishDate?.toIso8601String(),
        'category': category,
        'subcategory_label': subcategoryLabel,
      };
}
