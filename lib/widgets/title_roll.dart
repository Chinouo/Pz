import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DailyContainer extends StatelessWidget {
  const DailyContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 分割线颜色
    final Color dividerColor = const Color(0x00000000).withOpacity(0.22);

    return Container(
      margin: EdgeInsets.only(top: 22),
      width: 333,
      child: Column(
        children: [
          Divider(color: dividerColor, height: 0),
          Padding(
            padding: EdgeInsets.only(top: 17, left: 21, right: 21),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(
                "Title",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.27,
                    letterSpacing: 0),
              ),
              trailing: Text("See all",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      height: 1.5,
                      letterSpacing: 0.15)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: SizedBox(
                width: 375,
                height: 159,
                child: CustomScrollView(
                  scrollDirection: Axis.horizontal,
                  slivers: <Widget>[
                    SliverPadding(padding: EdgeInsets.only(left: 18)),
                    SliverList(
                        delegate: SliverChildBuilderDelegate((_, int index) {
                      return KeepAlive(index: index);
                    })),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}

class KeepAlive extends StatefulWidget {
  final int index;
  const KeepAlive({Key? key, required this.index}) : super(key: key);

  @override
  _KeepAliveState createState() => _KeepAliveState();
}

class _KeepAliveState extends State<KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 13),
      color: Colors.red,
      width: 159,
      height: 159,
      child: Text("${widget.index}"),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
