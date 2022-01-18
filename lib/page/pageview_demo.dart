import 'package:all_in_one/models/illust/illust.dart';
import 'package:all_in_one/provider/illust_rank_provider.dart';
import 'package:all_in_one/widgets/pixiv_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:all_in_one/widgets/useless/custom_pageview/custom_pageview.dart';
import 'package:provider/provider.dart';

class PageViewDemo extends StatefulWidget {
  const PageViewDemo({Key? key}) : super(key: key);

  @override
  _PageViewDemoState createState() => _PageViewDemoState();
}

class _PageViewDemoState extends State<PageViewDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PageViewDemo"),
      ),
      body: const CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 29.0),
              child: Text(
                "Ranking",
                style: TextStyle(fontSize: 36),
              ),
            ),
          ),
          Header(),
          Header(),
          Header(),
          SliverPadding(
            padding: EdgeInsets.only(bottom: 83),
          )
        ],
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [_buildHeader(), _buildRankingList(context)],
      ),
    );
  }

  Padding _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 29.0, vertical: 18.0),
      child: Column(
        children: [
          const Divider(
            color: Colors.grey,
            height: 0,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: const [
                Text(
                  "Content",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text("See all")
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingList(BuildContext context) {
    final illustCollection =
        Provider.of<IllustProvider>(context, listen: false).illustsCollection;

    if (illustCollection.length == 0) {
      return SizedBox(
        height: 225,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 31),
              sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) {
                      return SizedBox(
                        width: 180,
                        height: 180,
                        child: Text("$index"),
                      );
                    },
                    childCount: 3,
                  ),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      mainAxisExtent: 180,
                      mainAxisSpacing: 17,
                      maxCrossAxisExtent: 225)),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 225,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 31),
            sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, index) {
                    return _buildImgContent(index, illustCollection);
                  },
                  childCount: illustCollection.length,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    mainAxisExtent: 180,
                    mainAxisSpacing: 17,
                    maxCrossAxisExtent: 225)),
          ),
        ],
      ),
    );
  }

  Widget _buildImgContent(int index, List<Illust> illusts) {
    Widget img = PixivImage(
      url: illusts[index].imageUrls!.squareMedium!,
      width: 180,
      height: 180,
    );

    return Column(
      children: [
        SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              children: [
                //Image
                img,
                /*
                Container(
                  width: 180,
                  height: 180,
                  child: ColoredBox(color: Colors.blue),
                ),
                */
                Positioned(
                  left: 8,
                  child: ConstrainedBox(
                      constraints: BoxConstraints.loose(Size(180, 24)),
                      child: ListTile(
                        leading: Icon(
                          Icons.favorite,
                          color: Colors.black,
                          size: 24,
                        ),
                        trailing: Icon(
                          Icons.youtube_searched_for_outlined,
                          size: 24,
                        ),
                      )),
                  // child: Row(
                  //   children: [
                  //     Icon(Icons.access_alarms),
                  //     Text("ID"),
                  //     Spacer(),
                  //     Icon(Icons.youtube_searched_for_outlined)
                  //   ],
                  // ),
                )
              ],
            )),
        Text("Description: Hello World! ")
      ],
    );
  }
}
