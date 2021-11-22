import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:all_in_one/widgets/useless/custom_pageview/custom_pageview.dart';

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
      body: CustomScrollView(
        slivers: [Header()],
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
        children: [_buildHeader(), _buildRankingList()],
      ),
    );
  }

  Padding _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(8.0.w),
      child: Column(
        children: [
          Divider(
            color: Colors.grey,
            height: 0.5.w,
          ),
          Row(
            children: [Text("Content"), Spacer(), Text("See all")],
          ),
        ],
      ),
    );
  }

  Widget _buildRankingList() {
    return SizedBox(
      height: 225.w,
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 31.w),
            sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((_, index) {
                  return _buildImgContent();
                }, childCount: 7),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    mainAxisExtent: 180.w,
                    mainAxisSpacing: 17.w,
                    maxCrossAxisExtent: 225.w)),
          ),
        ],
      ),
    );
  }

  Widget _buildImgContent() {
    return Column(
      children: [
        SizedBox(
            width: 180.w,
            height: 180.w,
            child: Stack(
              children: [
                //Image
                Container(
                  width: 180.w,
                  height: 180.w,
                  child: ColoredBox(color: Colors.blue),
                ),
                Positioned(
                  left: 8.w,
                  child: ConstrainedBox(
                      constraints: BoxConstraints.loose(Size(180.w, 24.w)),
                      child: ListTile(
                        leading: Icon(
                          Icons.favorite,
                          color: Colors.black,
                          size: 24,
                        ),
                        trailing: Icon(
                          Icons.youtube_searched_for_outlined,
                          size: 24.w,
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
