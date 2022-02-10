/// 搜索页
/// 提供 illust 和 user
/// 搜索 illust 按照官方的来
/// 搜索 user 下面时推荐画师及其作品
import 'package:all_in_one/api/api_client.dart';
import 'package:all_in_one/models/trend_tag/trend_tag.dart';
import 'package:all_in_one/provider/trend_tag_provider.dart';
import 'package:all_in_one/widgets/pixiv_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TagGrid(),
    );
  }
}

class TagGrid extends StatefulWidget {
  const TagGrid({Key? key}) : super(key: key);

  @override
  _TagGridState createState() => _TagGridState();
}

// 写道搜索页 想了一想 为了启动后发送一堆请求后马上用  似乎没有必要跨组件状态管理
class _TagGridState extends State<TagGrid> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrendTagProvider>(
      builder: (context, trendProvider, child) {
        final tagCollection = trendProvider.collection;
        if (tagCollection.isEmpty) return const SizedBox.shrink();

        return CustomScrollView(
          slivers: [
            SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                return PixivImage(
                    url: tagCollection[index].illust!.imageUrls!.squareMedium!);
              }, childCount: tagCollection.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
            )
          ],
        );
      },
    );
  }
}
