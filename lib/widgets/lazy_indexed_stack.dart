/// Thx to OpenJMU 's author Alex (https://github.com/AlexV525)
///
/// A佬的思路就是当用户没点到所需界面的时候，IndexedStack内
/// 对应的Widget用SizeBox生成，达到LazyBuild.
import 'package:flutter/widgets.dart';

class LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final TextDirection? textDirection;
  final StackFit sizing;
  final AlignmentGeometry alignment;

  const LazyIndexedStack(
      {Key? key,
      required this.index,
      required this.children,
      this.alignment = AlignmentDirectional.topStart,
      this.sizing = StackFit.loose,
      this.textDirection})
      : super(key: key);

  @override
  _LazyIndexStackState createState() => _LazyIndexStackState();
}

class _LazyIndexStackState extends State<LazyIndexedStack> {
  // key : 对应界面的下标  value : 对应是否被初始化
  late Map<int, bool> _innerWidgetMap;
  late int selectedIndex;
  @override
  void initState() {
    super.initState();
    // 初始界面对应的下标
    selectedIndex = widget.index;
    // i == selectedIndex 表示选中了初始化的Widget, 所以设置为True
    _innerWidgetMap = Map<int, bool>.fromEntries(
      List<MapEntry<int, bool>>.generate(
        widget.children.length,
        (int i) => MapEntry<int, bool>(i, i == selectedIndex),
      ),
    );
  }

  // 判断是否初始化
  bool _hasInit(int index) => _innerWidgetMap[index] ?? false;

  //LazyBuild的实现
  List<Widget> _buildChildren() {
    final List<Widget> list = <Widget>[];
    for (int i = 0; i < widget.children.length; ++i) {
      if (_hasInit(i)) {
        list.add(widget.children[i]);
      } else {
        list.add(const SizedBox.shrink());
      }
    }
    return list;
  }

  void _updateIndex(int index) {
    if (index == selectedIndex) {
      return;
    }

    setState(() {
      selectedIndex = index;
    });
  }

  // 当外部状态改变，把所需Wiget激活。
  void _activeWidget(int index) {
    _innerWidgetMap[index] = true;
  }

  @override
  void didUpdateWidget(LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _updateIndex(widget.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    _activeWidget(widget.index);
    return IndexedStack(
      index: widget.index,
      children: _buildChildren(),
      sizing: widget.sizing,
      textDirection: widget.textDirection,
    );
  }
}
