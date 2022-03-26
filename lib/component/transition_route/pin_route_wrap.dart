import 'package:all_in_one/component/transition_route/clip_scale_route.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
        ),
        body: Center(
          child: Container(
            child: Text('Hello World'),
          ),
        ),
      ),
    );
  }
}

class ContainerWrap extends StatefulWidget {
  const ContainerWrap({
    Key? key,
    required this.closeBuilder,
    required this.openBuilder,
  }) : super(key: key);

  final WidgetBuilder closeBuilder;

  final WidgetBuilder openBuilder;

  @override
  State<ContainerWrap> createState() => _ContainerWrapState();
}

class _ContainerWrapState extends State<ContainerWrap> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          NextRoute(
            builder: widget.openBuilder,
            config: _getNextRouteConfig(),
          ),
        );
      },
      child: widget.closeBuilder(context),
    );
  }

  RouteConfig _getNextRouteConfig() {
    RenderBox box = context.findRenderObject() as RenderBox;
    debugPrint(box.toString());
    Offset offset = box.localToGlobal(box.size.topLeft(Offset.zero));

    Tween<Offset> routeCenter = Tween<Offset>(begin: offset, end: Offset.zero);

    return RouteConfig(rect: box.paintBounds, routeCenter: routeCenter);
  }
}
