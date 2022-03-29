import 'package:all_in_one/models/comment/comment.dart';
import 'package:all_in_one/models/illust/illust.dart';
import 'package:all_in_one/models/illust/tag.dart';
import 'package:all_in_one/models/spotlight_article.dart';
import 'package:all_in_one/models/trend_tag/trend_tag.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// List not maintain its length. We do it.

mixin IllustResponseHelper on State {
  final illusts = <Illust>[];

  int illustsCount = 0;

  String? nextUrl;

  @override
  void didUpdateWidget(StatefulWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

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
      comments.add(Comment.fromJson(item));
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
