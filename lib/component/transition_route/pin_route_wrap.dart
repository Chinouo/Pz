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
  const ContainerWrap({Key? key}) : super(key: key);

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
            builder: (context) {
              return ColoredBox(
                color: Colors.blue,
                child: Center(
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("back"),
                  ),
                ),
              );
            },
            config: _getNextRouteConfig(),
          ),
        );
      },
      child: Container(color: Colors.amber, height: 300, child: Text("GO NEXT ROUTE")),
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
