import 'package:flutter/material.dart';

class BaseRoute extends ModalRoute {
  BaseRoute({
    required this.builder,
  });

  WidgetBuilder builder;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => true;

  @override
  Duration get transitionDuration => const Duration(seconds: 5);
  @override
  bool canTransitionFrom(TransitionRoute previousRoute) {
    return true;
  }

  @override
  bool canTransitionTo(TransitionRoute nextRoute) {
    return true;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  RouteConfig? config;

  late Tween<Offset> offset;

  late Tween<double> scale;

  late Tween<Offset> routeCenter;

  void _updateTransitionConfig(Tween<Offset> poz) {
    final target =
        Offset(-config!.routeCenter.begin!.dx, -config!.routeCenter.begin!.dy);
    offset = Tween<Offset>(begin: Offset.zero, end: target);

    final routeSize = MediaQuery.of(navigator!.context).size;

    scale = Tween<double>(begin: 1.0, end: routeSize.width / config!.rect.size.width);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (config == null) {
      return child;
    }
    if (config != null) {
      //debugPrint(config.toString());
      //debugPrint(secondaryAnimation.toString());
    }
    debugPrint(config!.routeCenter.begin.toString());
    return Transform.translate(
      offset: secondaryAnimation.drive(offset).value,
      child: Transform.scale(
        alignment: Alignment.topLeft,
        origin: config!.routeCenter.begin!,
        scale: secondaryAnimation.drive(scale).value,
        child: child,
      ),
    );
  }

  @override
  void didChangeNext(covariant NextRoute? nextRoute) {
    super.didChangeNext(nextRoute);
  }
}

class NextRoute extends ModalRoute {
  NextRoute({
    required this.builder,
    required this.config,
  });

  WidgetBuilder builder;

  RouteConfig config;

  @override
  Color? get barrierColor => Colors.black;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  bool get maintainState => true;

  @override
  bool get opaque => true;

  @override
  Duration get transitionDuration => const Duration(seconds: 5);

  @override
  bool canTransitionFrom(TransitionRoute previousRoute) {
    return true;
  }

  @override
  bool canTransitionTo(TransitionRoute nextRoute) {
    return true;
  }

  late Tween<Size> clipSize;

  late Tween<double> scale;

  late Tween<Offset> routePosition;

  @override
  TickerFuture didPush() {
    var routeSize = MediaQuery.of(navigator!.context).size;
    final initScaleRate = config.rect.width / routeSize.width;
    scale = Tween<double>(begin: initScaleRate, end: 1.0);
    debugPrint("start height:" + (config.rect.height / initScaleRate).toString());
    clipSize = Tween<Size>(
        begin: Size(routeSize.width, (config.rect.height / initScaleRate)),
        end: Size(routeSize.width, (config.rect.height / initScaleRate)));

    routePosition = config.routeCenter;
    return super.didPush();
  }

  @override
  void didChangePrevious(covariant BaseRoute? previousRoute) {
    super.didChangePrevious(previousRoute);
    previousRoute?.config = config;
    previousRoute?._updateTransitionConfig(routePosition);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return Transform.translate(
      offset: animation.drive(routePosition).value,
      child: ScaleTransition(
          alignment: Alignment.topLeft,
          scale: animation.drive(scale),
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minHeight: clipSize.end!.height,
            maxHeight: clipSize.end!.height,
            child: ClipRect(
              clipper: MyClipper(clipSize: animation.drive(clipSize)),
              child: child,
            ),
          )),
    );
  }
}

class RouteConfig {
  RouteConfig({
    required this.rect,
    required this.routeCenter,
  });

  Tween<Offset> routeCenter;

  Rect rect;
}

class MyClipper extends CustomClipper<Rect> {
  MyClipper({
    required this.clipSize,
  });

  Animation<Size> clipSize;

  @override
  Rect getClip(Size size) {
    debugPrint(size.toString());
    return Offset.zero & clipSize.value;
  }

  @override
  bool shouldReclip(MyClipper oldClipper) => oldClipper.clipSize != clipSize;
}
