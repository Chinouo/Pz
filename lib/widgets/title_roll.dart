import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DailyContainer extends StatelessWidget {
  const DailyContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 分割线颜色
    final Color dividerColor = const Color(0x00000000).withOpacity(0.22);

    return Container(
      margin: EdgeInsets.only(top: 22.h),
      width: 333.h,
      child: Column(
        children: [
          Divider(color: dividerColor, height: 0.h),
          Padding(
            padding: EdgeInsets.only(top: 17.h, left: 21.h, right: 21.h),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(
                "Title",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.27,
                    letterSpacing: 0),
              ),
              trailing: Text("See all",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.normal,
                      height: 1.5,
                      letterSpacing: 0.15)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: SizedBox(
                width: 375.h,
                height: 159.h,
                child: CustomScrollView(
                  scrollDirection: Axis.horizontal,
                  slivers: <Widget>[
                    SliverPadding(padding: EdgeInsets.only(left: 18.w)),
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
      margin: EdgeInsets.only(right: 13.w),
      color: Colors.red,
      width: 159.r,
      height: 159.r,
      child: Text("${widget.index}"),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
