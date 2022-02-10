import 'image_urls.dart';
import 'meta_single_page.dart';
import 'tag.dart';
import 'user.dart';

class Illust {
  final int? id;
  final String? title;
  final String? type;
  final ImageUrls? imageUrls;
  final String? caption;
  final int? restrict;
  final User? user;
  final List<Tag>? tags;
  final List<dynamic>? tools;
  final DateTime? createDate;
  final int? pageCount;
  final int? width;
  final int? height;
  final int? sanityLevel;
  final int? xRestrict;
  final dynamic series;
  final MetaSinglePage? metaSinglePage;
  final List<dynamic>? metaPages;
  final int? totalView;
  final int? totalBookmarks;
  final bool? isBookmarked;
  final bool? visible;
  final bool? isMuted;

  const Illust({
    this.id,
    this.title,
    this.type,
    this.imageUrls,
    this.caption,
    this.restrict,
    this.user,
    this.tags,
    this.tools,
    this.createDate,
    this.pageCount,
    this.width,
    this.height,
    this.sanityLevel,
    this.xRestrict,
    this.series,
    this.metaSinglePage,
    this.metaPages,
    this.totalView,
    this.totalBookmarks,
    this.isBookmarked,
    this.visible,
    this.isMuted,
  });

  factory Illust.fromJson(Map<String, dynamic> json) => Illust(
        id: json['id'] as int?,
        title: json['title'] as String?,
        type: json['type'] as String?,
        imageUrls: json['image_urls'] == null
            ? null
            : ImageUrls.fromJson(json['image_urls'] as Map<String, dynamic>),
        caption: json['caption'] as String?,
        restrict: json['restrict'] as int?,
        user: json['user'] == null
            ? null
            : User.fromJson(json['user'] as Map<String, dynamic>),
        tags: (json['tags'] as List<dynamic>?)
            ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
            .toList(),
        tools: json['tools'] as List<dynamic>?,
        createDate: json['create_date'] == null
            ? null
            : DateTime.parse(json['create_date'] as String),
        pageCount: json['page_count'] as int?,
        width: json['width'] as int?,
        height: json['height'] as int?,
        sanityLevel: json['sanity_level'] as int?,
        xRestrict: json['x_restrict'] as int?,
        series: json['series'] as dynamic,
        metaSinglePage: json['meta_single_page'] == null
            ? null
            : MetaSinglePage.fromJson(
                json['meta_single_page'] as Map<String, dynamic>),
        metaPages: json['meta_pages'] as List<dynamic>?,
        totalView: json['total_view'] as int?,
        totalBookmarks: json['total_bookmarks'] as int?,
        isBookmarked: json['is_bookmarked'] as bool?,
        visible: json['visible'] as bool?,
        isMuted: json['is_muted'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'image_urls': imageUrls?.toJson(),
        'caption': caption,
        'restrict': restrict,
        'user': user?.toJson(),
        'tags': tags?.map((e) => e.toJson()).toList(),
        'tools': tools,
        'create_date': createDate?.toIso8601String(),
        'page_count': pageCount,
        'width': width,
        'height': height,
        'sanity_level': sanityLevel,
        'x_restrict': xRestrict,
        'series': series,
        'meta_single_page': metaSinglePage?.toJson(),
        'meta_pages': metaPages,
        'total_view': totalView,
        'total_bookmarks': totalBookmarks,
        'is_bookmarked': isBookmarked,
        'visible': visible,
        'is_muted': isMuted,
      };
}
