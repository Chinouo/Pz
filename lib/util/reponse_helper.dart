import 'package:all_in_one/models/comment/comment.dart';
import 'package:all_in_one/models/illust/illust.dart';
import 'package:all_in_one/models/illust/tag.dart';
import 'package:all_in_one/models/spotlight_article.dart';
import 'package:all_in_one/models/trend_tag/trend_tag.dart';
import 'package:all_in_one/models/user_preview/user_preview.dart';
import 'package:dio/dio.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

// List not maintain its length. We do it.
// all can have a same absturct parent class, but i like write one by one.
mixin IllustResponseHelper<T> {
  final illusts = <Illust>[];

  int illustsCount = 0;

  String? nextUrl;

  void storeIllusts(Response response) {
    nextUrl = response.data["next_url"];
    for (var item in response.data["illusts"]) {
      ++illustsCount;
      illusts.add(Illust.fromJson(item));
    }
  }

  void clearIllustsStore() {
    illusts.clear();
    illustsCount = 0;
    nextUrl = null;
  }
}

mixin SpotLightArticleResponseHeler {
  final spotlights = <SpotlightArticle>[];

  int spotlightsCount = 0;

  String? nextUrl;

  void storeSpotLightArticles(Response response) {
    nextUrl = response.data["next_url"];
    for (var item in response.data["spotlight_articles"]) {
      ++spotlightsCount;
      spotlights.add(SpotlightArticle.fromJson(item));
    }
  }

  void clearSpotLightArticlesStore() {
    spotlightsCount = 0;
    spotlights.clear();
    nextUrl = null;
  }
}

mixin TrendTagsResponseHelper {
  final trendTags = <TrendTag>[];

  int trendTagsCount = 0;

  void storeTrendTags(Response response) {
    for (var item in response.data["trend_tags"]) {
      ++trendTagsCount;
      trendTags.add(TrendTag.fromJson(item));
    }
  }

  void clearTrendTagsStore() {
    trendTags.clear();
    trendTagsCount = 0;
  }
}

// comment_access_controll current not imp.
mixin CommentResponseHelper {
  final comments = <Comment>[];

  int commentsCount = 0;

  String? nextUrl;

  void storeComments(Response response) {
    nextUrl = response.data["next_url"];
    for (var item in response.data["comments"]) {
      ++commentsCount;
      final temp = Comment.fromJson(item);
      if (temp.comment!.isNotEmpty) {
        comments.add(temp);
      }
    }
  }

  // May never call this.
  void clearCommentsStore() {
    commentsCount = 0;
    comments.clear();
    nextUrl = null;
  }
}

mixin AutoFillWordsReponseHelper {
  final words = <Tag>[];

  int wordsCount = 0;

  void storeAutoFillWords(Response response) {
    for (var item in response.data["tags"]) {
      ++wordsCount;
      words.add(Tag.fromJson(item));
    }
  }

  void clearAutoFillWordsStore() {
    wordsCount = 0;
    words.clear();
  }
}

mixin UserPreviewsResponseHelper {
  String? nextUrl;

  final userPreviews = <UserPreview>[];

  int previewCount = 0;

  void storeUserPreviews(Response response) {
    nextUrl = response.data["next_url"];
    for (var item in response.data["user_previews"]) {
      userPreviews.add(UserPreview.fromJson(item));
      ++previewCount;
    }
  }

  void clearUserPreviewStore() {
    userPreviews.clear();
    nextUrl = null;
    previewCount = 0;
  }
}

mixin SafeStateHelper on State {
  /// if post flag is true, post is to PostFrame.
  void setStateSafe(void Function() fn, {bool post = false}) {
    assert(SchedulerBinding.instance != null);
    if (post) {
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        if (mounted) setState(fn);
      });
    } else {
      if (mounted) setState(fn);
    }
  }
}
